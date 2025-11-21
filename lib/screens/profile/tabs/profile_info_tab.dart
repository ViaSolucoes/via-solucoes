import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:viasolucoes/models/user.dart';
import 'package:viasolucoes/services/user_service.dart';
import 'package:viasolucoes/screens/login_screen.dart';
import 'package:viasolucoes/theme.dart';

class ProfileInfoTab extends StatefulWidget {
  const ProfileInfoTab({super.key});

  @override
  State<ProfileInfoTab> createState() => _ProfileInfoTabState();
}

class _ProfileInfoTabState extends State<ProfileInfoTab> {
  final _userService = UserService();
  ViaSolutionsUser? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userId = await _userService.getCurrentUserId();

    if (userId != null) {
      final user = await _userService.getById(userId);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } else {
      // 👇 evita loading infinito
      setState(() {
        _user = null;
        _isLoading = false;
      });
    }
  }
  Future<void> _logout() async {
    await _userService.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_user == null) {
      return Center(
        child: Text(
          "Nenhum usuário encontrado.",
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }
    final bgCard = Theme.of(context).cardColor;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        // FOTO / AVATAR
        Center(
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: ViaColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _user!.name
                    .split(' ')
                    .map((n) => n[0])
                    .take(2)
                    .join()
                    .toUpperCase(),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: ViaColors.primary,
                ),
              ),
            ),
          ).animate().scale(duration: 400.ms, delay: 100.ms),
        ),

        const SizedBox(height: 16),

        // NOME / CARGO
        Text(
          _user!.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _user!.role,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 28),

        // INFORMAÇÕES DO PERFIL
        _sectionTitle("Informações"),
        _infoCard(
          icon: Icons.email_outlined,
          label: 'E-mail',
          value: _user!.email,
        ),
        const SizedBox(height: 12),
        _infoCard(
          icon: Icons.badge_outlined,
          label: 'Função',
          value: _user!.role,
        ),

        const SizedBox(height: 28),

        // CONFIGURAÇÕES
        _sectionTitle("Configurações"),
        _settingCard(Icons.dark_mode_outlined, 'Modo escuro'),
        const SizedBox(height: 12),
        _settingCard(Icons.language_outlined, 'Idioma'),

        const SizedBox(height: 32),

        // LOGOUT
        ElevatedButton.icon(
          onPressed: _logout,
          style: ElevatedButton.styleFrom(
            backgroundColor: ViaColors.error,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.logout),
          label: const Text('Sair'),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _infoCard({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: ViaColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingCard(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w500)),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
