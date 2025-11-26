class ViaSolutionsUser {
  final String id;
  final String name;
  final String email;
  final String role;

  final String? phone;     // 🆕 novo campo
  final String? address;   // 🆕 novo campo

  final DateTime createdAt;
  final DateTime updatedAt;

  ViaSolutionsUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ViaSolutionsUser.fromJson(Map<String, dynamic> json) {
    return ViaSolutionsUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'],            // novo
      address: json['address'],        // novo
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
    DateTime? updatedAt,
  }) {
    return ViaSolutionsUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
