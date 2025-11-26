import 'package:flutter/material.dart';
import 'package:viasolucoes/models/user.dart';
import 'package:viasolucoes/services/supabase/user_auth_service.dart';
import 'package:viasolucoes/services/supabase/user_service_supabase.dart';
import 'package:viasolucoes/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();

  final _auth = UserAuthService();
  final _userService = UserServiceSupabase();

  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passController.text != _confirmController.text) {
      _showError("As senhas não coincidem");
      return;
    }

    setState(() => _loading = true);

    try {
      // 1) Criar usuário no Auth
      final authResponse = await _auth.register(
        _emailController.text.trim(),
        _passController.text.trim(),
      );

      final userId = authResponse?.user?.id;

      if (userId == null) {
        _showError("Erro ao criar usuário");
        setState(() => _loading = false);
        return;
      }

      // 2) Criar perfil na tabela tbdUsuario
      final user = ViaSolutionsUser(
        id: userId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: "Usuário",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _userService.createProfile(user);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Conta criada com sucesso!"),
          backgroundColor: ViaColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      _showError("Erro: $e");
    }

    setState(() => _loading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ViaColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Conta")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nome completo"),
                validator: (v) =>
                v == null || v.isEmpty ? "Informe seu nome" : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "E-mail"),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Informe seu e-mail";
                  if (!v.contains("@")) return "E-mail inválido";
                  return null;
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Senha"),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Informe uma senha";
                  if (v.length < 6)
                    return "A senha deve ter pelo menos 6 caracteres";
                  return null;
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _confirmController,
                obscureText: true,
                decoration:
                const InputDecoration(labelText: "Confirmar senha"),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Cadastrar"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
