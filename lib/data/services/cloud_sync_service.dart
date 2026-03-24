import 'dart:io' as io;
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/phonics_unit.dart';
import '../repositories/lesson_repository.dart';
import '../models/word_example.dart';

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
        
        try {
          PhonicsUnit cloudUnit = PhonicsUnit.fromJson(data);
          
          if (cloudUnit.isDeleted) {
            final existingUnit = await _repository.getUnitById(cloudUnit.id);
            if (existingUnit != null && _repository.canDeleteUnit(cloudUnit.id)) {
              await _repository.deleteUnit(cloudUnit.id);
              deletedCount++;
            }
          } else {
            final existingUnit = await _repository.getUnitById(cloudUnit.id);
            
            bool shouldUpdate = false;
            if (existingUnit == null) {
              shouldUpdate = true;
            } else if (existingUnit.updatedAt == null) {
              shouldUpdate = true;
            } else if (cloudUnit.updatedAt != null && cloudUnit.updatedAt!.isAfter(existingUnit.updatedAt!)) {
              shouldUpdate = true;
            } else {
              skippedCount++;
            }

            if (shouldUpdate) {
              print('Sync: Downloading media for unit ${cloudUnit.id}...');
              
              // 1. Download Letter Audio if it's a URL
              if (cloudUnit.letterAudio != null && cloudUnit.letterAudio!.startsWith('http')) {
                final localPath = await _downloadAndSaveMedia(
                  cloudUnit.letterAudio!, 
                  'letter_audio', 
                  cloudUnit.id
                );
                if (localPath != null) {
                  cloudUnit = cloudUnit.copyWith(letterAudio: localPath);
                }
              }

              // 2. Download Example media
              List<WordExample> updatedExamples = [];
              for (var example in cloudUnit.examples) {
                String imgPath = example.imageAsset;
                String audPath = example.audioAsset;

                if (imgPath.startsWith('http')) {
                  final localImg = await _downloadAndSaveMedia(imgPath, 'images', example.id);
                  if (localImg != null) imgPath = localImg;
                }

                if (audPath.startsWith('http')) {
                  final localAud = await _downloadAndSaveMedia(audPath, 'audio', example.id);
                  if (localAud != null) audPath = localAud;
                }

                updatedExamples.add(example.copyWith(
                  imageAsset: imgPath,
                  audioAsset: audPath,
                ));
              }

              cloudUnit = cloudUnit.copyWith(examples: updatedExamples);

              await _repository.updateLesson(cloudUnit);
              newOrUpdatedCount++;
              print('Sync: Unit ${cloudUnit.id} synchronized offline.');
            }
          }
        } catch (e) {
          print('Sync Error processing unit ${doc.id}: $e');
        }
      }

      _updateStatus(false, 'Sync Complete! ($newOrUpdatedCount updated, $skippedCount skipped, $deletedCount removed)');
    } catch (e) {
      print('Sync Error: $e');
      _updateStatus(false, 'Sync failed: $e');
    }
  }

  /// Download a file from a URL and save it to local storage
  Future<String?> _downloadAndSaveMedia(String url, String subDir, String id) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final appDir = await getApplicationDocumentsDirectory();
        final mediaDir = io.Directory('${appDir.path}/offline_media/$subDir');
        if (!await mediaDir.exists()) {
          await mediaDir.create(recursive: true);
        }

        // Extract extension from URL or use default
        String ext = p.extension(Uri.parse(url).path);
        if (ext.isEmpty) {
          if (subDir == 'images') ext = '.png';
          else ext = '.m4a';
        }

        final fileName = '${id}_${DateTime.now().millisecondsSinceEpoch}$ext';
        final file = io.File('${mediaDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        
        print('Sync: Downloaded $url to ${file.path}');
        return file.path;
      } else {
        print('Sync: Failed to download $url - Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Sync: Error downloading $url: $e');
      return null;
    }
  }

  void _updateStatus(bool isSyncing, String message) {
    _isSyncing = isSyncing;
    _syncStatusMessage = message;
    notifyListeners();
  }
}

