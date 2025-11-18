import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:viasolucoes/models/client.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/services/contract_service.dart';
import 'package:viasolucoes/screens/contract_detail_screen.dart';
import 'package:viasolucoes/screens/create_contract_screen.dart';
import 'package:viasolucoes/theme.dart';
import 'package:viasolucoes/widgets/contract_card.dart';

class ContractsScreen extends StatefulWidget {
  final Client client;

  const ContractsScreen({super.key, required this.client});

  @override
  State<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen> {
  final _contractService = ContractService();
  List<Contract> _contracts = [];
  List<Contract> _filteredContracts = [];

  String _selectedFilter = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContracts();
  }

  Future<void> _loadContracts() async {
    setState(() => _isLoading = true);

    final all = await _contractService.getAll();

    // Apenas contratos do cliente atual
    _contracts = all.where((c) => c.clientId == widget.client.id).toList();

    _applyFilter();

    setState(() => _isLoading = false);
  }

  void _applyFilter() {
    switch (_selectedFilter) {
      case 'active':
        _filteredContracts =
            _contracts.where((c) => c.status == 'active').toList();
        break;
      case 'overdue':
        _filteredContracts =
            _contracts.where((c) => c.status == 'overdue').toList();
        break;
      case 'completed':
        _filteredContracts =
            _contracts.where((c) => c.status == 'completed').toList();
        break;
      default:
        _filteredContracts = _contracts;
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilter();
    });
  }

  Future<void> _createNewContract() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateContractScreen(
          client: widget.client,
        ),
      ),
    );

    if (result == true) {
      await _loadContracts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contratos - ${widget.client.companyName}'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewContract,
        backgroundColor: ViaColors.primary,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Filtros
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Todos'),
                  selected: _selectedFilter == 'all',
                  onSelected: (_) => _onFilterChanged('all'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Ativos'),
                  selected: _selectedFilter == 'active',
                  onSelected: (_) => _onFilterChanged('active'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Atrasados'),
                  selected: _selectedFilter == 'overdue',
                  onSelected: (_) => _onFilterChanged('overdue'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Concluídos'),
                  selected: _selectedFilter == 'completed',
                  onSelected: (_) => _onFilterChanged('completed'),
                ),
              ],
            ),
          ),

          // Lista
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredContracts.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 60,
                    color: ViaColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Nenhum contrato encontrado",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: ViaColors.textSecondary),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadContracts,
              child: ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filteredContracts.length,
                itemBuilder: (_, index) {
                  final contract = _filteredContracts[index];

                  return ContractCard(
                    contract: contract,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContractDetailScreen(
                          contractId: contract.id,
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (index * 60).ms)
                      .slideX(begin: 0.15);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
