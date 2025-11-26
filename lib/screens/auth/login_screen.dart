import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viasolucoes/screens/auth/register_screen.dart';
import 'package:viasolucoes/screens/main_screen.dart';
import 'package:viasolucoes/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Preencha e-mail e senha");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError("Erro inesperado ao entrar");
    }

    setState(() => _isLoading = false);
  }

  void _showError(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: ViaColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),

              // LOGO
              Text(
                "Via Soluções",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: ViaColors.primary,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.2),

              const SizedBox(height: 60),

              // CAMPOS
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "E-mail",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .slideX(begin: -0.2),

              const SizedBox(height: 20),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Senha",
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms)
                  .slideX(begin: -0.2),

              const SizedBox(height: 28),

              // BOTÃO LOGIN
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ViaColors.primary,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  )
                      : const Text("Entrar"),
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms)
                  .scale(begin: const Offset(0.9, 0.9)),

              const SizedBox(height: 24),

              // BOTÃO → CADASTRAR
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text(
                  "Criar conta",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ViaColors.primary,
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
