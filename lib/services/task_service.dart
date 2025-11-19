import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:viasolucoes/models/task.dart';
import 'package:viasolucoes/services/contract_service.dart';
import 'package:viasolucoes/extensions/iterable_extensions.dart';


class TaskService {
  static const String _fileName = 'tasks.json';
  final _uuid = const Uuid();

  /// Obtém o arquivo físico onde salvará o JSON
  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// Carrega todas as tarefas
  Future<List<Task>> getAll() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];

      final data = jsonDecode(content);
      if (data is! List) return [];

      return data.map<Task>((json) => Task.fromJson(json)).toList();
    } catch (e) {
      print("Erro ao carregar tarefas: $e");
      return [];
    }
  }

  /// Salva toda a lista
  Future<void> _saveAll(List<Task> tasks) async {
    final file = await _getLocalFile();
    final jsonContent = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await file.writeAsString(jsonContent);
  }

  /// Cria nova tarefa + recalcula progresso
  Future<void> create(Task task) async {
    final all = await getAll();
    all.add(task);
    await _saveAll(all);

    final tasksOfContract =
    all.where((t) => t.contractId == task.contractId).toList();

    await ContractService().recalculateProgress(task.contractId, tasksOfContract);
  }

  /// Atualiza tarefa existente
  Future<void> update(Task updated) async {
    final all = await getAll();
    final index = all.indexWhere((t) => t.id == updated.id);

    if (index != -1) {
      all[index] = updated.copyWith(updatedAt: DateTime.now());
      await _saveAll(all);

      final tasksOfContract =
      all.where((t) => t.contractId == updated.contractId).toList();

      await ContractService().recalculateProgress(updated.contractId, tasksOfContract);
    }
  }

  /// Obtém todas as tarefas de um contrato
  Future<List<Task>> getByContract(String contractId) async {
    final all = await getAll();
    return all.where((t) => t.contractId == contractId).toList();
  }

  /// Remove tarefa + recalcula progresso
  Future<void> delete(String id) async {
    final all = await getAll();

    final task = all.where((t) => t.id == id).firstOrNull;
    if (task == null) return; // ← SAFE

    all.removeWhere((t) => t.id == id);
    await _saveAll(all);

    final tasksOfContract =
    all.where((t) => t.contractId == task.contractId).toList();

    await ContractService().recalculateProgress(task.contractId, tasksOfContract);
  }

  /// Inicializa dados de exemplo
  Future<void> initializeSampleData() async {
    final file = await _getLocalFile();
    if (await file.exists()) return;

    final now = DateTime.now();

    final sample = Task(
      id: _uuid.v4(),
      contractId: '1',
      title: "Tarefa de exemplo",
      description: "Uma tarefa inicial",
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );

    await create(sample);
  }
}

