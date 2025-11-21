import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import 'package:viasolucoes/models/log_entry.dart';
import 'package:viasolucoes/services/log_service.dart';
import 'package:viasolucoes/theme.dart';

class LogTab extends StatefulWidget {
  const LogTab({super.key});

  @override
  State<LogTab> createState() => _LogTabState();
}

class _LogTabState extends State<LogTab> {
  final _logService = LogService();
  List<LogEntry> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await _logService.getAll();

    // Mais recentes primeiro
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    setState(() {
      _logs = logs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_logs.isEmpty) {
      return Center(
        child: Text(
          'Nenhum histórico disponível.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    final grouped = _groupLogsByDate();

    return RefreshIndicator(
      onRefresh: _loadLogs,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: grouped.keys.map((date) {
          final entries = grouped[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho de data
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 6),
                child: Text(
                  DateFormat('dd/MM/yyyy').format(date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
              ).animate().fadeIn(duration: 250.ms),

              ...entries.asMap().entries.map((entry) {
                final index = entry.key;
                final log = entry.value;

                final meta = _mapAction(log.action);
                final time = DateFormat('HH:mm').format(log.timestamp);

                final isFirst = index == 0;
                final isLast = index == entries.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TimelineAxis(
                      color: meta.color,
                      isFirst: isFirst,
                      isLast: isLast,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _LogCard(
                        title: meta.label,
                        description: log.description,
                        icon: meta.icon,
                        color: meta.color,
                        time: time,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: (index * 80).ms, duration: 300.ms)
                    .slideX(begin: 0.2);
              }),
              const SizedBox(height: 14),
            ],
          );
        }).toList(),
      ),
    );
  }

  Map<DateTime, List<LogEntry>> _groupLogsByDate() {
    final Map<DateTime, List<LogEntry>> map = {};
    for (var log in _logs) {
      final date =
      DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      map.putIfAbsent(date, () => []).add(log);
    }
    return map;
  }

  // ----------------------------------------------------------
  // MAPEAMENTO ACTION → LABEL / COR / ÍCONE
  // ----------------------------------------------------------
  _LogMeta _mapAction(String action) {
    final normalized = action.toLowerCase();

    if (normalized.contains('contract_created')) {
      return _LogMeta(
        label: 'Contrato criado',
        color: Colors.blueAccent,
        icon: Icons.description_outlined,
      );
    } else if (normalized.contains('contract_updated') ||
        normalized.contains('updated') && normalized.contains('contract')) {
      return _LogMeta(
        label: 'Contrato atualizado',
        color: Colors.indigo,
        icon: Icons.sync_alt_rounded,
      );
    } else if (normalized.contains('task_created')) {
      return _LogMeta(
        label: 'Tarefa criada',
        color: Colors.orange,
        icon: Icons.note_add_outlined,
      );
    } else if (normalized.contains('task_updated')) {
      return _LogMeta(
        label: 'Tarefa atualizada',
        color: Colors.deepOrange,
        icon: Icons.edit_outlined,
      );
    } else if (normalized.contains('task_completed')) {
      return _LogMeta(
        label: 'Tarefa concluída',
        color: Colors.green,
        icon: Icons.check_circle_outline,
      );
    } else if (normalized.contains('task_reopened')) {
      return _LogMeta(
        label: 'Tarefa reaberta',
        color: Colors.amber,
        icon: Icons.refresh_outlined,
      );
    } else if (normalized.contains('task_deleted')) {
      return _LogMeta(
        label: 'Tarefa removida',
        color: Colors.redAccent,
        icon: Icons.delete_outline,
      );
    } else if (normalized.contains('file_uploaded') ||
        normalized.contains('file_attached')) {
      return _LogMeta(
        label: 'Arquivo anexado',
        color: Colors.purple,
        icon: Icons.attach_file,
      );
    } else if (normalized.contains('file_deleted')) {
      return _LogMeta(
        label: 'Arquivo removido',
        color: Colors.deepPurple,
        icon: Icons.delete_forever_outlined,
      );
    } else if (normalized.contains('login')) {
      return _LogMeta(
        label: 'Login efetuado',
        color: Colors.grey,
        icon: Icons.login_rounded,
      );
    } else if (normalized.contains('logout')) {
      return _LogMeta(
        label: 'Logout efetuado',
        color: Colors.grey,
        icon: Icons.logout_rounded,
      );
    }

    // fallback genérico
    return _LogMeta(
      label: action.replaceAll('_', ' '),
      color: ViaColors.primary,
      icon: Icons.history_rounded,
    );
  }
}

// ==========================================================
// COMPONENTES DA TIMELINE
// ==========================================================

class _TimelineAxis extends StatelessWidget {
  final Color color;
  final bool isFirst;
  final bool isLast;

  const _TimelineAxis({
    required this.color,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final lineColor = color.withOpacity(0.4);

    return Column(
      children: [
        Container(
          width: 2,
          height: isFirst ? 10 : 18,
          color: isFirst ? Colors.transparent : lineColor,
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: color, width: 3),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 2,
          height: isLast ? 0 : 24,
          color: isLast ? Colors.transparent : lineColor,
        ),
      ],
    );
  }
}

class _LogCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String time;

  const _LogCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone colorido
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 10),

          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Horário
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Metadados de visual do log
class _LogMeta {
  final String label;
  final Color color;
  final IconData icon;

  _LogMeta({
    required this.label,
    required this.color,
    required this.icon,
  });
}
