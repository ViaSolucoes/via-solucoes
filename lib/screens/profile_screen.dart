import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:viasolucoes/models/user.dart';
import 'package:viasolucoes/services/user_service.dart';
import 'package:viasolucoes/screens/login_screen.dart';
import 'package:viasolucoes/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userService = UserService();
  ViaSolutionsUser? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    final userId = await _userService.getCurrentUserId();
    if (userId != null) {
      final user = await _userService.getById(userId);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _userService.logout();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Perfil',
          style: Theme.of(context).textTheme.displaySmall,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 32),
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: ViaColors.primary.withValues(alpha: 0.15),
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
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: ViaColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ).animate().scale(duration: 400.ms, delay: 100.ms),
        ),
        const SizedBox(height: 16),
        Text(
          _user!.name,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 4),
        Text(
          _user!.role,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: ViaColors.textSecondary),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 32),
        _buildProfileItem(Icons.email_outlined, 'E-mail', _user!.email, 0),
        const SizedBox(height: 12),
        _buildProfileItem(Icons.badge_outlined, 'Função', _user!.role, 1),
        const SizedBox(height: 32),
        Text(
          'Configurações',
          style: Theme.of(context).textTheme.titleLarge,
        ).animate().fadeIn(delay: 600.ms),
        const SizedBox(height: 16),
        _buildSettingItem(Icons.dark_mode_outlined, 'Modo escuro', 2),
        const SizedBox(height: 12),
        _buildSettingItem(Icons.notifications_outlined, 'Notificações', 3),
        const SizedBox(height: 12),
        _buildSettingItem(Icons.language_outlined, 'Idioma', 4),
        const SizedBox(height: 32),
        SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ViaColors.error,
                  foregroundColor: ViaColors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout),
                    const SizedBox(width: 8),
                    const Text('Sair'),
                  ],
                ),
              ),
            )
            .animate()
            .fadeIn(delay: 800.ms)
            .scale(begin: const Offset(0.95, 0.95)),
      ],
    );
  }

  Widget _buildProfileItem(
    IconData icon,
    String label,
    String value,
    int index,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ViaColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: ViaColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: ((400 + index * 100)).ms).slideX(begin: 0.2);
  }

  Widget _buildSettingItem(IconData icon, String label, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: ViaColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Icon(Icons.chevron_right, color: ViaColors.textSecondary),
        ],
      ),
    ).animate().fadeIn(delay: ((700 + index * 50)).ms).slideX(begin: 0.2);
  }
}
