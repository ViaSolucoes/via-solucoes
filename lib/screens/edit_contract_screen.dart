import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:viasolucoes/models/client.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/services/client_service.dart';
import 'package:viasolucoes/theme.dart';

class EditContractScreen extends StatefulWidget {
  final Contract contract;

  const EditContractScreen({
    super.key,
    required this.contract,
  });

  @override
  State<EditContractScreen> createState() => _EditContractScreenState();
}

class _EditContractScreenState extends State<EditContractScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Client> _clients = [];
  Client? _selectedClient;
  bool _loadingClients = true;

  late TextEditingController _descriptionController;
  late TextEditingController _assignedUserController;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();

    _descriptionController =
        TextEditingController(text: widget.contract.description);
    _assignedUserController =
        TextEditingController(text: widget.contract.assignedUserId);

    _startDate = widget.contract.startDate;
    _endDate = widget.contract.endDate;

    _loadClients();
  }

  Future<void> _loadClients() async {
    final clientService = ClientService();
    await clientService.initializeSampleData();
    final allClients = clientService.getClients();

    setState(() {
      _clients = allClients;
      _selectedClient = allClients.firstWhere(
            (c) => c.id == widget.contract.clientId,
        orElse: () => allClients.first,
      );
      _loadingClients = false;
    });
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDate: isStart ? _startDate ?? now : _endDate ?? now,
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate() == false) return;

    if (_selectedClient == null) {
      _showError('Selecione um cliente.');
      return;
    }

    if (_startDate == null || _endDate == null) {
      _showError('Selecione as datas de início e término.');
      return;
    }

    final updated = widget.contract.copyWith(
      clientId: _selectedClient!.id,
      clientName: _selectedClient!.companyName,
      description: _descriptionController.text.trim(),
      assignedUserId: _assignedUserController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      updatedAt: DateTime.now(),
    );

    Navigator.pop(context, updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Contrato atualizado com sucesso!'),
        backgroundColor: ViaColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ViaColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Contrato'),
        centerTitle: true,
      ),
      body: _loadingClients
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Vincular a um cliente',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),

              // 🔽 Dropdown de Clientes
              DropdownButtonFormField<Client>(
                value: _selectedClient,
                items: _clients.map((client) {
                  return DropdownMenuItem(
                    value: client,
                    child: Text(client.companyName),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Cliente',
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedClient = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Selecione um cliente' : null,
              ),

              const SizedBox(height: 24),

              Text(
                'Dados do contrato',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                _descriptionController,
                'Descrição',
                true,
              ),
              _buildTextField(
                _assignedUserController,
                'Usuário responsável (ID)',
                true,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _datePickerTile(
                      label: 'Início',
                      date: _startDate,
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _datePickerTile(
                      label: 'Término',
                      date: _endDate,
                      onTap: () => _pickDate(false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text('Salvar alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      bool required, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return 'Campo obrigatório';
          }
          return null;
        },
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _datePickerTile({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ViaColors.textSecondary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null
                  ? label
                  : '${date.day}/${date.month}/${date.year}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }
}
