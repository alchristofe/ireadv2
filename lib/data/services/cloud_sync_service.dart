import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/phonics_unit.dart';
import '../repositories/lesson_repository.dart';

class CloudSyncService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LessonRepository _repository;
  bool _isSyncing = false;
  String _syncStatusMessage = '';

  bool get isSyncing => _isSyncing;
  String get syncStatusMessage => _syncStatusMessage;

  CloudSyncService(this._repository);

  /// Synchronize local storage with Firestore
  Future<void> syncWithCloud() async {
    if (_isSyncing) return;

    _updateStatus(true, 'Starting sync with Cloud...');

    try {
      print('Sync: Fetching from Firestore...');
      final snapshot = await _firestore.collection('phonics_units').get();
      final cloudUnits = snapshot.docs;
      print('Sync: Found ${cloudUnits.length} units in cloud.');

      int newOrUpdatedCount = 0;
      int skippedCount = 0;
      int deletedCount = 0;

      for (var doc in cloudUnits) {
        final data = doc.data();
        data['id'] = data['id'] ?? doc.id; 
        print('Sync: Processing unit ${doc.id}');
        print('Sync: Data keys: ${data.keys.toList()}');
        
        try {
          final cloudUnit = PhonicsUnit.fromJson(data);
          print('Sync: Unit ${cloudUnit.id} parsed. Examples count: ${cloudUnit.examples.length}');
          if (cloudUnit.examples.isNotEmpty) {
            final example = cloudUnit.examples.first;
            print('Sync: Example ${example.word} -> Image: ${example.imageAsset}, Audio: ${example.audioAsset}');
          }
          
          if (cloudUnit.isDeleted) {
            final existingUnit = await _repository.getUnitById(cloudUnit.id);
            if (existingUnit != null && _repository.canDeleteUnit(cloudUnit.id)) {
              await _repository.deleteUnit(cloudUnit.id);
              deletedCount++;
              print('Sync: Deleted ${cloudUnit.id}');
            }
          } else {
            final existingUnit = await _repository.getUnitById(cloudUnit.id);
            
            bool shouldUpdate = false;
            if (existingUnit == null) {
              shouldUpdate = true;
              print('Sync: New unit found ${cloudUnit.id}');
            } else if (existingUnit.updatedAt == null) {
              shouldUpdate = true;
              print('Sync: Unit ${cloudUnit.id} has no local timestamp, updating.');
            } else if (cloudUnit.updatedAt != null && cloudUnit.updatedAt!.isAfter(existingUnit.updatedAt!)) {
              shouldUpdate = true;
              print('Sync: Unit ${cloudUnit.id} is newer in cloud (${cloudUnit.updatedAt}) vs local (${existingUnit.updatedAt})');
            } else {
              skippedCount++;
              print('Sync: Skipping unit ${cloudUnit.id} (already up to date)');
            }

            if (shouldUpdate) {
              await _repository.updateLesson(cloudUnit);
              newOrUpdatedCount++;
            }
          }
        } catch (e) {
          print('Sync Error parsing unit ${doc.id}: $e');
        }
      }

      _updateStatus(false, 'Sync Complete! ($newOrUpdatedCount updated, $skippedCount skipped, $deletedCount removed)');
    } catch (e) {
      print('Sync Error: $e');
      _updateStatus(false, 'Sync failed: $e');
    }
  }

  void _updateStatus(bool isSyncing, String message) {
    _isSyncing = isSyncing;
    _syncStatusMessage = message;
    notifyListeners();
  }
}

