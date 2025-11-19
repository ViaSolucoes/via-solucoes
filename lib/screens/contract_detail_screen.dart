import 'package:flutter/material.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/services/contract_service.dart';
import 'package:viasolucoes/theme.dart';

// ABAS
import 'tabs/contract_details_tab.dart';
import 'tabs/contract_tasks_tab.dart';
import 'tabs/contract_history_tab.dart';

class ContractDetailScreen extends StatefulWidget {
  final String contractId;

  const ContractDetailScreen({
    super.key,
    required this.contractId,
  });

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen>
    with SingleTickerProviderStateMixin {
  final _contractService = ContractService();

  Contract? _contract;
  bool _isLoading = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadContract();
  }

  Future<void> _loadContract() async {
    setState(() => _isLoading = true);

    final c = await _contractService.getById(widget.contractId);

    setState(() {
      _contract = c;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _contract == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Contrato")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_contract!.clientName),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ViaColors.primary,
          tabs: const [
            Tab(text: "Detalhes", icon: Icon(Icons.description_outlined)),
            Tab(text: "Tarefas", icon: Icon(Icons.checklist)),
            Tab(text: "Histórico", icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ContractDetailsTab(contract: _contract!),
          ContractTasksTab(contract: _contract!),
          ContractHistoryTab(contract: _contract!),
        ],
      ),
    );
  }
}
