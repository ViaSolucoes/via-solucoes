import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/services/contract_service.dart';
import 'package:viasolucoes/services/log_service.dart';
import 'package:viasolucoes/theme.dart';

class EditContractScreen extends StatefulWidget {
  final Contract contract;

  const EditContractScreen({super.key, required this.contract});

  @override
  State<EditContractScreen> createState() => _EditContractScreenState();
}

class _EditContractScreenState extends State<EditContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contractService = ContractService();
  final _logService = LogService();

  late TextEditingController _descriptionController;

  DateTime? _startDate;
  DateTime? _endDate;
  File? _selectedFile;

  final _formatter = DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR');
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _descriptionController =
        TextEditingController(text: widget.contract.description);

    _startDate = widget.contract.startDate;
    _endDate = widget.contract.endDate;
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: isStart ? _startDate! : _endDate!,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final updatedContract = widget.contract.copyWith(
      description: _descriptionController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      updatedAt: DateTime.now(),
      hasFile: _selectedFile != null,
      fileName: _selectedFile?.path.split('/').last,
    );

    await _contractService.update(updatedContract);

    await _logService.add(
      contractId: widget.contract.id,
      action: 'contract_updated',
      description: 'Contrato atualizado.',
    );

    if (!mounted) return;

    setState(() => _loading = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF4F5F7),
        title: const Text(
          "Editar Contrato",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ================================
              // DESCRIÇÃO
              // ================================
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Descrição",
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Descrição do contrato...",
                      ),
                      validator: (value) =>
                      (value == null || value.isEmpty)
                          ? "Informe a descrição"
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================================
              // DATAS
              // ================================
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Datas",
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _datePickerTile(
                            label: "Início",
                            date: _startDate!,
                            onTap: () => _selectDate(true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _datePickerTile(
                            label: "Término",
                            date: _endDate!,
                            onTap: () => _selectDate(false),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================================
              // ARQUIVO
              // ================================
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Anexo do Contrato",
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    _filePickerButton(),

                    if (_selectedFile != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        "Arquivo: ${_selectedFile!.path.split('/').last}",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ================================
              // BOTÃO SALVAR
              // ================================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text("Salvar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ViaColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================================
  // COMPONENTES DE UI (Reutilizáveis e modernos)
  // =============================================================================

  Widget _sectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _datePickerTile({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "${label}: ${_formatter.format(date)}",
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const Icon(Icons.calendar_today_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _filePickerButton() {
    return OutlinedButton.icon(
      onPressed: _pickFile,
      icon: const Icon(Icons.cloud_upload_outlined),
      label: const Text("Selecionar arquivo"),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        side: BorderSide(color: ViaColors.primary.withOpacity(0.4)),
        foregroundColor: ViaColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
