import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:viasolucoes/models/task.dart';
import 'package:viasolucoes/extensions/iterable_extensions.dart';
import 'package:viasolucoes/services/supabase/log_service_supabase.dart';
import 'package:viasolucoes/models/log_entry.dart';
import 'package:viasolucoes/services/supabase/contract_service_supabase.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class TaskService {
  static const String _fileName = 'tasks.json';
  final _uuid = const Uuid();

  final _logService = LogServiceSupabase();
  final _contractService = ContractServiceSupabase();

  /// Usuário autenticado
  String get _currentUserId {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.id ?? "unknown";
  }

  /// Obtém arquivo local
  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// Carregar todas as tarefas
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
      print("❌ Erro ao carregar tarefas: $e");
      return [];
    }
  }

  /// Salvar todas as tarefas
  Future<void> _saveAll(List<Task> tasks) async {
    final file = await _getLocalFile();
    final jsonContent = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await file.writeAsString(jsonContent);
  }

  /// Recalcular progresso do contrato
  Future<void> _updateContractProgress(String contractId) async {
    final tasks = await getByContract(contractId);

    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;

    final progress = total == 0 ? 0.0 : (completed / total) * 100;

    final contract = await _contractService.getById(contractId);
    if (contract == null) return;

    final updated = contract.copyWith(
      progressPercentage: progress,
      updatedAt: DateTime.now(),
    );

    await _contractService.update(updated);
  }

  /// Adicionar nova tarefa
  Future<void> add(Task task) async {
    final all = await getAll();
    all.add(task);
    await _saveAll(all);

    await _logService.log(
      module: LogModule.tarefa,
      action: LogAction.created,
      entityType: "TAREFA",
      entityId: task.id,
      description: "Tarefa criada: ${task.title}",
      metadata: {"contractId": task.contractId},
    );

    await _updateContractProgress(task.contractId);
  }


  /// Buscar por ID
  Future<Task?> getById(String id) async {
    final all = await getAll();
    return all.where((t) => t.id == id).firstOrNull;
  }

  /// Buscar por contrato
  Future<List<Task>> getByContract(String contractId) async {
    final all = await getAll();
    return all.where((t) => t.contractId == contractId).toList();
  }

  /// Atualizar tarefa
  Future<void> update(Task updated) async {
    final all = await getAll();
    final index = all.indexWhere((t) => t.id == updated.id);

    if (index != -1) {
      all[index] = updated.copyWith(updatedAt: DateTime.now());
      await _saveAll(all);

      await _logService.log(
        module: LogModule.tarefa,
        action: LogAction.updated,
        entityType: "TAREFA",
        entityId: updated.id,
        description: "Tarefa atualizada: ${updated.title}",
      );

      await _updateContractProgress(updated.contractId);
    }
  }

  /// Excluir tarefa
  Future<void> delete(String id) async {
    final all = await getAll();
    final task = await getById(id);

    all.removeWhere((t) => t.id == id);
    await _saveAll(all);

    if (task != null) {
      await _logService.log(
        module: LogModule.tarefa,
        action: LogAction.deleted,
        entityType: "TAREFA",
        entityId: task.id,
        description: "Tarefa excluída: ${task.title}",
        metadata: {"contractId": task.contractId},
      );

      await _updateContractProgress(task.contractId);
    }
  }

  /// Alternar conclusão
  Future<void> toggleComplete(Task task) async {
    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now(),
    );

    await update(updated);

    await _logService.log(
      module: LogModule.tarefa,
      action: updated.isCompleted ? LogAction.completed : LogAction.updated,
      entityType: "TAREFA",
      entityId: updated.id,
      description: updated.isCompleted
          ? "Tarefa concluída: ${updated.title}"
          : "Tarefa reaberta: ${updated.title}",
    );

    await _updateContractProgress(updated.contractId);
  }
}
