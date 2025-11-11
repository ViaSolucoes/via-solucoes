import 'package:flutter/material.dart';
import 'package:viasolucoes/models/client.dart';
import 'package:viasolucoes/theme.dart';

class EditClientScreen extends StatefulWidget {
  final Client client;

  const EditClientScreen({super.key, required this.client});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _companyNameController;
  late TextEditingController _highwayController;
  late TextEditingController _cnpjController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _contactPersonController;
  late TextEditingController _roleController;
  late TextEditingController _addressController;
  late TextEditingController _departmentController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController(text: widget.client.companyName);
    _highwayController = TextEditingController(text: widget.client.highway);
    _cnpjController = TextEditingController(text: widget.client.cnpj);
    _emailController = TextEditingController(text: widget.client.email);
    _phoneController = TextEditingController(text: widget.client.phone);
    _contactPersonController = TextEditingController(text: widget.client.contactPerson);
    _roleController = TextEditingController(text: widget.client.contactRole);
    _addressController = TextEditingController(text: widget.client.address);
    _departmentController = TextEditingController(text: widget.client.department);
    _notesController = TextEditingController(text: widget.client.notes);
  }

  void _updateClient() {
    if (_formKey.currentState!.validate()) {
      final updatedClient = widget.client.copyWith(
        companyName: _companyNameController.text.trim(),
        highway: _highwayController.text.trim(),
        cnpj: _cnpjController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        contactRole: _roleController.text.trim(),
        address: _addressController.text.trim(),
        department: _departmentController.text.trim(),
        notes: _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      Navigator.pop(context, updatedClient);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cliente atualizado com sucesso!'),
          backgroundColor: ViaColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cliente'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Atualize os dados do cliente:',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              _buildTextField(_companyNameController, 'Nome da Empresa', true),
              _buildTextField(_highwayController, 'Rodovia', true),
              _buildTextField(_cnpjController, 'CNPJ', true),
              _buildTextField(_emailController, 'E-mail', false, keyboardType: TextInputType.emailAddress),
              _buildTextField(_phoneController, 'Telefone', false, keyboardType: TextInputType.phone),
              _buildTextField(_contactPersonController, 'Responsável', true),
              _buildTextField(_roleController, 'Cargo do Responsável', false),
              _buildTextField(_addressController, 'Endereço', false),
              _buildTextField(_departmentController, 'Setor', false),
              _buildTextField(_notesController, 'Observações', false, maxLines: 3),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _updateClient,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Alterações'),
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
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return 'Campo obrigatório';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Digite $label',
        ),
      ),
    );
  }
}
