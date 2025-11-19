import 'package:flutter/material.dart';
import 'package:viasolucoes/models/task.dart';
import 'package:viasolucoes/services/task_service.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskService = TaskService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late bool _isCompleted;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description ?? "");

    _isCompleted = widget.task.isCompleted;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updated = widget.task.copyWith(
      title: _titleController.text,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      isCompleted: _isCompleted,
    );

    await _taskService.update(updated);

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Tarefa")),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Título"),
                validator: (v) =>
                v == null || v.isEmpty ? "Informe o título" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Descrição (opcional)",
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Checkbox(
                    value: _isCompleted,
                    onChanged: (value) =>
                        setState(() => _isCompleted = value ?? false),
                  ),
                  const Text("Concluída"),
                ],
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _save,
                child: const Text("Salvar Alterações"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
