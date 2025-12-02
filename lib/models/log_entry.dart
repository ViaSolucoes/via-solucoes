import 'dart:convert';

enum LogModule { contrato, empresa, tarefa, usuario, sistema, storage }

enum LogAction {
  created,
  updated,
  deleted,
  viewed,
  statusChanged,
  progressUpdated,
  fileUploaded,
  fileOpened,
  fileReplaced,
  fileRemoved,
  completed,
  login,
  logout,
  error,
}

class LogEntry {
  final String id;
  final String userId;
  final LogModule module;
  final LogAction action;
  final String entityType;
  final String? entityId;
  final String description;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  LogEntry({
    required this.id,
    required this.userId,
    required this.module,
    required this.action,
    required this.entityType,
    this.entityId,
    required this.description,
    this.metadata,
    required this.timestamp,
  });

  // ---------------------------------------------------------
  // NORMALIZADORES PARA DADOS ANTIGOS DO SUPABASE
  // ---------------------------------------------------------

  static String normalizeModule(String value) {
    final v = value.toLowerCase().trim();

    if (v.startsWith('contrato')) return 'contrato';
    if (v.startsWith('empresa')) return 'empresa';
    if (v.startsWith('tarefa')) return 'tarefa';
    if (v.startsWith('usuario')) return 'usuario';
    if (v.startsWith('sistema')) return 'sistema';
    if (v.startsWith('storage')) return 'storage';

    return v; // fallback
  }

  static String normalizeAction(String value) {
    final v = value.toLowerCase().trim();

    switch (v) {
      case 'created':
      case 'create':
      case 'criado':
        return 'created';

      case 'updated':
      case 'update':
      case 'atualizado':
        return 'updated';

      case 'deleted':
      case 'delete':
      case 'excluido':
      case 'removido':
        return 'deleted';

      case 'viewed':
      case 'visualizado':
        return 'viewed';

      case 'completed':
      case 'concluido':
        return 'completed';

      default:
        return v;
    }
  }

  // fallback seguro para módulos
  static LogModule safeModule(String raw) {
    try {
      return LogModule.values.byName(normalizeModule(raw));
    } catch (_) {
      return LogModule.sistema; // não quebra a UI
    }
  }

  // fallback seguro para ações
  static LogAction safeAction(String raw) {
    try {
      return LogAction.values.byName(normalizeAction(raw));
    } catch (_) {
      return LogAction.error;
    }
  }

  // ---------------------------------------------------------
  // FROM MAP (CORRIGIDO)
  // ---------------------------------------------------------

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      id: map['idlog'] ?? map['idLog'],
      userId: map['idusuario'] ?? map['idUsuario'],
      module: safeModule(map['modulo']),
      action: safeAction(map['acao']),
      entityType: map['entidadeTipo'],
      entityId: map['entidadeId'],
      description: map['descricao'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      timestamp: DateTime.parse(
        map['criadoem'] ?? map['criadoEm'],
      ),
    );
  }

  // ---------------------------------------------------------
  // TO MAP (SEM ALTERAÇÕES — FUNCIONA BEM)
  // ---------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'idUsuario': userId,
      'modulo': module.name,
      'acao': action.name,
      'entidadeTipo': entityType,
      'entidadeId': entityId,
      'descricao': description,
      'metadata': metadata,
    };
  }
}
