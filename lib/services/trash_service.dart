import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trash_model.dart';
import '../models/personnel_model.dart';
import '../services/personnel_service.dart';

class TrashService {
  // Key constants
  static const String _trashKey = 'trash_data';
  
  // Services
  final PersonnelService _personnelService = PersonnelService();
  
  // Initialize the trash service
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final hasTrash = prefs.containsKey(_trashKey);

    if (!hasTrash) {
      // Initialize with empty trash list
      await prefs.setString(_trashKey, jsonEncode([]));
    }
  }
  
  // Get all trash items
  Future<List<TrashItem>> getAllTrashItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trashJson = prefs.getString(_trashKey);
      
      if (trashJson == null || trashJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> trashList = jsonDecode(trashJson);
      return trashList.map((item) => TrashItem.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error getting trash items: $e');
      return [];
    }
  }
  
  // Get trash items by entity type
  Future<List<TrashItem>> getTrashItemsByType(String entityType) async {
    final allItems = await getAllTrashItems();
    return allItems.where((item) => item.entityType == entityType).toList();
  }
  
  // Get personnel trash items
  Future<List<TrashItem>> getPersonnelTrashItems() async {
    return getTrashItemsByType('personnel');
  }
  
  // Move a personnel to trash
  Future<TrashItem?> movePersonnelToTrash({
    required Personnel personnel,
    required String deletedBy,
    required String deletedByName,
    String? deletedByArmyNumber,
  }) async {
    try {
      // Create a trash item from the personnel
      final trashItem = TrashItem.fromPersonnel(
        personnel: personnel,
        deletedBy: deletedBy,
        deletedByName: deletedByName,
        deletedByArmyNumber: deletedByArmyNumber,
      );
      
      // Add the trash item to the trash
      await addTrashItem(trashItem);
      
      // Delete the personnel from the database
      await _personnelService.deletePersonnel(personnel.id);
      
      return trashItem;
    } catch (e) {
      debugPrint('Error moving personnel to trash: $e');
      return null;
    }
  }
  
  // Add a trash item
  Future<void> addTrashItem(TrashItem item) async {
    try {
      final allItems = await getAllTrashItems();
      allItems.add(item);
      await _saveTrashItems(allItems);
    } catch (e) {
      debugPrint('Error adding trash item: $e');
    }
  }
  
  // Restore a personnel from trash
  Future<Personnel?> restorePersonnelFromTrash(String trashItemId) async {
    try {
      final allItems = await getAllTrashItems();
      final index = allItems.indexWhere((item) => item.id == trashItemId);
      
      if (index == -1) {
        throw Exception('Trash item not found');
      }
      
      final trashItem = allItems[index];
      
      if (trashItem.entityType != 'personnel') {
        throw Exception('Trash item is not a personnel');
      }
      
      // Convert trash item to personnel
      final personnel = trashItem.toPersonnel();
      
      if (personnel == null) {
        throw Exception('Failed to convert trash item to personnel');
      }
      
      // Check if a personnel with the same army number already exists
      final existingPersonnel = await _personnelService.getPersonnelByArmyNumber(personnel.armyNumber);
      
      if (existingPersonnel != null) {
        throw Exception('A personnel with the same army number already exists');
      }
      
      // Add the personnel back to the database
      await _personnelService.addPersonnelFromJson(personnel.toJson());
      
      // Remove the trash item
      allItems.removeAt(index);
      await _saveTrashItems(allItems);
      
      return personnel;
    } catch (e) {
      debugPrint('Error restoring personnel from trash: $e');
      return null;
    }
  }
  
  // Permanently delete a trash item
  Future<bool> permanentlyDeleteTrashItem(String trashItemId) async {
    try {
      final allItems = await getAllTrashItems();
      final index = allItems.indexWhere((item) => item.id == trashItemId);
      
      if (index == -1) {
        throw Exception('Trash item not found');
      }
      
      // Remove the trash item
      allItems.removeAt(index);
      await _saveTrashItems(allItems);
      
      return true;
    } catch (e) {
      debugPrint('Error permanently deleting trash item: $e');
      return false;
    }
  }
  
  // Empty the trash (permanently delete all items)
  Future<bool> emptyTrash() async {
    try {
      await _saveTrashItems([]);
      return true;
    } catch (e) {
      debugPrint('Error emptying trash: $e');
      return false;
    }
  }
  
  // Save trash items
  Future<void> _saveTrashItems(List<TrashItem> trashItems) async {
    final prefs = await SharedPreferences.getInstance();
    final trashJson = jsonEncode(trashItems.map((item) => item.toMap()).toList());
    await prefs.setString(_trashKey, trashJson);
  }
}
