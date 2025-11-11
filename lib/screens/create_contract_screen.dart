import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/services/contract_service.dart';
import 'package:viasolucoes/theme.dart';

class CreateContractScreen extends StatefulWidget {
  const CreateContractScreen({super.key});

  @override
  State<CreateContractScreen> createState() => _CreateContractScreenState();
}

class _CreateContractScreenState extends State<CreateContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contractService = ContractService();

  final _nomeController = TextEditingController();
  final _clienteController = TextEditingController();
  final _responsavelController = TextEditingController();
  final _prazoController = TextEditingController();
  final _descricaoController = TextEditingController();

  PlatformFile? _selectedFile;
  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nomeController.dispose();
    _clienteController.dispose();
    _responsavelController.dispose();
    _prazoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar arquivo: \$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: ViaColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _prazoController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '\$bytes B';
    if (bytes < 1024 * 1024) return '\${(bytes / 1024).toStringAsFixed(1)} KB';
    return '\${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get _canSave =>
      _formKey.currentState?.validate() == true &&
      _selectedFile != null &&
      !_isLoading;

  Future<void> _saveContract() async {
    if (!_canSave) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Criar novo contrato
      final contract = Contract(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        clientName: _clienteController.text.trim(),
        description:
            '${_nomeController.text.trim()}: ${_descricaoController.text.trim()}',
        status: 'draft',
        assignedUserId: _responsavelController.text.trim(),
        startDate: DateTime.now(),
        endDate: _selectedDate!,
        progressPercentage: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Salvar contrato (em produção, aqui seria enviado o arquivo junto)
      await _contractService.createContract(contract);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Contrato "\${_nomeController.text}" criado com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar contrato: \$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Contrato'),
        elevation: 0,
        backgroundColor: ViaColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _canSave ? _saveContract : null,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Salvar',
                    style: TextStyle(
                      color: _canSave ? Colors.white : Colors.white54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nome do Contrato
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informações Gerais',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome do Contrato *',
                          hintText: 'Ex: Pavimentação Rua Principal',
                          prefixIcon: Icon(Icons.description),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nome do contrato é obrigatório';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _clienteController,
                        decoration: const InputDecoration(
                          labelText: 'Cliente *',
                          hintText: 'Ex: Prefeitura Municipal',
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Cliente é obrigatório';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _responsavelController,
                        decoration: const InputDecoration(
                          labelText: 'Responsável *',
                          hintText: 'Ex: João Silva',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Responsável é obrigatório';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _prazoController,
                        decoration: const InputDecoration(
                          labelText: 'Prazo *',
                          hintText: 'Selecione a data limite',
                          prefixIcon: Icon(Icons.calendar_today),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        readOnly: true,
                        onTap: _selectDate,
                        validator: (value) {
                          if (_selectedDate == null) {
                            return 'Prazo é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descricaoController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          hintText: 'Descreva os detalhes do contrato...',
                          prefixIcon: Icon(Icons.notes),
                        ),
                        maxLines: 3,
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Upload de Arquivo
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Documento do Contrato',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Anexe o documento do contrato (PDF ou DOCX)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Área de upload
                      InkWell(
                        onTap: _pickFile,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedFile != null
                                  ? ViaColors.success
                                  : Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.3),
                              width: 2,
                              style: _selectedFile != null
                                  ? BorderStyle.solid
                                  : BorderStyle.none,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: _selectedFile != null
                                ? ViaColors.success.withValues(alpha: 0.1)
                                : (isDark
                                      ? Colors.grey.withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.05)),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _selectedFile != null
                                    ? Icons.check_circle
                                    : Icons.cloud_upload_outlined,
                                size: 48,
                                color: _selectedFile != null
                                    ? ViaColors.success
                                    : Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 12),
                              if (_selectedFile != null) ...[
                                Text(
                                  _selectedFile!.name,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: ViaColors.success,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatFileSize(_selectedFile!.size),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: ViaColors.success),
                                ),
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: _pickFile,
                                  icon: const Icon(Icons.swap_horiz),
                                  label: const Text('Alterar arquivo'),
                                ),
                              ] else ...[
                                Text(
                                  'Toque para selecionar arquivo',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'PDF ou DOCX • Máximo 50MB',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      if (_selectedFile == null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ViaColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: ViaColors.accent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: ViaColors.accent,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'O documento é obrigatório para salvar o contrato',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: ViaColors.accent),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
