import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:viasolucoes/models/task.dart';
import 'package:viasolucoes/extensions/iterable_extensions.dart';
import 'package:viasolucoes/services/log_service.dart';
import 'package:viasolucoes/services/contract_service.dart'; // ✅ IMPORTANTE

class TaskService {
  static const String _fileName = 'tasks.json';
  final _uuid = const Uuid();
  final _logService = LogService();
  final _contractService = ContractService(); // ✅ para atualizar progresso

  /// Obtém o arquivo físico onde será salvo o JSON
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

      final decoded = jsonDecode(content);
      if (decoded is! List) return [];

      return decoded.map<Task>((json) => Task.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erro ao carregar tarefas: $e');
      return [];
    }
  }

  /// Salva toda a lista no arquivo
  Future<void> _saveAll(List<Task> tasks) async {
    final file = await _getLocalFile();
    final jsonContent = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await file.writeAsString(jsonContent);
  }

  /// =========================================================================
  /// 🔥 FUNÇÃO NOVA → Recalcula e atualiza o progresso do contrato
  /// =========================================================================
  Future<void> _updateContractProgress(String contractId) async {
    final tasks = await getByContract(contractId);

    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;

    // 👇 CORREÇÃO: 0.0 ao invés de 0
    final progress = total == 0 ? 0.0 : (completed / total) * 100;

    final contract = await _contractService.getById(contractId);

    if (contract != null) {
      final updated = contract.copyWith(
        progressPercentage: progress,
        updatedAt: DateTime.now(),
      );

      await _contractService.update(updated);
    }
  }


  /// Adiciona uma nova tarefa
  Future<void> add(Task task) async {
    final all = await getAll();
    all.add(task);
    await _saveAll(all);

    // log
    await _logService.add(
      contractId: task.contractId,
      action: 'task_created',
      description: 'Tarefa criada: ${task.title}',
    );

    // atualizar progresso
    await _updateContractProgress(task.contractId);
  }

  /// Busca tarefa por ID
  Future<Task?> getById(String id) async {
    final all = await getAll();
    return all.where((t) => t.id == id).firstOrNull;
  }

  /// Busca tarefas por contrato
  Future<List<Task>> getByContract(String contractId) async {
    final all = await getAll();
    return all.where((t) => t.contractId == contractId).toList();
  }

  /// Atualiza uma tarefa
  Future<void> update(Task updated) async {
    final all = await getAll();
    final index = all.indexWhere((t) => t.id == updated.id);

    if (index != -1) {
      all[index] = updated.copyWith(updatedAt: DateTime.now());
      await _saveAll(all);

      await _logService.add(
        contractId: updated.contractId,
        action: 'task_updated',
        description: 'Tarefa atualizada: ${updated.title}',
      );

      // atualizar progresso
      await _updateContractProgress(updated.contractId);

    } else {
      print("⚠ Tentativa de atualizar tarefa inexistente: ${updated.id}");
    }
  }

  /// Deleta uma tarefa
  Future<void> delete(String id) async {
    final all = await getAll();
    final task = await getById(id);

    all.removeWhere((t) => t.id == id);
    await _saveAll(all);

    if (task != null) {
      await _logService.add(
        contractId: task.contractId,
        action: 'task_deleted',
        description: 'Tarefa removida: ${task.title}',
      );

      // atualizar progresso
      await _updateContractProgress(task.contractId);
    }
  }

  /// Alterna o estado de conclusão
  Future<void> toggleComplete(Task task) async {
    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now(),
    );

    await update(updated);

    await _logService.add(
      contractId: updated.contractId,
      action: updated.isCompleted ? 'task_completed' : 'task_reopened',
      description: updated.isCompleted
          ? 'Tarefa concluída: ${updated.title}'
          : 'Tarefa reaberta: ${updated.title}',
    );

    // atualizar progresso
    await _updateContractProgress(updated.contractId);
  }
}
