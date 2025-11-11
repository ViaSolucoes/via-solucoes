import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/models/task.dart';
import 'package:viasolucoes/services/contract_service.dart';
import 'package:viasolucoes/services/task_service.dart';
import 'package:viasolucoes/theme.dart';
import 'package:viasolucoes/widgets/task_item.dart';

class ContractDetailScreen extends StatefulWidget {
  final String contractId;

  const ContractDetailScreen({super.key, required this.contractId});

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen>
    with SingleTickerProviderStateMixin {
  final _contractService = ContractService();
  final _taskService = TaskService();
  late TabController _tabController;
  Contract? _contract;
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final contract = await _contractService.getById(widget.contractId);
    final tasks = await _taskService.getByContractId(widget.contractId);
    setState(() {
      _contract = contract;
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Color _getStatusColor() {
    if (_contract == null) return ViaColors.textSecondary;
    switch (_contract!.status) {
      case 'active':
        return ViaColors.secondary;
      case 'overdue':
        return ViaColors.error;
      case 'completed':
        return ViaColors.success;
      default:
        return ViaColors.textSecondary;
    }
  }

  String _getStatusLabel() {
    if (_contract == null) return '';
    switch (_contract!.status) {
      case 'active':
        return 'Ativo';
      case 'overdue':
        return 'Atrasado';
      case 'completed':
        return 'Concluído';
      default:
        return _contract!.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _contract == null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Contrato'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ViaColors.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _contract!.clientName,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusLabel(),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: _getStatusColor(),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 12),
                Text(
                  _contract!.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ViaColors.textSecondary,
                  ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: ViaColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Início: ${DateFormat('dd/MM/yyyy').format(_contract!.startDate)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 20),
                    Icon(
                      Icons.event_outlined,
                      size: 16,
                      color: ViaColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Fim: ${DateFormat('dd/MM/yyyy').format(_contract!.endDate)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progresso',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          '${_contract!.progressPercentage.toInt()}%',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: ViaColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _contract!.progressPercentage / 100,
                        minHeight: 8,
                        backgroundColor: ViaColors.textSecondary.withValues(
                          alpha: 0.2,
                        ),
                        valueColor: AlwaysStoppedAnimation(_getStatusColor()),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: ViaColors.primary,
            labelColor: ViaColors.primary,
            unselectedLabelColor: ViaColors.textSecondary,
            tabs: const [
              Tab(text: 'Resumo'),
              Tab(text: 'Tarefas'),
              Tab(text: 'Histórico'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(),
                _buildTasksTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildInfoCard('Cliente', _contract!.clientName),
        const SizedBox(height: 12),
        _buildInfoCard('Status', _getStatusLabel()),
        const SizedBox(height: 12),
        _buildInfoCard(
          'Período',
          '${DateFormat('dd/MM/yyyy').format(_contract!.startDate)} - ${DateFormat('dd/MM/yyyy').format(_contract!.endDate)}',
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          'Progresso',
          '${_contract!.progressPercentage.toInt()}%',
        ),
      ],
    );
  }

  Widget _buildTasksTab() {
    if (_tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_outlined, size: 64, color: ViaColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Nenhuma tarefa vinculada',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: ViaColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TaskItem(
            task: _tasks[index],
          ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.2),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: ViaColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Histórico em breve',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: ViaColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
