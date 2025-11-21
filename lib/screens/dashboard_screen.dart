import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/services/contract_service.dart';
import 'package:viasolucoes/services/task_service.dart';
import 'package:viasolucoes/theme.dart';
import 'package:viasolucoes/screens/contracts/create_contract_screen.dart';
import 'package:viasolucoes/screens/tasks/create_task_screen.dart';

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
  int _completedTasks = 0;
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

    // Ordena contratos mais recentes primeiro
    contracts.sort((a, b) => b.endDate.compareTo(a.endDate));

    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final pendingTasks = tasks.length - completedTasks;

    setState(() {
      _stats = stats;
      _recentContracts = contracts.take(3).toList();
      _pendingTasks = pendingTasks;
      _completedTasks = completedTasks;
      _isLoading = false;
    });
  }

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

  // =====================================================================
  // 🔵 BOTTOM SHEET → Selecionar Contrato antes de Criar Tarefa
  // =====================================================================
  Future<void> _selectContractForTask() async {
    final contracts = await _contractService.getAll();

    if (contracts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nenhum contrato encontrado.")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.85,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          builder: (_, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                const Text(
                  "Selecione um contrato",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),

                ...contracts.map((c) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      title: Text(
                        c.clientName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(c.description),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(context); // Fecha o bottom sheet

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateTaskScreen(
                              contractId: c.id,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF4F5F7);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: bg,
      child: RefreshIndicator(
        onRefresh: _loadData,
        displacement: 30,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            // HEADER
            Text(
              'Bem-vindo de volta',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 4),
            Text(
              'Visão Geral',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // KPIs
            Row(
              children: [
                Expanded(
                  child: StatCardPremium(
                    title: 'Ativos',
                    value: _stats['active']?.toString() ?? '0',
                    subtitle: 'Em andamento',
                    color: ViaColors.secondary,
                    icon: Icons.work_outline,
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCardPremium(
                    title: 'Atrasados',
                    value: _stats['overdue']?.toString() ?? '0',
                    subtitle: 'Exigem atenção',
                    color: ViaColors.error,
                    icon: Icons.warning_amber_outlined,
                  ).animate().fadeIn(delay: 260.ms).slideX(begin: -0.2),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: StatCardPremium(
                    title: 'Concluídos',
                    value: _stats['completed']?.toString() ?? '0',
                    subtitle: 'Encerrados',
                    color: ViaColors.success,
                    icon: Icons.check_circle_outline,
                  ).animate().fadeIn(delay: 320.ms).slideX(begin: -0.2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCardPremium(
                    title: 'Tarefas',
                    value: _pendingTasks.toString(),
                    subtitle: '$_completedTasks concluídas',
                    color: ViaColors.accent,
                    icon: Icons.task_outlined,
                  ).animate().fadeIn(delay: 380.ms).slideX(begin: -0.2),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // AÇÕES RÁPIDAS
            Text(
              'Ações Rápidas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: QuickActionButtonPremium(
                    label: 'Novo Contrato',
                    icon: Icons.add_circle_outline,
                    color: ViaColors.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateContractScreen(),
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: 480.ms).scale(begin: const Offset(0.9, 0.9)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuickActionButtonPremium(
                    label: 'Nova Tarefa',
                    icon: Icons.task_alt,
                    color: ViaColors.accent,
                    onTap: _selectContractForTask,
                  ).animate().fadeIn(delay: 540.ms).scale(begin: const Offset(0.9, 0.9)),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // CONTRATOS RECENTES
            Text(
              'Contratos Recentes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            if (_recentContracts.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'Nenhum contrato recente.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ).animate().fadeIn(delay: 620.ms),

            ..._recentContracts.asMap().entries.map((entry) {
              final index = entry.key;
              final contract = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RecentContractCardPremium(
                  contract: contract,
                  statusColor: _getStatusColor(contract.status),
                  statusLabel: _getStatusLabel(contract.status),
                ).animate().fadeIn(delay: (650 + index * 100).ms).slideX(begin: 0.25),
              );
            }),
          ],
        ),
      ),
    );
  }
}



// ======================================================================
// WIDGETS PREMIUM
// ======================================================================

class StatCardPremium extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Color color;
  final IconData icon;

  const StatCardPremium({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone redondo
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class QuickActionButtonPremium extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionButtonPremium({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}




class RecentContractCardPremium extends StatelessWidget {
  final Contract contract;
  final Color statusColor;
  final String statusLabel;

  const RecentContractCardPremium({
    super.key,
    required this.contract,
    required this.statusColor,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');
    final dateStr = formatter.format(contract.endDate);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: título + status
          Row(
            children: [
              Expanded(
                child: Text(
                  contract.clientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),

              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            contract.description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progresso
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value:
                    (contract.progressPercentage / 100).clamp(0.0, 1.0),
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
    );
  }
}
