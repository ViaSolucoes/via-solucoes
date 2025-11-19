import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:viasolucoes/models/log_entry.dart';
import 'package:viasolucoes/services/log_service.dart';
import 'package:viasolucoes/theme.dart';

class ContractHistoryScreen extends StatefulWidget {
  final String contractId;

  const ContractHistoryScreen({super.key, required this.contractId});

  @override
  State<ContractHistoryScreen> createState() => _ContractHistoryScreenState();
}

class _ContractHistoryScreenState extends State<ContractHistoryScreen> {
  final _logService = LogService();
  List<LogEntry> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    final logs = await _logService.getByContract(widget.contractId);

    // Ordenar do mais novo para o mais antigo
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    setState(() {
      _logs = logs;
      _isLoading = false;
    });
  }

  IconData _getIcon(String action) {
    switch (action) {
      case 'create':
        return Icons.add_circle_outline;
      case 'update':
        return Icons.edit_outlined;
      case 'view':
        return Icons.visibility_outlined;
      case 'task_done':
        return Icons.check_circle_outline;
      case 'file_open':
        return Icons.description_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _getColor(String action) {
    switch (action) {
      case 'create':
        return ViaColors.primary;
      case 'update':
        return ViaColors.accent;
      case 'view':
        return ViaColors.textSecondary;
      case 'task_done':
        return ViaColors.success;
      case 'file_open':
        return ViaColors.secondary;
      default:
        return ViaColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Histórico do Contrato"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 70, color: ViaColors.textSecondary),
            const SizedBox(height: 20),
            Text(
              "Nenhuma ação registrada",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: ViaColors.textSecondary),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadLogs,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _logs.length,
          itemBuilder: (_, index) {
            final log = _logs[index];
            final formatted = DateFormat('dd/MM/yyyy HH:mm')
                .format(log.timestamp);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icone da timeline
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  child: Icon(
                    _getIcon(log.action),
                    color: _getColor(log.action),
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // Card da descrição
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: ViaColors.primary
                              .withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.description,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatted,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: ViaColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: (index * 80).ms);
          },
        ),
      ),
    );
  }
}
