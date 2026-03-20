import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'data/local/json_loader.dart';
import 'data/models/language.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(home: UploadScreen()));
}

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String status = "Ready to upload data to Firestore";
  bool isUploading = false;

  Future<void> uploadData() async {
    setState(() {
      status = "Starting upload...";
      isUploading = true;
    });

    try {
      final db = FirebaseFirestore.instance;
      
      for (var language in LanguageType.values) {
        setState(() => status = "Uploading categories for ${language.name}...");
        
        // Upload categories (don't include massive nested units here, just base info)
        final categories = await JsonLoader.getCategoriesByLanguage(language);
        for (var category in categories) {
          // Store category document
          final catData = category.toJson();
          catData.remove('units'); // We will store units in a separate collection for easier querying
          catData['language'] = language.name; // Tag with language
          await db.collection('categories').doc('${language.name}_${category.id}').set(catData);
        }

        setState(() => status = "Uploading units for ${language.name}...");
        
        // Upload individual units
        final units = await JsonLoader.getUnitsByLanguage(language);
        for (var unit in units) {
           await db.collection('phonics_units').doc(unit.id).set(unit.toJson());
        }
      }

      setState(() {
        status = "Upload complete! You can check Firebase Console.";
        isUploading = false;
      });
    } catch (e) {
      setState(() {
        status = "Error: $e";
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Data Initializer')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_upload, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                status, 
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (isUploading) 
                const CircularProgressIndicator()
              else 
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload),
                  label: const Text('Start Upload Base Data'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  onPressed: uploadData,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
