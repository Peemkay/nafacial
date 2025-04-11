enum PersonnelCategory {
  officerMale,
  officerFemale,
  soldierMale,
  soldierFemale,
}

enum VerificationStatus {
  pending,
  verified,
  rejected,
}

enum ServiceStatus {
  active,
  retired,
  resigned,
  awol, // Absent Without Leave
  deserted,
  dismissed,
}

extension ServiceStatusExtension on ServiceStatus {
  String get displayName {
    switch (this) {
      case ServiceStatus.active:
        return 'Active';
      case ServiceStatus.retired:
        return 'Retired';
      case ServiceStatus.resigned:
        return 'Resigned';
      case ServiceStatus.awol:
        return 'AWOL';
      case ServiceStatus.deserted:
        return 'Deserted';
      case ServiceStatus.dismissed:
        return 'Dismissed';
    }
  }
}

enum RankType {
  officer,
  soldier,
}

enum Corps {
  // Combat Arms
  infantry,
  armoured,
  artillery,

  // Combat Support Arms
  engineers,
  signals,
  intelligence,

  // Combat Service Support Arms
  supplyAndTransport,
  medical,
  ordnance,
  electricalAndMechanical,
  militaryPolice,

  // Administrative and Specialized Corps
  education,
  finance,
  physicalTraining,
  band,
  chaplainServices,
  islamicAffairs,
  publicRelations,
  legalServices,
  womensCorps,
}

// Extension to get corps display name
extension CorpsExtension on Corps {
  String get displayName {
    switch (this) {
      // Combat Arms
      case Corps.infantry:
        return 'Infantry Corps';
      case Corps.armoured:
        return 'Armoured Corps';
      case Corps.artillery:
        return 'Artillery Corps';

      // Combat Support Arms
      case Corps.engineers:
        return 'Engineers Corps (NAE)';
      case Corps.signals:
        return 'Signals Corps (NAS)';
      case Corps.intelligence:
        return 'Intelligence Corps (NAIC)';

      // Combat Service Support Arms
      case Corps.supplyAndTransport:
        return 'Corps of Supply and Transport (NACST)';
      case Corps.medical:
        return 'Medical Corps (NAMC)';
      case Corps.ordnance:
        return 'Ordnance Corps (NAOC)';
      case Corps.electricalAndMechanical:
        return 'Electrical and Mechanical Engineers Corps (NAEME)';
      case Corps.militaryPolice:
        return 'Corps of Military Police (NACMP)';

      // Administrative and Specialized Corps
      case Corps.education:
        return 'Education Corps (NAEC)';
      case Corps.finance:
        return 'Finance Corps (NAFC)';
      case Corps.physicalTraining:
        return 'Directorate of Army Physical Training (DAPT)';
      case Corps.band:
        return 'Band Corps (NABC)';
      case Corps.chaplainServices:
        return 'Chaplain Services';
      case Corps.islamicAffairs:
        return 'Directorate of Islamic Affairs (DOIA)';
      case Corps.publicRelations:
        return 'Directorate of Army Public Relations (DAPR)';
      case Corps.legalServices:
        return 'Directorate of Legal Services';
      case Corps.womensCorps:
        return 'Women\'s Corps';
    }
  }

  String get shortName {
    switch (this) {
      // Combat Arms
      case Corps.infantry:
        return 'Infantry';
      case Corps.armoured:
        return 'Armoured';
      case Corps.artillery:
        return 'Artillery';

      // Combat Support Arms
      case Corps.engineers:
        return 'NAE';
      case Corps.signals:
        return 'NAS';
      case Corps.intelligence:
        return 'NAIC';

      // Combat Service Support Arms
      case Corps.supplyAndTransport:
        return 'NACST';
      case Corps.medical:
        return 'NAMC';
      case Corps.ordnance:
        return 'NAOC';
      case Corps.electricalAndMechanical:
        return 'NAEME';
      case Corps.militaryPolice:
        return 'NACMP';

      // Administrative and Specialized Corps
      case Corps.education:
        return 'NAEC';
      case Corps.finance:
        return 'NAFC';
      case Corps.physicalTraining:
        return 'DAPT';
      case Corps.band:
        return 'NABC';
      case Corps.chaplainServices:
        return 'Chaplain';
      case Corps.islamicAffairs:
        return 'DOIA';
      case Corps.publicRelations:
        return 'DAPR';
      case Corps.legalServices:
        return 'Legal';
      case Corps.womensCorps:
        return 'Women\'s Corps';
    }
  }
}

enum Rank {
  // Officer Ranks
  general,
  lieutenantGeneral,
  majorGeneral,
  brigadierGeneral,
  colonel,
  lieutenantColonel,
  major,
  captain,
  lieutenant,
  secondLieutenant,

  // Soldier Ranks
  warrantOfficerClass1,
  warrantOfficerClass2,
  staffSergeant,
  sergeant,
  corporal,
  lanceCorporal,
  private,
}

// Extension to get rank type
extension RankTypeExtension on Rank {
  RankType get type {
    switch (this) {
      case Rank.general:
      case Rank.lieutenantGeneral:
      case Rank.majorGeneral:
      case Rank.brigadierGeneral:
      case Rank.colonel:
      case Rank.lieutenantColonel:
      case Rank.major:
      case Rank.captain:
      case Rank.lieutenant:
      case Rank.secondLieutenant:
        return RankType.officer;
      case Rank.warrantOfficerClass1:
      case Rank.warrantOfficerClass2:
      case Rank.staffSergeant:
      case Rank.sergeant:
      case Rank.corporal:
      case Rank.lanceCorporal:
      case Rank.private:
        return RankType.soldier;
    }
  }

  // Get display name
  String get displayName {
    switch (this) {
      case Rank.general:
        return 'General (4 star general)';
      case Rank.lieutenantGeneral:
        return 'Lieutenant General (3 star general)';
      case Rank.majorGeneral:
        return 'Major General (2 star general)';
      case Rank.brigadierGeneral:
        return 'Brigadier General (1 star general)';
      case Rank.colonel:
        return 'Colonel';
      case Rank.lieutenantColonel:
        return 'Lieutenant Colonel';
      case Rank.major:
        return 'Major';
      case Rank.captain:
        return 'Captain';
      case Rank.lieutenant:
        return 'Lieutenant';
      case Rank.secondLieutenant:
        return 'Second Lieutenant';
      case Rank.warrantOfficerClass1:
        return 'Warrant Officer Class 1';
      case Rank.warrantOfficerClass2:
        return 'Warrant Officer Class 2';
      case Rank.staffSergeant:
        return 'Staff Sergeant';
      case Rank.sergeant:
        return 'Sergeant';
      case Rank.corporal:
        return 'Corporal';
      case Rank.lanceCorporal:
        return 'Lance Corporal';
      case Rank.private:
        return 'Private';
    }
  }

  // Get short name
  String get shortName {
    switch (this) {
      case Rank.general:
        return 'Gen.';
      case Rank.lieutenantGeneral:
        return 'Lt. Gen.';
      case Rank.majorGeneral:
        return 'Maj. Gen.';
      case Rank.brigadierGeneral:
        return 'Brig. Gen.';
      case Rank.colonel:
        return 'Col.';
      case Rank.lieutenantColonel:
        return 'Lt. Col.';
      case Rank.major:
        return 'Maj.';
      case Rank.captain:
        return 'Capt.';
      case Rank.lieutenant:
        return 'Lt.';
      case Rank.secondLieutenant:
        return '2nd Lt.';
      case Rank.warrantOfficerClass1:
        return 'WO1';
      case Rank.warrantOfficerClass2:
        return 'WO2';
      case Rank.staffSergeant:
        return 'S/Sgt.';
      case Rank.sergeant:
        return 'Sgt.';
      case Rank.corporal:
        return 'Cpl.';
      case Rank.lanceCorporal:
        return 'L/Cpl.';
      case Rank.private:
        return 'Pte.';
    }
  }
}

class Personnel {
  final String id;
  final String armyNumber;
  final String fullName;
  final String initials;
  final Rank rank;
  final String unit;
  final Corps corps;
  final PersonnelCategory category;
  final String? photoUrl;
  final VerificationStatus status;
  final ServiceStatus serviceStatus;
  final DateTime dateRegistered;
  final DateTime? lastVerified;
  final String? notes;
  final DateTime? dateOfBirth;
  final DateTime? enlistmentDate;

  // Calculate years of service based on enlistment date
  int get yearsOfService {
    if (enlistmentDate == null) return 0;

    final now = DateTime.now();
    final years = now.year - enlistmentDate!.year;

    // Adjust for month and day
    if (now.month < enlistmentDate!.month ||
        (now.month == enlistmentDate!.month && now.day < enlistmentDate!.day)) {
      return years - 1;
    }

    return years;
  }

  Personnel({
    required this.id,
    required this.armyNumber,
    required this.fullName,
    required this.initials,
    required this.rank,
    required this.unit,
    required this.corps,
    required this.category,
    this.photoUrl,
    this.status = VerificationStatus.pending,
    this.serviceStatus = ServiceStatus.active,
    required this.dateRegistered,
    this.lastVerified,
    this.notes,
    this.dateOfBirth,
    this.enlistmentDate,
  });

  // Determine category from army number - more flexible approach
  static PersonnelCategory getCategoryFromArmyNumber(String armyNumber) {
    // Check if it's an officer (starts with N/)
    final isOfficer = armyNumber.startsWith('N/');

    // Check if it's female (ends with F)
    final isFemale = armyNumber.endsWith('F');

    if (isOfficer) {
      return isFemale
          ? PersonnelCategory.officerFemale
          : PersonnelCategory.officerMale;
    } else {
      // Assume it's a soldier if not an officer
      return isFemale
          ? PersonnelCategory.soldierFemale
          : PersonnelCategory.soldierMale;
    }
  }

  // Validate army number format - more flexible validation
  static bool isValidArmyNumber(String armyNumber) {
    // Basic validation - just check for general patterns
    // Officer: Starts with N/
    final officerRegex = RegExp(r'^N/.*');

    // Soldier: Contains NA/ somewhere in the string
    final soldierRegex = RegExp(r'.*NA/.*');

    // Accept any army number that follows the basic pattern
    return officerRegex.hasMatch(armyNumber) ||
        soldierRegex.hasMatch(armyNumber);
  }

  // Convert Personnel object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'armyNumber': armyNumber,
      'fullName': fullName,
      'initials': initials,
      'rank': rank.toString().split('.').last,
      'unit': unit,
      'corps': corps.toString().split('.').last,
      'category': category.toString().split('.').last,
      'photoUrl': photoUrl,
      'status': status.toString().split('.').last,
      'serviceStatus': serviceStatus.toString().split('.').last,
      'dateRegistered': dateRegistered.toIso8601String(),
      'lastVerified': lastVerified?.toIso8601String(),
      'notes': notes,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'enlistmentDate': enlistmentDate?.toIso8601String(),
    };
  }

  // Create a Personnel object from a Map
  factory Personnel.fromMap(Map<String, dynamic> map) {
    return Personnel(
      id: map['id'],
      armyNumber: map['armyNumber'],
      fullName: map['fullName'],
      initials: map['initials'] ?? '', // Default to empty string if not present
      rank: Rank.values.firstWhere(
        (e) => e.toString().split('.').last == map['rank'],
        orElse: () => Rank.private,
      ),
      unit: map['unit'],
      corps: Corps.values.firstWhere(
        (e) => e.toString().split('.').last == map['corps'],
        orElse: () => Corps.infantry,
      ),
      category: PersonnelCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
      ),
      photoUrl: map['photoUrl'],
      status: VerificationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => VerificationStatus.pending,
      ),
      serviceStatus: ServiceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['serviceStatus'],
        orElse: () => ServiceStatus.active,
      ),
      dateRegistered: DateTime.parse(map['dateRegistered']),
      lastVerified: map['lastVerified'] != null
          ? DateTime.parse(map['lastVerified'])
          : null,
      notes: map['notes'],
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.parse(map['dateOfBirth'])
          : null,
      enlistmentDate: map['enlistmentDate'] != null
          ? DateTime.parse(map['enlistmentDate'])
          : null,
    );
  }

  // Create a copy of the Personnel with modified fields
  Personnel copyWith({
    String? id,
    String? armyNumber,
    String? fullName,
    String? initials,
    Rank? rank,
    String? unit,
    Corps? corps,
    PersonnelCategory? category,
    String? photoUrl,
    VerificationStatus? status,
    ServiceStatus? serviceStatus,
    DateTime? dateRegistered,
    DateTime? lastVerified,
    String? notes,
    DateTime? dateOfBirth,
    DateTime? enlistmentDate,
  }) {
    return Personnel(
      id: id ?? this.id,
      armyNumber: armyNumber ?? this.armyNumber,
      fullName: fullName ?? this.fullName,
      initials: initials ?? this.initials,
      rank: rank ?? this.rank,
      unit: unit ?? this.unit,
      corps: corps ?? this.corps,
      category: category ?? this.category,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      serviceStatus: serviceStatus ?? this.serviceStatus,
      dateRegistered: dateRegistered ?? this.dateRegistered,
      lastVerified: lastVerified ?? this.lastVerified,
      notes: notes ?? this.notes,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      enlistmentDate: enlistmentDate ?? this.enlistmentDate,
    );
  }

  // Convert Personnel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'armyNumber': armyNumber,
      'fullName': fullName,
      'initials': initials,
      'rank': rank.toString().split('.').last,
      'unit': unit,
      'corps': corps.toString().split('.').last,
      'category': category.toString().split('.').last,
      'photoUrl': photoUrl,
      'status': status.toString().split('.').last,
      'serviceStatus': serviceStatus.toString().split('.').last,
      'dateRegistered': dateRegistered.toIso8601String(),
      'lastVerified': lastVerified?.toIso8601String(),
      'notes': notes,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'enlistmentDate': enlistmentDate?.toIso8601String(),
      'yearsOfService': yearsOfService,
    };
  }

  // Create Personnel from JSON
  factory Personnel.fromJson(Map<String, dynamic> json) {
    return Personnel(
      id: json['id'],
      armyNumber: json['armyNumber'],
      fullName: json['fullName'],
      initials:
          json['initials'] ?? '', // Default to empty string if not present
      rank: _parseRank(json['rank']),
      unit: json['unit'],
      corps: _parseCorps(json['corps']),
      category: _parseCategory(json['category']),
      photoUrl: json['photoUrl'],
      status: _parseVerificationStatus(json['status']),
      serviceStatus: _parseServiceStatus(json['serviceStatus']),
      dateRegistered: DateTime.parse(json['dateRegistered']),
      lastVerified: json['lastVerified'] != null
          ? DateTime.parse(json['lastVerified'])
          : null,
      notes: json['notes'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      enlistmentDate: json['enlistmentDate'] != null
          ? DateTime.parse(json['enlistmentDate'])
          : null,
    );
  }

  // Parse rank from string
  static Rank _parseRank(String rankStr) {
    return Rank.values.firstWhere(
      (r) => r.toString().split('.').last == rankStr,
      orElse: () => Rank.private,
    );
  }

  // Parse corps from string
  static Corps _parseCorps(String corpsStr) {
    return Corps.values.firstWhere(
      (c) => c.toString().split('.').last == corpsStr,
      orElse: () => Corps.infantry,
    );
  }

  // Parse category from string
  static PersonnelCategory _parseCategory(String categoryStr) {
    return PersonnelCategory.values.firstWhere(
      (c) => c.toString().split('.').last == categoryStr,
      orElse: () => PersonnelCategory.soldierMale,
    );
  }

  // Parse verification status from string
  static VerificationStatus _parseVerificationStatus(String statusStr) {
    return VerificationStatus.values.firstWhere(
      (s) => s.toString().split('.').last == statusStr,
      orElse: () => VerificationStatus.pending,
    );
  }

  // Parse service status from string
  static ServiceStatus _parseServiceStatus(String statusStr) {
    return ServiceStatus.values.firstWhere(
      (s) => s.toString().split('.').last == statusStr,
      orElse: () => ServiceStatus.active,
    );
  }
}
