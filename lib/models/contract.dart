class Contract {
  final String id;
  final String clientId;
  final String clientName;
  final String description;

  // Status legado (não usado)
  final String status;

  final String assignedUserId;
  final DateTime startDate;
  final DateTime endDate;
  final double progressPercentage;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Arquivos
  final String? fileUrl;
  final String? fileName;
  final bool hasFile;

  Contract({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.description,
    required this.status,
    required this.assignedUserId,
    required this.startDate,
    required this.endDate,
    required this.progressPercentage,
    required this.createdAt,
    required this.updatedAt,
    this.fileUrl,
    this.fileName,
    this.hasFile = false,
  });

  // ============================================================
  // 🔥 Status calculado
  // ============================================================
  String get computedStatus {
    final now = DateTime.now();

    if (progressPercentage >= 100) return 'completed';
    if (endDate.isBefore(now)) return 'overdue';
    return 'active';
  }

  // ============================================================
  // 🔄 JSON → MODEL (PARSE SEGURO)
  // ============================================================
  factory Contract.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Contract(
      id: json['id'] ?? '',
      clientId: json['clientId'] ?? '',
      clientName: json['clientName'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      assignedUserId: json['assignedUserId'] ?? '',

      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),

      progressPercentage: (json['progressPercentage'] ?? 0).toDouble(),
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      hasFile: json['hasFile'] ?? false,
    );
  }

  // ============================================================
  // MODEL → JSON
  // ============================================================
  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'clientName': clientName,
        'description': description,
        'status': status,
        'assignedUserId': assignedUserId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'progressPercentage': progressPercentage,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'fileUrl': fileUrl,
        'fileName': fileName,
        'hasFile': hasFile,
      };

  // ============================================================
  // COPY WITH
  // ============================================================
  Contract copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? description,
    String? status,
    String? assignedUserId,
    DateTime? startDate,
    DateTime? endDate,
    double? progressPercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fileUrl,
    String? fileName,
    bool? hasFile,
  }) =>
      Contract(
        id: id ?? this.id,
        clientId: clientId ?? this.clientId,
        clientName: clientName ?? this.clientName,
        description: description ?? this.description,
        status: status ?? this.status,
        assignedUserId: assignedUserId ?? this.assignedUserId,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        progressPercentage: progressPercentage ?? this.progressPercentage,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        fileUrl: fileUrl ?? this.fileUrl,
        fileName: fileName ?? this.fileName,
        hasFile: hasFile ?? this.hasFile,
      );
}
