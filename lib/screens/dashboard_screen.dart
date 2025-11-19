import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/models/task.dart';
import 'package:viasolucoes/services/contract_service.dart';
import 'package:viasolucoes/services/task_service.dart';
import 'package:viasolucoes/theme.dart';
import 'package:viasolucoes/widgets/stat_card.dart';
import 'package:viasolucoes/widgets/quick_action_button.dart';
import 'package:viasolucoes/widgets/recent_contract_item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _contractService = ContractService();
  final _taskService = TaskService();
  Map<String, int> _stats = {};
  List<Contract> _recentContracts = [];
  int _pendingTasks = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final stats = await _contractService.getStats();
    final contracts = await _contractService.getAll();
    final tasks = await _taskService.getAll();

    setState(() {
      _stats = stats;
      _recentContracts = contracts.take(3).toList();
      _pendingTasks = tasks.length; // ← corrigido
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Bem-vindo de volta',
            style: Theme.of(context).textTheme.titleMedium,
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 4),
          Text(
            'Visão Geral',
            style: Theme.of(context).textTheme.displaySmall,
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Ativos',
                  value: _stats['active']?.toString() ?? '0',
                  color: ViaColors.secondary,
                  icon: Icons.work_outline,
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Atrasados',
                  value: _stats['overdue']?.toString() ?? '0',
                  color: ViaColors.error,
                  icon: Icons.warning_amber_outlined,
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Concluídos',
                  value: _stats['completed']?.toString() ?? '0',
                  color: ViaColors.success,
                  icon: Icons.check_circle_outline,
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Tarefas',
                  value: _pendingTasks.toString(),
                  color: ViaColors.accent,
                  icon: Icons.task_outlined,
                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Ações Rápidas',
            style: Theme.of(context).textTheme.titleLarge,
          ).animate().fadeIn(delay: 600.ms),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: QuickActionButton(
                  label: 'Novo Contrato',
                  icon: Icons.add_circle_outline,
                  color: ViaColors.primary,
                  onTap: () {},
                ).animate().fadeIn(delay: 700.ms).scale(begin: const Offset(0.8, 0.8)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionButton(
                  label: 'Nova Tarefa',
                  icon: Icons.task_alt,
                  color: ViaColors.accent,
                  onTap: () {},
                ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.8, 0.8)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Contratos Recentes',
            style: Theme.of(context).textTheme.titleLarge,
          ).animate().fadeIn(delay: 900.ms),
          const SizedBox(height: 16),
          ..._recentContracts.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RecentContractItem(contract: entry.value)
                  .animate()
                  .fadeIn(delay: (1000 + entry.key * 100).ms)
                  .slideX(begin: 0.3),
            );
          }),
        ],
      ),
    );
  }
}
