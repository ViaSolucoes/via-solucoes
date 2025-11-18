import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:viasolucoes/models/client.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/services/contract_service.dart';
import 'package:viasolucoes/theme.dart';

class CreateContractScreen extends StatefulWidget {
  final Client client;

  const CreateContractScreen({
    super.key,
    required this.client,
  });

  @override
  State<CreateContractScreen> createState() => _CreateContractScreenState();
}

class _CreateContractScreenState extends State<CreateContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contractService = ContractService();

  final _descriptionController = TextEditingController();
  final _assignedUserController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  File? _selectedFile;
  String? _selectedFileName;

  bool _isSaving = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
      });
    }
  }

  Future<String?> _saveFileLocally(File file) async {
    final directory = await getApplicationDocumentsDirectory();
    final savePath = '${directory.path}/${_selectedFileName ?? 'contrato'}';

    final savedFile = await file.copy(savePath);
    return savedFile.path;
  }

  Future<void> _saveContract() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) return;

    setState(() => _isSaving = true);

    String? savedFilePath;

    if (_selectedFile != null) {
      savedFilePath = await _saveFileLocally(_selectedFile!);
    }

    final now = DateTime.now();

    final contract = Contract(
      id: const Uuid().v4(),
      clientId: widget.client.id,
      clientName: widget.client.companyName,
      description: _descriptionController.text.trim(),
      status: 'active',
      assignedUserId: _assignedUserController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      progressPercentage: 0,
      createdAt: now,
      updatedAt: now,
      fileUrl: savedFilePath,
      fileName: _selectedFileName,
      hasFile: savedFilePath != null,
    );

    await _contractService.add(contract);

    setState(() => _isSaving = false);

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contrato para ${widget.client.companyName}"),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Informações do Contrato",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Descrição
              TextFormField(
                controller: _descriptionController,
                decoration:
                const InputDecoration(labelText: "Descrição"),
                validator: (v) => v == null || v.isEmpty
                    ? "Digite uma descrição"
                    : null,
              ),
              const SizedBox(height: 16),

              // Responsável
              TextFormField(
                controller: _assignedUserController,
                decoration:
                const InputDecoration(labelText: "Responsável"),
                validator: (v) => v == null || v.isEmpty
                    ? "Informe o responsável"
                    : null,
              ),
              const SizedBox(height: 16),

              // Datas
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      label: "Início",
                      value: _startDate,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          initialDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _startDate = date);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDatePicker(
                      label: "Fim",
                      value: _endDate,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          initialDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _endDate = date);
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Upload de arquivo
              Text(
                "Contrato (opcional)",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file),
                label: const Text("Selecionar arquivo"),
              ),

              if (_selectedFileName != null) ...[
                const SizedBox(height: 8),
                Text(
                  "Selecionado: $_selectedFileName",
                  style: const TextStyle(color: ViaColors.primary),
                ),
              ],

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _saveContract,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Salvar Contrato",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: ViaColors.textSecondary.withOpacity(0.4),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          value != null
              ? "${value.day}/${value.month}/${value.year}"
              : label,
          style: TextStyle(
            color:
            value != null ? Colors.black : ViaColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
