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

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      id: map['idLog'],
      userId: map['idUsuario'],
      module: LogModule.values.byName(map['modulo']),
      action: LogAction.values.byName(map['acao']),
      entityType: map['entidadeTipo'],
      entityId: map['entidadeId'],
      description: map['descricao'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      timestamp: DateTime.parse(map['criadoEm']),
    );
  }

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
