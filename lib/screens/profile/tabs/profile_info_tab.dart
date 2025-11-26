import 'package:flutter/material.dart';
import 'package:viasolucoes/models/user.dart';
import 'package:viasolucoes/services/supabase/user_service_supabase.dart';
import 'package:viasolucoes/services/supabase/user_auth_service.dart';
import 'package:viasolucoes/theme.dart';

class ProfileInfoTab extends StatefulWidget {
  const ProfileInfoTab({super.key});

  @override
  State<ProfileInfoTab> createState() => _ProfileInfoTabState();
}

class _ProfileInfoTabState extends State<ProfileInfoTab> {
  final _auth = UserAuthService();
  final _userService = UserServiceSupabase();

  ViaSolutionsUser? _user;
  bool _loading = true;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final id = _auth.getCurrentUserId();

    if (id == null) {
      setState(() => _loading = false);
      return;
    }

    final user = await _userService.getProfile(id);

    setState(() {
      _user = user;
      _nameController = TextEditingController(text: user?.name ?? "");
      _phoneController = TextEditingController(text: user?.phone ?? "");
      _addressController = TextEditingController(text: user?.address ?? "");
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_user == null) return;

    setState(() => _loading = true);

    final updated = _user!.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      updatedAt: DateTime.now(),
    );

    await _userService.updateProfile(updated);

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Perfil atualizado com sucesso!")),
    );

    _loadUser(); // recarrega os dados
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_user == null) {
      return const Center(child: Text("Usuário não encontrado."));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TÍTULO
          const Text(
            "Informações do Perfil",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),

          // CAMPOS EDITÁVEIS
          _buildInput("Nome", _nameController),
          const SizedBox(height: 18),

          _buildInput("Telefone", _phoneController),
          const SizedBox(height: 18),

          _buildInput("Endereço", _addressController),
          const SizedBox(height: 25),

          // INFO NÃO EDITÁVEL
          _buildInfoCard(_user!),

          const SizedBox(height: 32),

          // BOTÃO SALVAR
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text("Salvar alterações"),
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
    );
  }

  // ----------------------------------------------------------------------
  // COMPONENTES DE UI
  // ----------------------------------------------------------------------

  Widget _buildInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(ViaSolutionsUser user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("E-mail"),
          Text(user.email, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 14),

          _label("Função"),
          Text(user.role, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}
