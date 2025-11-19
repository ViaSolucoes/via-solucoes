import 'package:flutter/material.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/services/task_service.dart';
import 'package:viasolucoes/models/task.dart';
import 'package:viasolucoes/widgets/task_item.dart';
import 'package:viasolucoes/theme.dart';

class ContractTasksTab extends StatefulWidget {
  final Contract contract;

  const ContractTasksTab({super.key, required this.contract});

  @override
  State<ContractTasksTab> createState() => _ContractTasksTabState();
}

class _ContractTasksTabState extends State<ContractTasksTab> {
  final _taskService = TaskService();
  List<Task> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _loading = true;
    setState(() {});

    final all = await _taskService.getAll();
    _tasks = all.where((t) => t.contractId == widget.contract.id).toList();

    _loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_tasks.isEmpty) {
      return Center(
        child: Text(
          "Nenhuma tarefa cadastrada",
          style: TextStyle(color: ViaColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tasks.length,
        itemBuilder: (_, i) => TaskItem(task: _tasks[i]),
      ),
    );
  }
}
