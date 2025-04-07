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

enum RankType {
  officer,
  soldier,
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
  final Rank rank;
  final String unit;
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
    required this.rank,
    required this.unit,
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

  // Determine category from army number
  static PersonnelCategory getCategoryFromArmyNumber(String armyNumber) {
    if (armyNumber.startsWith('N/') && armyNumber.endsWith('F')) {
      return PersonnelCategory.officerFemale;
    } else if (armyNumber.startsWith('N/')) {
      return PersonnelCategory.officerMale;
    } else if (armyNumber.contains('NA/') && armyNumber.endsWith('F')) {
      return PersonnelCategory.soldierFemale;
    } else if (armyNumber.contains('NA/')) {
      return PersonnelCategory.soldierMale;
    } else {
      throw Exception('Invalid army number format');
    }
  }

  // Validate army number format
  static bool isValidArmyNumber(String armyNumber) {
    // Officer Male: N/xxxxx
    final officerMaleRegex = RegExp(r'^N/\d+$');

    // Officer Female: N/xxxxxF
    final officerFemaleRegex = RegExp(r'^N/\d+F$');

    // Soldier Male: xxNA/xx/xxxxx
    final soldierMaleRegex = RegExp(r'^\d+NA/\d+/\d+$');

    // Soldier Female: xxNA/xx/xxxxxF
    final soldierFemaleRegex = RegExp(r'^\d+NA/\d+/\d+F$');

    return officerMaleRegex.hasMatch(armyNumber) ||
        officerFemaleRegex.hasMatch(armyNumber) ||
        soldierMaleRegex.hasMatch(armyNumber) ||
        soldierFemaleRegex.hasMatch(armyNumber);
  }

  // Convert Personnel object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'armyNumber': armyNumber,
      'fullName': fullName,
      'rank': rank.toString().split('.').last,
      'unit': unit,
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
      rank: Rank.values.firstWhere(
        (e) => e.toString().split('.').last == map['rank'],
        orElse: () => Rank.private,
      ),
      unit: map['unit'],
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
    Rank? rank,
    String? unit,
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
      rank: rank ?? this.rank,
      unit: unit ?? this.unit,
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
}
