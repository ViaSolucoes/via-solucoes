import 'package:flutter/material.dart';
import 'package:viaflow/screens/dashboard_screen.dart';
import 'package:viaflow/screens/contracts_screen.dart';
import 'package:viaflow/screens/notifications_screen.dart';
import 'package:viaflow/screens/profile_screen.dart';
import 'package:viaflow/services/user_service.dart';
import 'package:viaflow/services/contract_service.dart';
import 'package:viaflow/services/task_service.dart';
import 'package:viaflow/services/notification_service.dart';
import 'package:viaflow/theme.dart';

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
    final notificationService = NotificationService();

    await userService.initializeSampleData();
    await contractService.initializeSampleData();
    await taskService.initializeSampleData();

    final userId = await userService.getCurrentUserId();
    if (userId != null) {
      await notificationService.initializeSampleData(userId);
    }

    setState(() => _isInitialized = true);
  }

  final List<Widget> _screens = const [
    DashboardScreen(),
    ContractsScreen(),
    NotificationsScreen(),
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
              icon: Icon(Icons.folder_outlined),
              selectedIcon: Icon(Icons.folder, color: ViaColors.primary),
              label: 'Contratos',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications, color: ViaColors.primary),
              label: 'Notificações',
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
