import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:viasolucoes/models/client.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/services/client_service.dart';
import 'package:viasolucoes/services/contract_service.dart';
import 'package:viasolucoes/services/log_service.dart';
import 'package:viasolucoes/theme.dart';

class CreateContractScreen extends StatefulWidget {
  final Client? client; // cliente vindo de ClientDetailScreen

  const CreateContractScreen({super.key, this.client});

  @override
  State<CreateContractScreen> createState() => _CreateContractScreenState();
}

class _CreateContractScreenState extends State<CreateContractScreen> {
  final _formKey = GlobalKey<FormState>();

  final _contractService = ContractService();
  final _clientService = ClientService();
  final _logService = LogService();
  final _uuid = const Uuid();

  List<Client> _clients = [];
  bool _clientsLoaded = false;

  String? _selectedClientId;

  final _descriptionController = TextEditingController();
  File? _selectedFile;

  DateTime? _startDate;
  DateTime? _endDate;

  bool _loading = false;

  final _formatter = DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR');

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      _selectedClientId = widget.client!.id;
    }
    _loadClients();
  }

  /// ===========================================================
  /// 🔥 CARREGA CLIENTES E GARANTE QUE UM CLIENTE SEMPRE EXISTE
  /// ===========================================================
  Future<void> _loadClients() async {
    final clients = await _clientService.getAll();

    setState(() {
      _clients = clients;

      // Se o cliente veio da tela anterior mas não está no JSON
      if (widget.client != null &&
          !_clients.any((c) => c.id == widget.client!.id)) {
        _clients.add(widget.client!); // garante que o dropdown terá o item
      }

      // Atualiza o ID selecionado
      if (widget.client != null) {
        _selectedClientId = widget.client!.id;
      }

      _clientsLoaded = true;
    });
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: ViaColors.primary,
            onPrimary: Colors.white,
            onSurface: ViaColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final client = _clients.firstWhere((c) => c.id == _selectedClientId);

    setState(() => _loading = true);

    final contract = Contract(
      id: _uuid.v4(),
      clientId: client.id,
      clientName: client.companyName,
      description: _descriptionController.text.trim(),
      status: 'active',
      assignedUserId: 'user1',
      startDate: _startDate ?? DateTime.now(),
      endDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      progressPercentage: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      hasFile: _selectedFile != null,
      fileName: _selectedFile?.path.split('/').last,
      fileUrl: null,
    );

    await _contractService.add(contract);

    await _logService.add(
      contractId: contract.id,
      action: 'contract_created',
      description: 'Contrato criado para ${client.companyName}',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Contrato criado com sucesso!'),
        backgroundColor: Colors.green.shade600,
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.client != null
              ? 'Novo contrato para ${widget.client!.companyName}'
              : 'Novo Contrato',
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildClientField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 16),
              _buildDatesField(),
              const SizedBox(height: 16),
              _buildUploadSection(),
              const SizedBox(height: 30),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CAMPOS
  // ---------------------------------------------------------------------------

  Widget _buildClientField() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("Cliente"),
          const SizedBox(height: 10),

          if (!_clientsLoaded)
            const Center(child: CircularProgressIndicator())
          else
            DropdownButtonFormField<String>(
              value: _selectedClientId,
              decoration: _inputDecoration(),
              items: _clients.map((c) {
                return DropdownMenuItem(
                  value: c.id,
                  child: Text(c.companyName),
                );
              }).toList(),

              onChanged: widget.client != null
                  ? null
                  : (v) => setState(() => _selectedClientId = v),

              validator: widget.client != null
                  ? null
                  : (v) => v == null ? "Selecione um cliente" : null,
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("Descrição"),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            decoration: _inputDecoration(hint: "Descreva o contrato..."),
            maxLines: 3,
            validator: (v) =>
            v == null || v.trim().isEmpty ? "Informe a descrição" : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDatesField() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("Datas"),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _dateField(
                  date: _startDate,
                  onTap: () => _selectDate(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dateField(
                  date: _endDate,
                  onTap: () => _selectDate(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("Anexo do Contrato"),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: ViaColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: ViaColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_upload_rounded,
                      color: ViaColors.primary, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Selecionar arquivo",
                      style: TextStyle(
                        color: ViaColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          if (_selectedFile != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.insert_drive_file_rounded,
                      size: 40, color: Colors.grey.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedFile!.path.split('/').last,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: Colors.red.shade400, size: 22),
                    onPressed: () => setState(() => _selectedFile = null),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _save,
        icon: const Icon(Icons.save_rounded),
        label: const Text("Salvar Contrato"),
        style: ElevatedButton.styleFrom(
          backgroundColor: ViaColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // COMPONENTES UTILITÁRIOS
  // ---------------------------------------------------------------------------

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding:
      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _dateField({
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date != null
                    ? _formatter.format(date)
                    : "Selecionar data",
                style: TextStyle(
                  color: date != null
                      ? ViaColors.textPrimary
                      : Colors.grey.shade500,
                ),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}
