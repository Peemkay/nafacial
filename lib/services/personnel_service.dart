import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/personnel_model.dart';

class PersonnelService {
  // Key constants
  static const String _personnelKey = 'personnel_data';

  // Sample personnel data for demonstration
  final List<Personnel> _samplePersonnel = [
    Personnel(
      id: '1',
      armyNumber: 'N/12345',
      fullName: 'John Smith',
      rank: Rank.captain,
      unit: 'Infantry Division',
      category: PersonnelCategory.officerMale,
      dateRegistered: DateTime.now().subtract(const Duration(days: 365)),
      lastVerified: DateTime.now().subtract(const Duration(days: 30)),
      status: VerificationStatus.verified,
      serviceStatus: ServiceStatus.active,
      dateOfBirth: DateTime(1985, 5, 15),
      enlistmentDate: DateTime(2010, 3, 10),
    ),
    Personnel(
      id: '2',
      armyNumber: 'N/54321F',
      fullName: 'Jane Doe',
      rank: Rank.lieutenant,
      unit: 'Medical Corps',
      category: PersonnelCategory.officerFemale,
      dateRegistered: DateTime.now().subtract(const Duration(days: 180)),
      status: VerificationStatus.verified,
      serviceStatus: ServiceStatus.retired,
      dateOfBirth: DateTime(1988, 8, 22),
      enlistmentDate: DateTime(2012, 6, 15),
    ),
    Personnel(
      id: '3',
      armyNumber: '12NA/67/32451',
      fullName: 'Michael Johnson',
      rank: Rank.sergeant,
      unit: 'Artillery Regiment',
      category: PersonnelCategory.soldierMale,
      dateRegistered: DateTime.now().subtract(const Duration(days: 90)),
      status: VerificationStatus.pending,
      serviceStatus: ServiceStatus.awol,
      dateOfBirth: DateTime(1990, 3, 5),
      enlistmentDate: DateTime(2015, 9, 20),
    ),
    Personnel(
      id: '4',
      armyNumber: '15NA/72/98765F',
      fullName: 'Sarah Williams',
      rank: Rank.corporal,
      unit: 'Signal Corps',
      category: PersonnelCategory.soldierFemale,
      dateRegistered: DateTime.now().subtract(const Duration(days: 45)),
      status: VerificationStatus.pending,
      serviceStatus: ServiceStatus.dismissed,
      dateOfBirth: DateTime(1992, 11, 18),
      enlistmentDate: DateTime(2017, 2, 5),
    ),
  ];

  // Initialize the personnel service
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPersonnel = prefs.containsKey(_personnelKey);

    if (!hasPersonnel) {
      // Store sample personnel if no personnel exist
      final personnelJson =
          jsonEncode(_samplePersonnel.map((p) => p.toMap()).toList());
      await prefs.setString(_personnelKey, personnelJson);
    }
  }

  // Get all personnel
  Future<List<Personnel>> getAllPersonnel() async {
    final prefs = await SharedPreferences.getInstance();
    final personnelJson = prefs.getString(_personnelKey);

    if (personnelJson == null) {
      return [];
    }

    final List<dynamic> personnelList = jsonDecode(personnelJson);
    return personnelList.map((p) => Personnel.fromMap(p)).toList();
  }

  // Get personnel by category
  Future<List<Personnel>> getPersonnelByCategory(
      PersonnelCategory category) async {
    final allPersonnel = await getAllPersonnel();
    return allPersonnel.where((p) => p.category == category).toList();
  }

  // Get personnel by army number
  Future<Personnel?> getPersonnelByArmyNumber(String armyNumber) async {
    final allPersonnel = await getAllPersonnel();
    try {
      return allPersonnel.firstWhere((p) => p.armyNumber == armyNumber);
    } catch (e) {
      return null;
    }
  }

  // Search personnel by name, rank, or unit
  Future<List<Personnel>> searchPersonnel(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final allPersonnel = await getAllPersonnel();
    final lowerQuery = query.toLowerCase();

    return allPersonnel.where((p) {
      return p.fullName.toLowerCase().contains(lowerQuery) ||
          p.rank.displayName.toLowerCase().contains(lowerQuery) ||
          p.unit.toLowerCase().contains(lowerQuery) ||
          p.armyNumber.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Add new personnel
  Future<Personnel> addPersonnel({
    required String armyNumber,
    required String fullName,
    required Rank rank,
    required String unit,
    String? photoUrl,
    String? notes,
    ServiceStatus serviceStatus = ServiceStatus.active,
    DateTime? dateOfBirth,
    DateTime? enlistmentDate,
  }) async {
    // Validate army number
    if (!Personnel.isValidArmyNumber(armyNumber)) {
      throw Exception('Invalid army number format');
    }

    // Get category from army number
    final category = Personnel.getCategoryFromArmyNumber(armyNumber);

    // Check if personnel with this army number already exists
    final existingPersonnel = await getPersonnelByArmyNumber(armyNumber);
    if (existingPersonnel != null) {
      throw Exception('Personnel with this army number already exists');
    }

    // Create new personnel
    final newPersonnel = Personnel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      armyNumber: armyNumber,
      fullName: fullName,
      rank: rank,
      unit: unit,
      category: category,
      photoUrl: photoUrl,
      dateRegistered: DateTime.now(),
      notes: notes,
      serviceStatus: serviceStatus,
      dateOfBirth: dateOfBirth,
      enlistmentDate: enlistmentDate,
    );

    // Add to list and save
    final allPersonnel = await getAllPersonnel();
    allPersonnel.add(newPersonnel);
    await _savePersonnel(allPersonnel);

    return newPersonnel;
  }

  // Update personnel
  Future<Personnel> updatePersonnel(Personnel personnel) async {
    final allPersonnel = await getAllPersonnel();
    final index = allPersonnel.indexWhere((p) => p.id == personnel.id);

    if (index < 0) {
      throw Exception('Personnel not found');
    }

    allPersonnel[index] = personnel;
    await _savePersonnel(allPersonnel);

    return personnel;
  }

  // Update verification status
  Future<Personnel> updateVerificationStatus(
    String personnelId,
    VerificationStatus status,
  ) async {
    final allPersonnel = await getAllPersonnel();
    final index = allPersonnel.indexWhere((p) => p.id == personnelId);

    if (index < 0) {
      throw Exception('Personnel not found');
    }

    final updatedPersonnel = allPersonnel[index].copyWith(
      status: status,
      lastVerified:
          status == VerificationStatus.verified ? DateTime.now() : null,
    );

    allPersonnel[index] = updatedPersonnel;
    await _savePersonnel(allPersonnel);

    return updatedPersonnel;
  }

  // Delete personnel
  Future<void> deletePersonnel(String personnelId) async {
    final allPersonnel = await getAllPersonnel();
    final filteredPersonnel =
        allPersonnel.where((p) => p.id != personnelId).toList();

    if (filteredPersonnel.length == allPersonnel.length) {
      throw Exception('Personnel not found');
    }

    await _savePersonnel(filteredPersonnel);
  }

  // Save personnel list
  Future<void> _savePersonnel(List<Personnel> personnelList) async {
    final prefs = await SharedPreferences.getInstance();
    final personnelJson =
        jsonEncode(personnelList.map((p) => p.toMap()).toList());
    await prefs.setString(_personnelKey, personnelJson);
  }

  // Save personnel photo
  Future<String> savePersonnelPhoto(String personnelId, File photoFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/personnel_photos';

    // Create directory if it doesn't exist
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Generate unique filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '$personnelId-$timestamp.jpg';
    final filePath = '$path/$fileName';

    // Copy file to app directory
    await photoFile.copy(filePath);

    // Update personnel with photo URL
    final allPersonnel = await getAllPersonnel();
    final index = allPersonnel.indexWhere((p) => p.id == personnelId);

    if (index < 0) {
      throw Exception('Personnel not found');
    }

    final updatedPersonnel = allPersonnel[index].copyWith(
      photoUrl: filePath,
    );

    allPersonnel[index] = updatedPersonnel;
    await _savePersonnel(allPersonnel);

    return filePath;
  }
}
