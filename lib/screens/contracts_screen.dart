import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/services/contract_service.dart';
import 'package:viasolucoes/screens/contract_detail_screen.dart';
import 'package:viasolucoes/screens/create_contract_screen.dart';
import 'package:viasolucoes/theme.dart';
import 'package:viasolucoes/widgets/contract_card.dart';

class ContractsScreen extends StatefulWidget {
  const ContractsScreen({super.key});

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
    final contracts = await _contractService.getAll();
    setState(() {
      _contracts = contracts;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    if (_selectedFilter == 'all') {
      _filteredContracts = _contracts;
    } else {
      _filteredContracts = _contracts
          .where((c) => c.status == _selectedFilter)
          .toList();
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
      MaterialPageRoute(builder: (context) => const CreateContractScreen()),
    );

    if (result == true) {
      _loadContracts(); // Recarregar lista após criar contrato
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Contratos',
                    style: Theme.of(context).textTheme.displaySmall,
                  ).animate().fadeIn(duration: 400.ms),
                  ElevatedButton.icon(
                    onPressed: _createNewContract,
                    icon: const Icon(Icons.add),
                    label: const Text('Novo Contrato'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ViaColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
                ).animate().fadeIn(delay: 200.ms),
              ),
            ],
          ),
        ),
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
                        size: 64,
                        color: ViaColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum contrato encontrado',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: ViaColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadContracts,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredContracts.length,
                    itemBuilder: (context, index) {
                      final contract = _filteredContracts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child:
                            ContractCard(
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
                                .fadeIn(delay: (index * 50).ms)
                                .slideX(begin: 0.2),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
