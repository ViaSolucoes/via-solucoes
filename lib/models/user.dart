class ViaSolutionsUser {
  final String id;
  final String name;
  final String email;
  final String role;

  final String? phone;
  final String? address;

  final String? webhookUrl; // 🆕 ADICIONADO

  final DateTime createdAt;
  final DateTime updatedAt;

  ViaSolutionsUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.webhookUrl, // 🆕 ADICIONADO
    required this.createdAt,
    required this.updatedAt,
  });

  factory ViaSolutionsUser.fromJson(Map<String, dynamic> json) {
    return ViaSolutionsUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'],
      address: json['address'],
      webhookUrl: json['webhookUrl'], // 🆕 ADICIONADO
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'address': address,
      'webhookUrl': webhookUrl, // 🆕 ADICIONADO
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ViaSolutionsUser copyWith({
    String? name,
    String? email,
    String? role,
    String? phone,
    String? address,
    String? webhookUrl, // 🆕 ADICIONADO
    DateTime? updatedAt,
  }) {
    return ViaSolutionsUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      webhookUrl: webhookUrl ?? this.webhookUrl, // 🆕 ADICIONADO
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
