import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:viasolucoes/models/log_entry.dart';

class LogService {
  static const String _fileName = 'logs.json';
  final _uuid = const Uuid();

  // ---------------------------------------------------------------
  // Obtém o arquivo local
  // ---------------------------------------------------------------
  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  // ---------------------------------------------------------------
  // Lê todos os logs (modelo novo)
  // ---------------------------------------------------------------
  Future<List<LogEntry>> getAll() async {
    try {
      final file = await _getLocalFile();

      if (!await file.exists()) return [];

      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];

      final data = jsonDecode(content);
      if (data is! List) return [];

      return data
          .map<LogEntry>((e) => LogEntry.fromMap(e))
          .toList();
    } catch (e) {
      print("Erro ao carregar logs: $e");
      return [];
    }
  }

  // ---------------------------------------------------------------
  // Salva lista completa (modelo novo)
  // ---------------------------------------------------------------
  Future<void> _saveAll(List<LogEntry> logs) async {
    final file = await _getLocalFile();
    final jsonContent = jsonEncode(
      logs.map((l) => l.toMap()).toList(),
    );
    await file.writeAsString(jsonContent);
  }

  // ---------------------------------------------------------------
  // Adiciona novo log (modelo novo)
  // ---------------------------------------------------------------
  Future<void> add({
    required LogModule module,
    required LogAction action,
    required String entityType,
    String? entityId,
    required String description,
    Map<String, dynamic>? metadata,
    required String userId,
  }) async {
    final logs = await getAll();

    final log = LogEntry(
      id: _uuid.v4(),
      userId: userId,
      module: module,
      action: action,
      entityType: entityType,
      entityId: entityId,
      description: description,
      metadata: metadata,
      timestamp: DateTime.now(),
    );

    logs.insert(0, log);
    await _saveAll(logs);
  }

  // ---------------------------------------------------------------
  // Retorna logs por entidade (antigo "por contrato")
  // ---------------------------------------------------------------
  Future<List<LogEntry>> getByEntity(String entityId) async {
    final logs = await getAll();
    return logs.where((l) => l.entityId == entityId).toList();
  }
}
