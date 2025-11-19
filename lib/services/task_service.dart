import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:viasolucoes/models/task.dart';

class TaskService {
  static const String _fileName = 'tasks.json';
  final _uuid = const Uuid();

  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<Task>> getAll() async {
    try {
      final file = await _getLocalFile();

      if (!await file.exists()) return [];

      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];

      final data = jsonDecode(content) as List;
      return data.map((e) => Task.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<Task> tasks) async {
    final file = await _getLocalFile();
    await file.writeAsString(
      jsonEncode(tasks.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> add(Task task) async {
    final all = await getAll();
    all.add(task);
    await saveAll(all);
  }

  Future<List<Task>> getByContract(String contractId) async {
    final all = await getAll();
    return all.where((t) => t.contractId == contractId).toList();
  }

  Future<void> update(Task updated) async {
    final all = await getAll();
    final index = all.indexWhere((t) => t.id == updated.id);

    if (index != -1) {
      all[index] = updated;
      await saveAll(all);
    }
  }

  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((t) => t.id == id);
    await saveAll(all);
  }
}
