import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:viasolucoes/models/log_entry.dart';
import 'package:viasolucoes/models/log_entry_extensions.dart';
import 'package:viasolucoes/services/supabase/log_service_supabase.dart';

class ProfileLogTab extends StatefulWidget {
  const ProfileLogTab({super.key});

  @override
  State<ProfileLogTab> createState() => _ProfileLogTabState();
}

class _ProfileLogTabState extends State<ProfileLogTab> {
  final LogServiceSupabase _logService = LogServiceSupabase();

  List<LogEntry> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _logService.getMyLogs(); // busca logs do próprio usuário
    setState(() {
      _logs = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_logs.isEmpty) {
      return const Center(
        child: Text(
          "Nenhum registro encontrado.",
          style: TextStyle(fontSize: 15, color: Colors.grey),
        ),
      );
    }

    final grouped = _groupByDate(_logs);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: grouped.entries.map((entry) {
        final date = entry.key;
        final logs = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 14, top: 10),
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ...logs.asMap().entries.map((item) {
              final index = item.key;
              final log = item.value;

              return _logItem(
                log,
                showLine: index != logs.length - 1,
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // ITEM DA TIMELINE
  // ---------------------------------------------------------------------------
  Widget _logItem(LogEntry entry, {required bool showLine}) {
    final time = DateFormat('HH:mm').format(entry.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: entry.actionColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  entry.actionIcon,
                  color: entry.actionColor,
                  size: 18,
                ),
              ),
              if (showLine)
                Container(
                  width: 3,
                  height: 50,
                  color: entry.actionColor.withValues(alpha: 0.25),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.actionLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entry.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // AGRUPAR POR DATA
  // ---------------------------------------------------------------------------
  Map<String, List<LogEntry>> _groupByDate(List<LogEntry> logs) {
    final Map<String, List<LogEntry>> map = {};
    final formatter = DateFormat('dd/MM/yyyy');

    for (var log in logs) {
      final date = formatter.format(log.timestamp);
      map.putIfAbsent(date, () => []);
      map[date]!.add(log);
    }

    return map;
  }
}
