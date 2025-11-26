import 'package:flutter/material.dart';
import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/models/task.dart';
import 'package:viasolucoes/services/supabase/task_service_supabase.dart';
import 'package:viasolucoes/theme.dart';
import 'package:viasolucoes/widgets/task_item.dart';
import 'package:viasolucoes/screens/tasks/create_task_screen.dart';
import '../../tasks/edit_task_screen.dart';

class ContractTasksTab extends StatefulWidget {
  final Contract contract;

  const ContractTasksTab({super.key, required this.contract});

  @override
  State<ContractTasksTab> createState() => _ContractTasksTabState();
}

class _ContractTasksTabState extends State<ContractTasksTab> {
  final TaskServiceSupabase _taskService = TaskServiceSupabase();

  List<Task> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // ============================================================
  // 🔵 CARREGAR TAREFAS DO SUPABASE
  // ============================================================
  Future<void> _loadTasks() async {
    setState(() => _loading = true);

    try {
      final data = await _taskService.getByContract(widget.contract.id);
      setState(() {
        _tasks = data;
      });
    } catch (e) {
      print("❌ Erro ao carregar tarefas: $e");
    }

    setState(() => _loading = false);
  }

  // ============================================================
  // 🔵 ALTERNAR COMPLETO / NÃO COMPLETO
  // ============================================================
  Future<void> _toggle(Task task) async {
    await _taskService.toggleCompleted(task);
    _loadTasks();
  }

  // ============================================================
  // 🔵 DELETAR TAREFA
  // ============================================================
  Future<void> _delete(Task task) async {
    await _taskService.delete(task.id, task.contractId);
    _loadTasks();
  }

  // ============================================================
  // 🔵 CRIAR TAREFA
  // ============================================================
  Future<void> _add() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateTaskScreen(contractId: widget.contract.id),
      ),
    );

    if (result == true) {
      _loadTasks();
    }
  }

  // ============================================================
  // 🔵 EDITAR TAREFA
  // ============================================================
  Future<void> _edit(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTaskScreen(task: task),
      ),
    );

    if (result == true) {
      _loadTasks();
    }
  }

  // ============================================================
  // 🔵 UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
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

        // BOTÃO FLUTUANTE
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            backgroundColor: ViaColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add_rounded, size: 30),
            onPressed: _add,
          ),
        ),
      ],
    );
  }
}
