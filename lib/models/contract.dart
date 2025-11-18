class Contract {
  final String id;
  final String clientId;
  final String clientName;
  final String description;
  final String status;
  final String assignedUserId;
  final DateTime startDate;
  final DateTime endDate;
  final double progressPercentage;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 📌 Campos opcionais de arquivo
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

  factory Contract.fromJson(Map<String, dynamic> json) => Contract(
    id: json['id'] ?? '',
    clientId: json['clientId'] ?? '',
    clientName: json['clientName'] ?? '',
    description: json['description'] ?? '',
    status: json['status'] ?? '',
    assignedUserId: json['assignedUserId'] ?? '',
    startDate:
    DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
    endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
    progressPercentage:
    (json['progressPercentage'] ?? 0).toDouble(),
    createdAt:
    DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    updatedAt:
    DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    fileUrl: json['fileUrl'],
    fileName: json['fileName'],
    hasFile: json['hasFile'] ?? false,
  );

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
