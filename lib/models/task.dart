class Task {
  final String id;
  final String title;
  final String description;
  final String contractId;
  final String assignedUserId;
  final String priority;
  final String status;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.contractId,
    required this.assignedUserId,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'contractId': contractId,
    'assignedUserId': assignedUserId,
    'priority': priority,
    'status': status,
    'dueDate': dueDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    contractId: json['contractId'] as String,
    assignedUserId: json['assignedUserId'] as String,
    priority: json['priority'] as String,
    status: json['status'] as String,
    dueDate: DateTime.parse(json['dueDate'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? contractId,
    String? assignedUserId,
    String? priority,
    String? status,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    contractId: contractId ?? this.contractId,
    assignedUserId: assignedUserId ?? this.assignedUserId,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    dueDate: dueDate ?? this.dueDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  bool get isOverdue =>
      DateTime.now().isAfter(dueDate) && status != 'completed';
  bool get isDueSoon =>
      dueDate.difference(DateTime.now()).inDays <= 2 && status != 'completed';
}
