import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:viasolucoes/models/client.dart';
import 'package:viasolucoes/theme.dart';

class CreateClientScreen extends StatefulWidget {
  const CreateClientScreen({super.key});

  @override
  State<CreateClientScreen> createState() => _CreateClientScreenState();
}

class _CreateClientScreenState extends State<CreateClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  final _companyNameController = TextEditingController();
  final _highwayController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _roleController = TextEditingController();
  final _addressController = TextEditingController();
  final _departmentController = TextEditingController();
  final _notesController = TextEditingController();

  void _saveClient() {
    if (_formKey.currentState!.validate()) {
      final client = Client(
        id: _uuid.v4(),
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
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Navigator.pop(context, client);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cliente cadastrado com sucesso!'),
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
        title: const Text('Cadastrar Cliente'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Preencha os dados do cliente:',
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
                onPressed: _saveClient,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Cliente'),
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
