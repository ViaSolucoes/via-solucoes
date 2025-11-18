import 'package:flutter/material.dart';
import 'package:viasolucoes/screens/dashboard_screen.dart';
import 'package:viasolucoes/screens/clients_screen.dart';
import 'package:viasolucoes/screens/profile_screen.dart';
import 'package:viasolucoes/services/user_service.dart';
import 'package:viasolucoes/services/contract_service.dart';
import 'package:viasolucoes/services/task_service.dart';
import 'package:viasolucoes/services/client_service.dart';
import 'package:viasolucoes/theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final userService = UserService();
    final contractService = ContractService();
    final taskService = TaskService();
    final clientService = ClientService();

    await userService.initializeSampleData();
    await contractService.initializeSampleData();
    await taskService.initializeSampleData();
    await clientService.initializeSampleData();

    setState(() => _isInitialized = true);
  }

  final List<Widget> _screens = const [
    DashboardScreen(),
    ClientsScreen(),  // ← Contratos agora ficam dentro do cliente
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(child: _screens[_selectedIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: ViaColors.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          indicatorColor: ViaColors.primary.withValues(alpha: 0.15),
          height: 70,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: ViaColors.primary),
              label: 'Início',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_alt_outlined),
              selectedIcon: Icon(Icons.people_alt, color: ViaColors.primary),
              label: 'Clientes',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: ViaColors.primary),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
