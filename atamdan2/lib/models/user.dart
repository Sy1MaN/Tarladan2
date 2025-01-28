enum UserRole { seller, buyer }

class User {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final UserRole role;
  final String? companyName; // For sellers
  final String? address;
  final List<String>? specialties; // For sellers (types of products they sell)
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.role,
    this.companyName,
    this.address,
    this.specialties,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isSeller => role == UserRole.seller;
  bool get isBuyer => role == UserRole.buyer;

  // Convert User to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'role': role.toString(),
      'companyName': companyName,
      'address': address,
      'specialties': specialties,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create User from Map (database data)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      role: UserRole.values.firstWhere(
        (role) => role.toString() == map['role'],
      ),
      companyName: map['companyName'],
      address: map['address'],
      specialties: map['specialties'] != null
          ? List<String>.from(map['specialties'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // Create a copy of User with some fields updated
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    UserRole? role,
    String? companyName,
    String? address,
    List<String>? specialties,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      specialties: specialties ?? this.specialties,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
