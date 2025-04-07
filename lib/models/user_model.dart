class User {
  final String id;
  final String username;
  final String fullName;
  final String rank;
  final String department;
  final String passwordHash;
  final bool isAdmin;
  final bool isBiometricEnabled;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.rank,
    required this.department,
    required this.passwordHash,
    this.isAdmin = false,
    this.isBiometricEnabled = false,
  });

  // Convert User object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'rank': rank,
      'department': department,
      'passwordHash': passwordHash,
      'isAdmin': isAdmin,
      'isBiometricEnabled': isBiometricEnabled,
    };
  }

  // Create a User object from a Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      fullName: map['fullName'],
      rank: map['rank'],
      department: map['department'],
      passwordHash: map['passwordHash'],
      isAdmin: map['isAdmin'] ?? false,
      isBiometricEnabled: map['isBiometricEnabled'] ?? false,
    );
  }

  // Create a copy of the User with modified fields
  User copyWith({
    String? id,
    String? username,
    String? fullName,
    String? rank,
    String? department,
    String? passwordHash,
    bool? isAdmin,
    bool? isBiometricEnabled,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      rank: rank ?? this.rank,
      department: department ?? this.department,
      passwordHash: passwordHash ?? this.passwordHash,
      isAdmin: isAdmin ?? this.isAdmin,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    );
  }
}
