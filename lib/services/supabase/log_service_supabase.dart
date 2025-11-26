import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:viasolucoes/models/log_entry.dart';

class LogServiceSupabase {
  final SupabaseClient _db = Supabase.instance.client;
  final _uuid = const Uuid();

  // ===========================================================================
  // 🔵 REGISTRAR LOG
  // ===========================================================================
  Future<void> log({
    required LogModule module,
    required LogAction action,
    required String entityType,   // Ex.: "CONTRATO", "TAREFA"
    String? entityId,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    final user = _db.auth.currentUser;
    if (user == null) return; // Usuário não autenticado

    final entry = LogEntry(
      id: _uuid.v4(),
      userId: user.id,
      module: module,
      action: action,
      entityType: entityType,
      entityId: entityId,
      description: description,
      metadata: metadata,
      timestamp: DateTime.now(),
    );

    try {
      await _db.from('tbdLogSistema').insert({
        'idLog': entry.id,
        'idUsuario': entry.userId,
        'modulo': entry.module.name,
        'acao': entry.action.name,
        'entidadeTipo': entry.entityType,
        'entidadeId': entry.entityId,
        'descricao': entry.description,
        'metadata': entry.metadata,
        'criadoEm': entry.timestamp.toIso8601String(),
      });
    } catch (e) {
      print("❌ Erro ao registrar log: $e");
    }
  }

  // ===========================================================================
  // 🔵 HELPER – Mapeamento seguro
  // ===========================================================================
  List<LogEntry> _parseList(dynamic response) {
    if (response is! List) return [];

    return response
        .map((row) {
      try {
        return LogEntry.fromMap(row);
      } catch (e) {
        print("❌ Erro ao converter LogEntry: $e");
        return null; // agora pode retornar null sem causar erro de tipo
      }
    })
        .whereType<LogEntry>() // remove null automaticamente
        .toList();
  }


  // ===========================================================================
  // 🔵 BUSCAR TODOS OS LOGS
  // ===========================================================================
  Future<List<LogEntry>> getAll() async {
    try {
      final res = await _db
          .from('tbdLogSistema')
          .select()
          .order('criadoEm', ascending: false);

      return _parseList(res);
    } catch (e) {
      print("❌ Erro ao buscar logs: $e");
      return [];
    }
  }

  // ===========================================================================
  // 🔵 BUSCAR SOMENTE OS LOGS DO USUÁRIO ATUAL
  // ===========================================================================
  Future<List<LogEntry>> getMyLogs() async {
    final user = _db.auth.currentUser;
    if (user == null) return [];

    try {
      final res = await _db
          .from('tbdLogSistema')
          .select()
          .eq('idUsuario', user.id)
          .order('criadoEm', ascending: false);

      return _parseList(res);
    } catch (e) {
      print("❌ Erro ao buscar logs do usuário: $e");
      return [];
    }
  }

  // ===========================================================================
  // 🔵 BUSCAR LOGS POR MÓDULO
  // ===========================================================================
  Future<List<LogEntry>> getByModule(LogModule module) async {
    try {
      final res = await _db
          .from('tbdLogSistema')
          .select()
          .eq('modulo', module.name)
          .order('criadoEm', ascending: false);

      return _parseList(res);
    } catch (e) {
      print("❌ Erro ao buscar logs por módulo: $e");
      return [];
    }
  }
}
