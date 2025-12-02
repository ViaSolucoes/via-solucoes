import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/screens/contracts/contract_detail_screen.dart';
import 'package:viasolucoes/screens/contracts/create_contract_screen.dart';
import 'package:viasolucoes/screens/contracts/edit_contract_screen.dart';
import 'package:viasolucoes/services/supabase/contract_service_supabase.dart';
import 'package:viasolucoes/theme.dart';

enum ContractFilter { all, active, overdue, completed }

class ContractsScreen extends StatefulWidget {
  const ContractsScreen({super.key});

  @override
  State<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen> {
  final _contractService = ContractServiceSupabase();
  final TextEditingController _searchController = TextEditingController();

  List<Contract> _contracts = [];
  List<Contract> _filteredContracts = [];

  ContractFilter _selectedFilter = ContractFilter.all;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContracts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // CARREGAR CONTRATOS
  // ============================================================
  Future<void> _loadContracts() async {
    setState(() => _isLoading = true);

    try {
      final all = await _contractService.getAll();

      all.sort((a, b) => a.endDate.compareTo(b.endDate));

      _contracts = all;
      _applyFilter();
    } catch (e) {
      print('❌ Erro ao carregar contratos: $e');
    }

    setState(() => _isLoading = false);
  }

  // ============================================================
  // FILTRAGEM USANDO computedStatus
  // ============================================================
  void _applyFilter() {
    List<Contract> filtered = _contracts;

    switch (_selectedFilter) {
      case ContractFilter.active:
        filtered = filtered.where((c) => c.computedStatus == 'active').toList();
        break;
      case ContractFilter.overdue:
        filtered = filtered.where((c) => c.computedStatus == 'overdue').toList();
        break;
      case ContractFilter.completed:
        filtered = filtered.where((c) => c.computedStatus == 'completed').toList();
        break;
      case ContractFilter.all:
        break;
    }

    // Busca
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((c) {
        return c.clientName.toLowerCase().contains(query) ||
            c.description.toLowerCase().contains(query);
      }).toList();
    }

    setState(() => _filteredContracts = filtered);
  }

  void _onFilterChanged(ContractFilter filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilter();
    });
  }

  void _onSearchChanged(String value) {
    _applyFilter();
  }

  Future<void> _createNewContract() async {
    final saved = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateContractScreen()),
    );
    if (saved == true) {
      await _loadContracts();
    }
  }

  // ============================================================
  // CORES E LABELS DO STATUS
  // ============================================================
  Color _getStatusColor(String status) {
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

  String _getStatusLabel(String status) {
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

  String _filterLabel(ContractFilter filter) {
    switch (filter) {
      case ContractFilter.all:
        return 'Todos';
      case ContractFilter.active:
        return 'Ativos';
      case ContractFilter.overdue:
        return 'Atrasados';
      case ContractFilter.completed:
        return 'Concluídos';
    }
  }

  // ============================================================
  // UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final background = const Color(0xFFF4F5F7);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        titleSpacing: 20,
        title: Text(
          'Todos os Contratos (${_filteredContracts.length})',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButton: _buildFab(),
      body: Column(
        children: [
          // Busca
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: 'Buscar contrato...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                ),
              ),
            ),
          ),

          // Filtros
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: _buildFiltersRow(),
          ),

          // Lista
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredContracts.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhum contrato encontrado.',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadContracts,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
                          itemCount: _filteredContracts.length,
                          itemBuilder: (context, index) {
                            final contract = _filteredContracts[index];
                            return _buildContractCard(contract, index);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPONENTES
  // ============================================================

  Widget _buildFiltersRow() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ContractFilter.values.map((filter) {
          final bool selected = _selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onFilterChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? ViaColors.primary.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: Text(
                    _filterLabel(filter),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? ViaColors.primary : ViaColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContractCard(Contract contract, int index) {
    final status = contract.computedStatus;
    final statusColor = _getStatusColor(status);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ContractDetailScreen(contract: contract),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    contract.clientName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit_rounded,
                    size: 20,
                    color: Colors.blueAccent,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditContractScreen(contract: contract),
                      ),
                    );
                    if (updated == true) {
                      _loadContracts();
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Descrição
            Text(
              contract.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ViaColors.textSecondary,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 12),

            // Data + Status
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: 6),
                Text(
                  '${contract.endDate.day.toString().padLeft(2, '0')}/${contract.endDate.month.toString().padLeft(2, '0')}/${contract.endDate.year}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                Text(
                  _getStatusLabel(status),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: statusColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Barra de progresso
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (contract.progressPercentage / 100)
                          .clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation(
                        contract.progressPercentage >= 100
                            ? Colors.green
                            : ViaColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${contract.progressPercentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: contract.progressPercentage >= 100
                        ? Colors.green
                        : ViaColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 70).ms)
        .slideY(begin: 0.2);
  }

  Widget _buildFab() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4, right: 2),
      child: FloatingActionButton(
        onPressed: _createNewContract,
        backgroundColor: ViaColors.primary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.add_rounded, size: 26),
      ),
    );
  }
}
