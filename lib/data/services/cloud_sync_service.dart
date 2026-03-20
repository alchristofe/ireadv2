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
      final snapshot = await _firestore.collection('phonics_units').get();
      final cloudUnits = snapshot.docs;

      int newOrUpdatedCount = 0;
      int deletedCount = 0;

      for (var doc in cloudUnits) {
        final data = doc.data();
        // Fallback for ID since documents before sync might not have 'id' inside the data map
        data['id'] = data['id'] ?? doc.id; 
        
        try {
          final cloudUnit = PhonicsUnit.fromJson(data);
          
          if (cloudUnit.isDeleted) {
            // Remove from local storage
            final existingUnit = await _repository.getUnitById(cloudUnit.id);
            if (existingUnit != null && _repository.canDeleteUnit(cloudUnit.id)) {
              await _repository.deleteUnit(cloudUnit.id);
              deletedCount++;
            }
          } else {
            // Update or add locally
            final existingUnit = await _repository.getUnitById(cloudUnit.id);
            
            // For now, cloud is source of truth. We just overwrite.
            // In a robust offline-first app, you'd compare `updatedAt` timestamps.
            if (existingUnit == null || 
                (cloudUnit.updatedAt != null && existingUnit.updatedAt != null && cloudUnit.updatedAt!.isAfter(existingUnit.updatedAt!)) ||
                existingUnit.updatedAt == null) {
              await _repository.updateLesson(cloudUnit);
              newOrUpdatedCount++;
            }
          }
        } catch (e) {
          debugPrint('Sync Error parsing unit ${doc.id}: $e');
        }
      }

      _updateStatus(false, 'Sync Complete! ($newOrUpdatedCount updated, $deletedCount removed)');
    } catch (e) {
      debugPrint('Sync Error: $e');
      _updateStatus(false, 'Sync failed. Please check connection.');
    }
  }

  void _updateStatus(bool isSyncing, String message) {
    _isSyncing = isSyncing;
    _syncStatusMessage = message;
    notifyListeners();
  }
}

