import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/screens/contracts/tabs/contract_details_tab.dart';
import 'package:viasolucoes/screens/contracts/tabs/contract_tasks_tab.dart';

class ContractDetailScreen extends StatefulWidget {
  final Contract contract;

  const ContractDetailScreen({
    super.key,
    required this.contract,
  });

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _formatter = DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.blueAccent;
      case 'overdue':
        return Colors.orangeAccent;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Ativo';
      case 'overdue':
        return 'Atrasado';
      case 'completed':
        return 'Concluído';
      default:
        return 'Indefinido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.contract;
    final statusColor = _statusColor(c.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F5F7),
        elevation: 0,
        title: const Text(
          "Detalhes do Contrato",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            alignment: Alignment.center,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.blueAccent,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey.shade600,
              tabs: const [
                Tab(text: "Detalhes"),
                Tab(text: "Tarefas"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ContractDetailsTab(contract: c),
          ContractTasksTab(contract: c),
        ],
      ),
    );
  }
}
