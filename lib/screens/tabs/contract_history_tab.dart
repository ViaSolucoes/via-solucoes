import 'package:flutter/material.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/models/log_entry.dart';
import 'package:viasolucoes/services/log_service.dart';
import 'package:viasolucoes/theme.dart';

class ContractHistoryTab extends StatefulWidget {
  final Contract contract;

  const ContractHistoryTab({super.key, required this.contract});

  @override
  State<ContractHistoryTab> createState() => _ContractHistoryTabState();
}

class _ContractHistoryTabState extends State<ContractHistoryTab> {
  final _logService = LogService();
  List<LogEntry> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    _loading = true;
    setState(() {});

    final all = await _logService.getAll();
    _logs = all
        .where((l) => l.contractId == widget.contract.id)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    _loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_logs.isEmpty) {
      return const Center(child: Text("Nenhum registro encontrado."));
    }

    return RefreshIndicator(
      onRefresh: _loadLogs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _logs.length,
        itemBuilder: (_, i) {
          final log = _logs[i];

          return ListTile(
            leading: const Icon(Icons.history),
            title: Text(log.description),
            subtitle: Text(
              "${log.timestamp.day}/${log.timestamp.month}/${log.timestamp.year} "
                  "${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}",
            ),
          );
        },
      ),
    );
  }
}
