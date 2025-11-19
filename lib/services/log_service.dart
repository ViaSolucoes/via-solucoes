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
  // Lê todos os logs
  // ---------------------------------------------------------------
  Future<List<LogEntry>> getAll() async {
    try {
      final file = await _getLocalFile();

      if (!await file.exists()) return [];

      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];

      final data = jsonDecode(content);
      if (data is! List) return [];

      return data.map<LogEntry>((e) => LogEntry.fromJson(e)).toList();
    } catch (e) {
      print("Erro ao carregar logs: $e");
      return [];
    }
  }

  // ---------------------------------------------------------------
  // Salva lista completa
  // ---------------------------------------------------------------
  Future<void> _saveAll(List<LogEntry> logs) async {
    final file = await _getLocalFile();
    final jsonContent =
    jsonEncode(logs.map((l) => l.toJson()).toList());
    await file.writeAsString(jsonContent);
  }

  // ---------------------------------------------------------------
  // Adiciona um novo log
  // ---------------------------------------------------------------
  Future<void> add({
    required String contractId,
    required String action,
    required String description,
  }) async {
    final logs = await getAll();

    final log = LogEntry(
      id: _uuid.v4(),
      contractId: contractId,
      action: action,
      description: description,
      timestamp: DateTime.now(),
    );

    logs.insert(0, log); // adiciona no topo -> mais recente primeiro
    await _saveAll(logs);
  }

  // ---------------------------------------------------------------
  // Retorna apenas logs de um contrato específico
  // ---------------------------------------------------------------
  Future<List<LogEntry>> getByContract(String contractId) async {
    final logs = await getAll();
    return logs.where((l) => l.contractId == contractId).toList();
  }
}
