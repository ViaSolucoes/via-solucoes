enum ContractStatus { draft, active, completed, overdue, cancelled }

class Contract {
  final String id;
  final String clientName;
  final String description;
  final String status;
  final String assignedUserId;
  final DateTime startDate;
  final DateTime endDate;
  final double progressPercentage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Contract({
    required this.id,
    required this.clientName,
    required this.description,
    required this.status,
    required this.assignedUserId,
    required this.startDate,
    required this.endDate,
    required this.progressPercentage,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'clientName': clientName,
    'description': description,
    'status': status,
    'assignedUserId': assignedUserId,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'progressPercentage': progressPercentage,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Contract.fromJson(Map<String, dynamic> json) => Contract(
    id: json['id'] as String,
    clientName: json['clientName'] as String,
    description: json['description'] as String,
    status: json['status'] as String,
    assignedUserId: json['assignedUserId'] as String,
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: DateTime.parse(json['endDate'] as String),
    progressPercentage: (json['progressPercentage'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Contract copyWith({
    String? id,
    String? clientName,
    String? description,
    String? status,
    String? assignedUserId,
    DateTime? startDate,
    DateTime? endDate,
    double? progressPercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Contract(
    id: id ?? this.id,
    clientName: clientName ?? this.clientName,
    description: description ?? this.description,
    status: status ?? this.status,
    assignedUserId: assignedUserId ?? this.assignedUserId,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    progressPercentage: progressPercentage ?? this.progressPercentage,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  bool get isOverdue =>
      DateTime.now().isAfter(endDate) && status != 'completed';
  bool get isDueSoon =>
      endDate.difference(DateTime.now()).inDays <= 3 && status != 'completed';
}
