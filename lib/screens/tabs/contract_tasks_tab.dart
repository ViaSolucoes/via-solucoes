import 'package:flutter/material.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/models/task.dart';
import 'package:viasolucoes/services/task_service.dart';
import 'package:viasolucoes/theme.dart';
import 'package:viasolucoes/widgets/task_item.dart';
import 'package:viasolucoes/screens/tasks/create_task_screen.dart';

import '../tasks/edit_task_screen.dart';

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
    setState(() => _loading = true);
    final data = await _taskService.getByContract(widget.contract.id);
    setState(() {
      _tasks = data;
      _loading = false;
    });
  }

  Future<void> _toggle(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await _taskService.update(updated);
    _loadTasks();
  }

  Future<void> _delete(Task task) async {
    await _taskService.delete(task.id);
    _loadTasks();
  }

  Future<void> _add() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CreateTaskScreen(contractId: widget.contract.id),
      ),
    );

    if (result == true) _loadTasks();
  }

  Future<void> _edit(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTaskScreen(task: task),
      ),
    );

    if (result == true) _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _tasks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final task = _tasks[i];
            return TaskItem(
              task: task,
              onToggle: () => _toggle(task),
              onDelete: () => _delete(task),
              onEdit: () => _edit(task),
            );
          },
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            backgroundColor: ViaColors.primary,
            onPressed: _add,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
