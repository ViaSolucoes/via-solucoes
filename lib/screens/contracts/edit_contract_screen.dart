import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/models/log_entry.dart';
import 'package:viasolucoes/services/supabase/log_service_supabase.dart';
import 'package:viasolucoes/services/supabase/contract_service_supabase.dart';
import 'package:uuid/uuid.dart';

import 'package:viasolucoes/theme.dart';

class EditContractScreen extends StatefulWidget {
  final Contract contract;

  const EditContractScreen({super.key, required this.contract});

  @override
  State<EditContractScreen> createState() => _EditContractScreenState();
}

class _EditContractScreenState extends State<EditContractScreen> {
  final _formKey = GlobalKey<FormState>();

  final _contractService = ContractServiceSupabase();
  final _logService = LogServiceSupabase();

  late TextEditingController _descriptionController;

  DateTime? _startDate;
  DateTime? _endDate;

  File? _selectedFile;             // novo arquivo
  bool _removeOldFile = false;     // flag para remover arquivo anterior

  final _formatter = DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR');
  final supabase = Supabase.instance.client;

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _descriptionController =
        TextEditingController(text: widget.contract.description);

    _startDate = widget.contract.startDate;
    _endDate = widget.contract.endDate;
  }

  // ==============================================================================
  // Seleção de datas
  // ==============================================================================
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

  // ==============================================================================
  // Selecionar arquivo novo
  // ==============================================================================
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _removeOldFile = true; // vai substituir o arquivo anterior
      });
    }
  }

  // ==============================================================================
  // Excluir arquivo antigo do bucket
  // ==============================================================================
  Future<void> _deleteOldFile() async {
    if (widget.contract.fileName == null) return;

    try {
      await supabase.storage
          .from('contract-files')
          .remove(['contracts/${widget.contract.fileName}']);
    } catch (e) {
      print('⚠ Erro ao excluir arquivo antigo: $e');
    }
  }

  // ==============================================================================
  // Upload arquivo novo
  // ==============================================================================
  Future<Map<String, String?>> _uploadNewFile() async {
    if (_selectedFile == null) {
      return {'fileUrl': widget.contract.fileUrl, 'fileName': widget.contract.fileName};
    }

    try {
      // remover arquivo antigo se existir
      if (_removeOldFile && widget.contract.fileName != null) {
        await _deleteOldFile();
      }

      final fileBytes = await _selectedFile!.readAsBytes();
      final newName = "${const Uuid().v4()}_${_selectedFile!.path.split('/').last}";

      await supabase.storage.from('contract-files').uploadBinary(
        'contracts/$newName',
        fileBytes,
        fileOptions: const FileOptions(upsert: false),
      );

      final newUrl = supabase.storage
          .from('contract-files')
          .getPublicUrl('contracts/$newName');

      return {'fileUrl': newUrl, 'fileName': newName};
    } catch (e) {
      print('❌ Erro ao enviar arquivo: $e');
      return {'fileUrl': null, 'fileName': null};
    }
  }

  // ==============================================================================
  // Salvar alterações
  // ==============================================================================
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    String? fileUrl = widget.contract.fileUrl;
    String? fileName = widget.contract.fileName;

    // Caso o usuário tenha marcado para remover o arquivo sem adicionar outro
    if (_removeOldFile && _selectedFile == null) {
      await _deleteOldFile();
      fileUrl = null;
      fileName = null;
    }

    // Caso tenha selecionado um novo arquivo
    if (_selectedFile != null) {
      final result = await _uploadNewFile();
      fileUrl = result['fileUrl'];
      fileName = result['fileName'];
    }

    final updatedContract = widget.contract.copyWith(
      description: _descriptionController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      updatedAt: DateTime.now(),
      hasFile: fileUrl != null,
      fileUrl: fileUrl,
      fileName: fileName,
    );

    try {
      // 🔵 Atualizar contrato no Supabase
      await _contractService.update(updatedContract);

      // 🔵 Registrar log no novo formato
      await _logService.log(
        module: LogModule.contrato,
        action: LogAction.updated,
        entityType: "CONTRATO",
        entityId: widget.contract.id,
        description: "Contrato atualizado.",
        metadata: {
          "fileReplaced": _selectedFile != null,
          "fileRemoved": _removeOldFile && _selectedFile == null,
        },
      );

      if (!mounted) return;

      setState(() => _loading = false);
      Navigator.pop(context, true);

    } catch (e) {
      print("❌ Erro ao atualizar contrato: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro ao atualizar contrato.'),
          backgroundColor: Colors.red.shade600,
        ),
      );

      setState(() => _loading = false);
    }
  }


  // ==============================================================================
  // Abrir arquivo atual
  // ==============================================================================
  Future<void> _openFile() async {
    if (widget.contract.fileUrl == null) return;

    final uri = Uri.parse(widget.contract.fileUrl!);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Não foi possível abrir o arquivo."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==============================================================================
  // UI
  // ==============================================================================
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
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Descrição",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      validator: (v) =>
                      v == null || v.isEmpty ? "Informe a descrição" : null,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Datas",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
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

              // ==========================================================
              // ARQUIVO
              // ==========================================================
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Anexo do Contrato",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),

                    if (widget.contract.hasFile && !_removeOldFile)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.insert_drive_file,
                                    color: Colors.blue, size: 30),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    widget.contract.fileName!,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.download),
                                  onPressed: _openFile,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() => _removeOldFile = true);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),

                    OutlinedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text("Selecionar arquivo"),
                    ),

                    if (_selectedFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          "Novo arquivo: ${_selectedFile!.path.split('/').last}",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================================
  // COMPONENTES DE UI
  // ==============================================================================
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
                "$label: ${_formatter.format(date)}",
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const Icon(Icons.calendar_today_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
