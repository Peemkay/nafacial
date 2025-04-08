class User {
  final String id;
  final String username;
  final String fullName;
  final String rank;
  final String department;
  final String passwordHash;
  final bool isAdmin;
  final bool isBiometricEnabled;
  final String? token;
  final String? armyNumber;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.rank,
    required this.department,
    required this.passwordHash,
    this.isAdmin = false,
    this.isBiometricEnabled = false,
    this.token,
    this.armyNumber,
  });

  // Get name (alias for fullName)
  String get name => fullName;

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
      'token': token,
      'armyNumber': armyNumber,
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
      token: map['token'],
      armyNumber: map['armyNumber'],
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
    String? token,
    String? armyNumber,
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
      token: token ?? this.token,
      armyNumber: armyNumber ?? this.armyNumber,
    );
  }
}
