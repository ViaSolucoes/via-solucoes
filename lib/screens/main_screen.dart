import 'package:flutter/material.dart';

import 'package:viasolucoes/screens/dashboard_screen.dart';
import 'package:viasolucoes/screens/client/clients_screen.dart';
import 'package:viasolucoes/screens/contracts/contracts_screen.dart';
import 'package:viasolucoes/screens/profile/profile_screen.dart';
import 'package:viasolucoes/theme.dart';

import 'package:viasolucoes/features/assistant/ui/assistant_modal.dart';
import 'package:viasolucoes/features/assistant/ui/assistant_fab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ClientsScreen(),
    ContractsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      // FAB somente na aba Dashboard
      floatingActionButton: _selectedIndex == 0
          ? AssistantFAB(
        onTap: () => showAssistantModal(context),
      )
          : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: ViaColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Clientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Contratos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
