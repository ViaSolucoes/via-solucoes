import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  late TextEditingController _webhookController;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ---------------------------------------------------------
  // 🔵 CARREGA PERFIL DO SUPABASE
  // ---------------------------------------------------------
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
      _webhookController = TextEditingController(text: user?.webhookUrl ?? "");
      _loading = false;
    });
  }

  // ---------------------------------------------------------
  // 🔵 SALVAR PERFIL
  // ---------------------------------------------------------
  Future<void> _save() async {
    if (_user == null) return;

    setState(() => _loading = true);

    final updated = _user!.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      webhookUrl: _webhookController.text.trim(),
      updatedAt: DateTime.now(),
    );

    await _userService.updateProfile(updated);

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Perfil atualizado com sucesso!")),
    );

    _loadUser(); // recarrega
  }

  // ---------------------------------------------------------
  // 🔵 TESTAR WEBHOOK
  // ---------------------------------------------------------
  Future<void> _testWebhook() async {
    final url = _webhookController.text.trim();

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Digite o webhook primeiro."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Exibir loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "event": "webhook_test",
          "message": "Webhook funcionando!",
          "timestamp": DateTime.now().toIso8601String(),
        }),
      );

      Navigator.pop(context); // fecha loading

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Webhook conectado com sucesso!"),
            backgroundColor: Colors.green.shade600,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ${response.statusCode}: resposta inválida."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Falha ao conectar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ---------------------------------------------------------
  // 🔵 UI
  // ---------------------------------------------------------
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
          const Text(
            "Informações do Perfil",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),

          _buildInput("Nome", _nameController),
          const SizedBox(height: 18),

          _buildInput("Telefone", _phoneController),
          const SizedBox(height: 18),

          _buildInput("Endereço", _addressController),
          const SizedBox(height: 18),

          _buildWebhookField(),
          const SizedBox(height: 25),

          _buildInfoCard(_user!),
          const SizedBox(height: 32),

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

  // ---------------------------------------------------------
  // CAMPOS UI
  // ---------------------------------------------------------

  Widget _buildWebhookField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("URL do Webhook"),
        const SizedBox(height: 6),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _webhookController,
                decoration: InputDecoration(
                  hintText: "https://meu-webhook.com/api",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            ElevatedButton(
              onPressed: _testWebhook,
              style: ElevatedButton.styleFrom(
                backgroundColor: ViaColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text("Testar"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController controller,
      {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
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
