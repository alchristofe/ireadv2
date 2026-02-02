import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iread/core/constants/app_colors.dart';
import 'package:iread/core/constants/app_text_styles.dart';
import 'package:iread/core/widgets/custom_button.dart';
import 'package:iread/data/models/language.dart';
import 'package:iread/data/models/phonics_unit.dart';
import 'package:iread/data/models/word_example.dart';
import 'package:iread/data/repositories/lesson_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:iread/core/utils/audio_player_util.dart';
import 'package:iread/core/utils/background_music_manager.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;

/// Screen for adding or editing a Phonics Unit
class UnitEditorScreen extends StatefulWidget {
  final PhonicsUnit? unit; // If null, creating new unit

  const UnitEditorScreen({super.key, this.unit});

  @override
  State<UnitEditorScreen> createState() => _UnitEditorScreenState();
}

class _UnitEditorScreenState extends State<UnitEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = LessonRepository();

  late TextEditingController _letterController;
  late TextEditingController _soundController;
  late TextEditingController _descriptionController;
  List<WordExample> _examples = [];
  String? _letterAudioPath;
  String? _letterAudioFileName;
  bool _isSaving = false;

  // Recording state
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  // Default selections
  LanguageType _selectedLanguage = LanguageType.english;
  String _selectedCategory = 'vowels';

  @override
  void initState() {
    super.initState();
    _letterController = TextEditingController(text: widget.unit?.letter ?? '');
    _soundController = TextEditingController(text: widget.unit?.sound ?? '');
    _descriptionController = TextEditingController(
      text: widget.unit?.description ?? '',
    );
    _examples = widget.unit?.examples ?? [];

    if (widget.unit != null) {
      _selectedLanguage = widget.unit!.language;
      // Extract category type from ID (e.g., "eng_vowels" -> "vowels")
      if (widget.unit!.categoryId.contains('vowels')) {
        _selectedCategory = 'vowels';
      } else if (widget.unit!.categoryId.contains('consonants')) {
        _selectedCategory = 'consonants';
      } else if (widget.unit!.categoryId.contains('blends')) {
        _selectedCategory = 'blends';
      }

      _letterAudioPath = widget.unit!.letterAudio;
      if (_letterAudioPath != null &&
          _letterAudioPath!.isNotEmpty &&
          !_letterAudioPath!.startsWith('assets/')) {
        _letterAudioFileName = _letterAudioPath!.split('/').last;
      }
    }
  }

  @override
  void dispose() {
    if (_isRecording) {
      BackgroundMusicManager.instance.unmuteAfterSpeech();
    }
    _letterController.dispose();
    _soundController.dispose();
    _descriptionController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await Permission.microphone.request().isGranted) {
        // Mute background music
        await BackgroundMusicManager.instance.muteForSpeech();

        if (!kIsWeb) {
          final appDir = await getApplicationDocumentsDirectory();
          final audioDir = io.Directory('${appDir.path}/audio');
          if (!await audioDir.exists()) {
            await audioDir.create(recursive: true);
          }
          final fileName = 'record_${const Uuid().v4()}.m4a';
          final filePath = '${audioDir.path}/$fileName';

          await _audioRecorder.start(const RecordConfig(), path: filePath);
        } else {
          // Fallback for web recording or just disable for now
          await _audioRecorder.start(
            const RecordConfig(),
            path: '', // Record will handle pathing on web
          );
        }
        setState(() {
          _isRecording = true;
          _letterAudioPath = null; // Clear previous audio path
          _letterAudioFileName = null;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission not granted')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error starting recording: $e')));
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      // Unmute background music
      await BackgroundMusicManager.instance.unmuteAfterSpeech();

      if (path != null) {
        setState(() {
          _letterAudioPath = path;
          _letterAudioFileName = path.split('/').last;
          _isRecording = false;
        });
      }
    } catch (e) {
      // Ensure unmuted even on error
      await BackgroundMusicManager.instance.unmuteAfterSpeech();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error stopping recording: $e')));
    }
  }

  Future<void> _saveUnit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final unitId = widget.unit?.id ?? const Uuid().v4();
      // Generate category ID based on convention (e.g., eng_vowels, fil_consonants)
      final langPrefix = _selectedLanguage == LanguageType.english
          ? 'eng'
          : 'fil';
      final categoryId = '${langPrefix}_$_selectedCategory';

      final newUnit = PhonicsUnit(
        id: unitId,
        letter: _letterController.text.trim().toLowerCase(),
        sound: _soundController.text.trim(),
        description: _descriptionController.text.trim(),
        examples: _examples,
        categoryId: categoryId,
        language: _selectedLanguage,
        letterAudio: _letterAudioPath,
      );

      await _repository.updateLesson(newUnit);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unit saved successfully!')),
        );
        context.pop(true); // Return true to indicate refresh needed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving unit: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickLetterAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final pickedFile = io.File(result.files.single.path!);

        // Copy file to app's document directory
        final appDir = await getApplicationDocumentsDirectory();
        final audioDir = io.Directory('${appDir.path}/audio');
        if (!await audioDir.exists()) {
          await audioDir.create(recursive: true);
        }

        final fileName =
            'letter_${const Uuid().v4()}.${result.files.single.extension ?? 'mp3'}';
        final savedFile = await pickedFile.copy('${audioDir.path}/$fileName');

        setState(() {
          _letterAudioPath = savedFile.path;
          _letterAudioFileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking audio: $e')));
    }
  }

  Future<void> _previewLetterAudio() async {
    if (_letterAudioPath != null && _letterAudioPath!.isNotEmpty) {
      await AudioPlayerUtil.playAudio(_letterAudioPath!);
    }
  }

  void _addOrEditWord([WordExample? word]) async {
    final result = await showDialog<WordExample>(
      context: context,
      builder: (context) =>
          WordEditorDialog(word: word, language: _selectedLanguage),
    );

    if (result != null) {
      setState(() {
        if (word != null) {
          // Edit existing
          final index = _examples.indexWhere((w) => w.id == word.id);
          if (index != -1) {
            _examples[index] = result;
          }
        } else {
          // Add new
          _examples.add(result);
        }
      });
    }
  }

  void _deleteWord(WordExample word) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Word'),
        content: Text('Are you sure you want to delete "${word.word}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _examples.removeWhere((w) => w.id == word.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          widget.unit == null ? 'Add New Unit' : 'Edit Unit',
          style: AppTextStyles.heading3.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Language Dropdown
            DropdownButtonFormField<LanguageType>(
              initialValue: _selectedLanguage,
              decoration: const InputDecoration(
                labelText: 'Language',
                border: OutlineInputBorder(),
              ),
              items: LanguageType.values.map((lang) {
                return DropdownMenuItem(
                  value: lang,
                  child: Text(lang.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedLanguage = value);
              },
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: 'vowels', child: Text('Vowels')),
                const DropdownMenuItem(
                  value: 'consonants',
                  child: Text('Consonants'),
                ),
                DropdownMenuItem(
                  value: 'blends',
                  child: Text(
                    _selectedLanguage == LanguageType.english
                        ? 'Consonant Blends'
                        : 'Kambal-katinig',
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
            ),
            const SizedBox(height: 16),

            // Letter Input
            TextFormField(
              controller: _letterController,
              decoration: const InputDecoration(
                labelText: 'Letter (e.g., a, b, ch)',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Sound Input
            TextFormField(
              controller: _soundController,
              decoration: const InputDecoration(
                labelText: 'Sound (Pronunciation guide)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Letter Audio Section
            Text('Letter Audio', style: AppTextStyles.bodyLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                if (_isRecording) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _stopRecording,
                      icon: const Icon(Icons.stop, color: Colors.white),
                      label: const Text('Stop Recording'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickLetterAudio,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _startRecording,
                      icon: const Icon(Icons.mic),
                      label: const Text('Record'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (_letterAudioPath != null && !_isRecording) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.audiotrack, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _letterAudioFileName ?? 'Audio File',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: _previewLetterAudio,
                      icon: const Icon(
                        Icons.play_circle,
                        color: AppColors.primary,
                      ),
                      tooltip: 'Preview',
                    ),
                    IconButton(
                      onPressed: () => setState(() {
                        _letterAudioPath = null;
                        _letterAudioFileName = null;
                      }),
                      icon: const Icon(Icons.close, color: Colors.red),
                      tooltip: 'Remove',
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Description Input
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            // Word Examples Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Word Examples', style: AppTextStyles.heading3),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  onPressed: () => _addOrEditWord(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_examples.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No words added yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ..._examples.map(
                (word) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: word.imageAsset.isNotEmpty
                        ? Image.asset(
                            word.imageAsset,
                            width: 40,
                            height: 40,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image),
                          )
                        : const Icon(Icons.image_not_supported),
                    title: Text(word.word),
                    subtitle: Text(word.phonetic),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _addOrEditWord(word),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteWord(word),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Save Button
            CustomButton(
              text: _isSaving ? 'Saving...' : 'Save Unit',
              onPressed: _isSaving ? null : _saveUnit,
              backgroundColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for adding/editing a word
class WordEditorDialog extends StatefulWidget {
  final WordExample? word;
  final LanguageType language;

  const WordEditorDialog({super.key, this.word, required this.language});

  @override
  State<WordEditorDialog> createState() => _WordEditorDialogState();
}

class _WordEditorDialogState extends State<WordEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _wordController;
  late TextEditingController _phoneticController;

  String? _imagePath;
  String? _audioPath;
  String? _audioFileName;
  final ImagePicker _picker = ImagePicker();

  // Recording state
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(text: widget.word?.word ?? '');
    _phoneticController = TextEditingController(
      text: widget.word?.phonetic ?? '',
    );
    _imagePath = widget.word?.imageAsset;
    _audioPath = widget.word?.audioAsset;

    // Extract filename if it's a local path
    if (_audioPath != null &&
        _audioPath!.isNotEmpty &&
        !_audioPath!.startsWith('assets/')) {
      _audioFileName = _audioPath!.split('/').last;
    }
  }

  @override
  void dispose() {
    if (_isRecording) {
      BackgroundMusicManager.instance.unmuteAfterSpeech();
    }
    _wordController.dispose();
    _phoneticController.dispose();
    _audioRecorder.dispose();
    AudioPlayerUtil.stopAudio();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await Permission.microphone.request().isGranted) {
        // Mute background music
        await BackgroundMusicManager.instance.muteForSpeech();

        if (!kIsWeb) {
          final appDir = await getApplicationDocumentsDirectory();
          final audioDir = io.Directory('${appDir.path}/audio');
          if (!await audioDir.exists()) {
            await audioDir.create(recursive: true);
          }
          final fileName = 'word_${const Uuid().v4()}.m4a';
          final filePath = '${audioDir.path}/$fileName';

          await _audioRecorder.start(const RecordConfig(), path: filePath);
        } else {
          await _audioRecorder.start(const RecordConfig(), path: '');
        }
        setState(() {
          _isRecording = true;
          _audioPath = null;
          _audioFileName = null;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission not granted')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error starting recording: $e')));
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      // Unmute background music
      await BackgroundMusicManager.instance.unmuteAfterSpeech();

      if (path != null) {
        setState(() {
          _audioPath = path;
          _audioFileName = path.split('/').last;
          _isRecording = false;
        });
      }
    } catch (e) {
      // Ensure unmuted even on error
      await BackgroundMusicManager.instance.unmuteAfterSpeech();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error stopping recording: $e')));
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: AppColors.primary,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
            ),
            IOSUiSettings(title: 'Crop Image', aspectRatioLockEnabled: true),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            _imagePath = croppedFile.path;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final pickedFile = io.File(result.files.single.path!);

        // Copy file to app's document directory
        final appDir = await getApplicationDocumentsDirectory();
        final audioDir = io.Directory('${appDir.path}/audio');
        if (!await audioDir.exists()) {
          await audioDir.create(recursive: true);
        }

        final fileName =
            '${const Uuid().v4()}.${result.files.single.extension ?? 'mp3'}';
        final savedFile = await pickedFile.copy('${audioDir.path}/$fileName');

        setState(() {
          _audioPath = savedFile.path;
          _audioFileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking audio: $e')));
    }
  }

  Future<void> _previewAudio() async {
    if (_audioPath != null && _audioPath!.isNotEmpty) {
      await AudioPlayerUtil.playAudio(_audioPath!);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final newWord = WordExample(
      id: widget.word?.id ?? const Uuid().v4(),
      word: _wordController.text.trim(),
      phonetic: _phoneticController.text.trim(),
      imageAsset: _imagePath ?? '',
      audioAsset: _audioPath ?? '',
      language: widget.language,
    );

    Navigator.pop(context, newWord);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.word == null ? 'Add Word' : 'Edit Word'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image Preview & Picker
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Take Photo'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.camera);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Choose from Gallery'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                    image: _imagePath != null && _imagePath!.isNotEmpty
                        ? DecorationImage(
                            image: _imagePath!.startsWith('assets/')
                                ? AssetImage(_imagePath!) as ImageProvider
                                : (!kIsWeb
                                      ? FileImage(io.File(_imagePath!))
                                      : NetworkImage(_imagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imagePath == null || _imagePath!.isEmpty
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 32,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Add Image',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _wordController,
                decoration: const InputDecoration(labelText: 'Word'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _phoneticController,
                decoration: const InputDecoration(
                  labelText: 'Phonetic (optional)',
                ),
              ),
              const SizedBox(height: 16),

              // Audio Upload Section
              Row(
                children: [
                  if (_isRecording) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _stopRecording,
                        icon: const Icon(Icons.stop, color: Colors.white),
                        label: const Text('Stop Recording'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickAudioFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _startRecording,
                        icon: const Icon(Icons.mic),
                        label: const Text('Record'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (_audioPath != null && !_isRecording) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.audiotrack,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _audioFileName ?? 'Audio File',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: _previewAudio,
                        icon: const Icon(
                          Icons.play_circle,
                          color: AppColors.primary,
                        ),
                        tooltip: 'Preview',
                      ),
                      IconButton(
                        onPressed: () => setState(() {
                          _audioPath = null;
                          _audioFileName = null;
                        }),
                        icon: const Icon(Icons.close, color: Colors.red),
                        tooltip: 'Remove',
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
