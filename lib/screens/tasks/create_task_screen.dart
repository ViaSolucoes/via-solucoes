import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:viasolucoes/models/task.dart';
import 'package:viasolucoes/services/task_service.dart';

class CreateTaskScreen extends StatefulWidget {
  final String contractId;

  const CreateTaskScreen({super.key, required this.contractId});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskService = TaskService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isSaving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final now = DateTime.now();

    final task = Task(
      id: const Uuid().v4(),
      contractId: widget.contractId,
      title: _titleController.text,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    await _taskService.create(task);

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nova Tarefa")),
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
                decoration:
                const InputDecoration(labelText: "Descrição (opcional)"),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: const Text("Salvar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
