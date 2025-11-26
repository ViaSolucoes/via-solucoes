import 'package:flutter/material.dart';
import 'package:viasolucoes/models/client.dart';
import 'package:viasolucoes/services/supabase/client_service_supabase.dart';
import 'package:viasolucoes/theme.dart';

class EditClientScreen extends StatefulWidget {
  final Client client;

  const EditClientScreen({super.key, required this.client});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientService = ClientServiceSupabase();

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

  bool _loading = false;

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

  // ============================================================
  // 🔵 ATUALIZAR CLIENTE NO SUPABASE
  // ============================================================
  Future<void> _updateClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
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

      // 🔥 Atualizar no Supabase
      await _clientService.update(updatedClient);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cliente atualizado com sucesso!'),
          backgroundColor: ViaColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {
      print("❌ Erro ao atualizar cliente: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro ao atualizar cliente.'),
          backgroundColor: ViaColors.error,
        ),
      );
    }

    setState(() => _loading = false);
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ViaColors.primary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _field(
      TextEditingController controller,
      String label, {
        bool required = false,
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
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

  // ============================================================
  // 🔵 UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cliente'),
        centerTitle: false,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionTitle("Dados da Concessionária"),
                _card(
                  Column(
                    children: [
                      _field(_companyNameController, "Nome da Empresa", required: true),
                      _field(_highwayController, "Rodovia", required: true),
                      _field(_cnpjController, "CNPJ", required: true),
                    ],
                  ),
                ),

                _sectionTitle("Informações de Contato"),
                _card(
                  Column(
                    children: [
                      _field(_contactPersonController, "Responsável", required: true),
                      _field(_roleController, "Cargo do Responsável"),
                      _field(_emailController, "E-mail",
                          keyboardType: TextInputType.emailAddress),
                      _field(_phoneController, "Telefone",
                          keyboardType: TextInputType.phone),
                    ],
                  ),
                ),

                _sectionTitle("Dados Complementares"),
                _card(
                  Column(
                    children: [
                      _field(_addressController, "Endereço"),
                      _field(_departmentController, "Setor"),
                      _field(_notesController, "Observações", maxLines: 3),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _updateClient,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text("Salvar Alterações"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(
                child: CircularProgressIndicator(color: ViaColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
