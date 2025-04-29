class User {
  final String id;
  final String username;
  final String fullName;
  final String initials;
  final String rank;
  final String department;
  final String passwordHash;
  final bool isAdmin;
  final bool isBiometricEnabled;
  final String? token;
  final String? armyNumber;
  final String? photoUrl;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.initials,
    required this.rank,
    required this.department,
    required this.passwordHash,
    this.isAdmin = false,
    this.isBiometricEnabled = false,
    this.token,
    this.armyNumber,
    this.photoUrl,
  });

  // Get name (alias for fullName)
  String get name => fullName;

  // Get display name (rank + initials)
  String get displayName => '$rank $initials';

  // Convert User object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'initials': initials,
      'rank': rank,
      'department': department,
      'passwordHash': passwordHash,
      'isAdmin': isAdmin,
      'isBiometricEnabled': isBiometricEnabled,
      'token': token,
      'armyNumber': armyNumber,
      'photoUrl': photoUrl,
    };
  }

  // Create a User object from a Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      fullName: map['fullName'],
      initials: map['initials'] ?? '', // Default to empty string if not present
      rank: map['rank'],
      department: map['department'],
      passwordHash: map['passwordHash'],
      isAdmin: map['isAdmin'] ?? false,
      isBiometricEnabled: map['isBiometricEnabled'] ?? false,
      token: map['token'],
      armyNumber: map['armyNumber'],
      photoUrl: map['photoUrl'],
    );
  }

  // Create a copy of the User with modified fields
  User copyWith({
    String? id,
    String? username,
    String? fullName,
    String? initials,
    String? rank,
    String? department,
    String? passwordHash,
    bool? isAdmin,
    bool? isBiometricEnabled,
    String? token,
    String? armyNumber,
    String? photoUrl,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      initials: initials ?? this.initials,
      rank: rank ?? this.rank,
      department: department ?? this.department,
      passwordHash: passwordHash ?? this.passwordHash,
      isAdmin: isAdmin ?? this.isAdmin,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      token: token ?? this.token,
      armyNumber: armyNumber ?? this.armyNumber,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
