class Client {
  final String id;
  final String companyName;
  final String highway;
  final String cnpj;
  final String email;
  final String phone;
  final String contactPerson;
  final String contactRole;
  final String address;
  final String department;
  final String notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Client({
    required this.id,
    required this.companyName,
    required this.highway,
    required this.cnpj,
    required this.email,
    required this.phone,
    required this.contactPerson,
    required this.contactRole,
    required this.address,
    required this.department,
    required this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'companyName': companyName,
    'highway': highway,
    'cnpj': cnpj,
    'email': email,
    'phone': phone,
    'contactPerson': contactPerson,
    'contactRole': contactRole,
    'address': address,
    'department': department,
    'notes': notes,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Client.fromJson(Map<String, dynamic> json) => Client(
    id: json['id'] as String,
    companyName: json['companyName'] as String,
    highway: json['highway'] as String,
    cnpj: json['cnpj'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    contactPerson: json['contactPerson'] as String,
    contactRole: json['contactRole'] as String,
    address: json['address'] as String,
    department: json['department'] as String,
    notes: json['notes'] as String,
    isActive: json['isActive'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Client copyWith({
    String? id,
    String? companyName,
    String? highway,
    String? cnpj,
    String? email,
    String? phone,
    String? contactPerson,
    String? contactRole,
    String? address,
    String? department,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Client(
        id: id ?? this.id,
        companyName: companyName ?? this.companyName,
        highway: highway ?? this.highway,
        cnpj: cnpj ?? this.cnpj,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        contactPerson: contactPerson ?? this.contactPerson,
        contactRole: contactRole ?? this.contactRole,
        address: address ?? this.address,
        department: department ?? this.department,
        notes: notes ?? this.notes,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
