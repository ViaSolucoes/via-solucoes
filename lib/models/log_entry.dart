class LogEntry {
  final String id;
  final String contractId;
  final String action;       // ex: view, update, file_open, progress_update...
  final String description;  // texto mostrado na tela de histórico
  final DateTime timestamp;  // quando aconteceu

  LogEntry({
    required this.id,
    required this.contractId,
    required this.action,
    required this.description,
    required this.timestamp,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'],
      contractId: json['contractId'],
      action: json['action'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contractId': contractId,
      'action': action,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
