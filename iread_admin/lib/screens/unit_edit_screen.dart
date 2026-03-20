import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/language.dart';
import '../data/models/phonics_unit.dart';
import '../data/models/word_example.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/widgets/custom_button.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:uuid/uuid.dart';

class UnitEditScreen extends StatefulWidget {
  final LanguageType language;
  final PhonicsUnit? unit;
  final bool isMobile;

  const UnitEditScreen({
    super.key,
    required this.language,
    this.unit,
    this.isMobile = false,
  });

  @override
  State<UnitEditScreen> createState() => _UnitEditScreenState();
}

class _UnitEditScreenState extends State<UnitEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  late TextEditingController _letterController;
  late TextEditingController _soundController;
  late TextEditingController _descriptionController;
  
  List<WordExample> _examples = [];
  bool _isLoading = false;
  String _selectedCategory = 'vowels';

  Uint8List? _letterAudioBytes;
  String? _letterAudioExtension;
  String? _letterAudioPath;
  bool _isPlayingLetterAudio = false;

  bool get isEditing => widget.unit != null;

  @override
  void initState() {
    super.initState();
    _letterController = TextEditingController(text: widget.unit?.letter ?? '');
    _soundController = TextEditingController(text: widget.unit?.sound ?? '');
    _descriptionController = TextEditingController(text: widget.unit?.description ?? '');
    _examples = widget.unit?.examples.toList() ?? [];
    _letterAudioPath = widget.unit?.letterAudio;

    if (widget.unit != null) {
      if (widget.unit!.categoryId.contains('vowels')) {
        _selectedCategory = 'vowels';
      } else if (widget.unit!.categoryId.contains('consonants')) {
        _selectedCategory = 'consonants';
      } else if (widget.unit!.categoryId.contains('blends')) {
        _selectedCategory = 'blends';
      }
    }

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingLetterAudio = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _letterController.dispose();
    _soundController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addOrEditWord([WordExample? word]) async {
    final result = await showDialog<WordExample>(
      context: context,
      builder: (context) => WordEditorDialog(word: word, language: widget.language),
    );

    if (result != null) {
      setState(() {
        if (word != null) {
          final index = _examples.indexWhere((w) => w.id == word.id);
          if (index != -1) {
            _examples[index] = result;
          }
        } else {
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

  Future<void> _toggleLetterAudio() async {
    if (_isPlayingLetterAudio) {
      await _audioPlayer.stop();
    } else {
      if (_letterAudioBytes != null) {
        await _audioPlayer.play(BytesSource(_letterAudioBytes!));
      } else if (_letterAudioPath != null && _letterAudioPath!.isNotEmpty) {
        await _audioPlayer.play(UrlSource(_letterAudioPath!));
      }
    }
  }

  Future<void> _pickLetterAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _letterAudioBytes = result.files.single.bytes;
        _letterAudioExtension = result.files.single.extension ?? 'mp3';
        _letterAudioPath = null;
      });
    }
  }

  Future<void> _saveUnit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final langPrefix = widget.language == LanguageType.english ? 'eng' : 'fil';
      final categoryId = '${langPrefix}_$_selectedCategory';

      String finalLetterAudioPath = _letterAudioPath ?? '';
      if (_letterAudioBytes != null) {
        final fileName = '${const Uuid().v4()}.${_letterAudioExtension ?? 'mp3'}';
        final ref = FirebaseStorage.instance.ref().child('audio/letters/$langPrefix/$fileName');
        final metadata = SettableMetadata(contentType: 'audio/$_letterAudioExtension');
        await ref.putData(_letterAudioBytes!, metadata);
        finalLetterAudioPath = await ref.getDownloadURL();
      }

      final unitData = {
        'letter': _letterController.text.trim().toLowerCase(),
        'sound': _soundController.text.trim(),
        'description': _descriptionController.text.trim(),
        'categoryId': categoryId,
        'language': widget.language.name,
        'examples': _examples.map((e) => e.toJson()).toList(),
        'letterAudio': finalLetterAudioPath,
        'isDeleted': false,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.unit == null) {
        // Create
        unitData['id'] = FirebaseFirestore.instance.collection('phonics_units').doc().id; 
        unitData['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('phonics_units').add(unitData);
      } else {
        // Update
        await FirebaseFirestore.instance.collection('phonics_units').doc(widget.unit!.id).update(unitData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unit saved successfully!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving unit: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Hero Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: widget.isMobile ? 24 : 40,
                vertical: widget.isMobile ? 32 : 48,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
              ),
              child: widget.isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context),
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEditing ? 'Edit Lesson' : 'New Lesson',
                              style: AppTextStyles.heading2(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Save Changes',
                          onPressed: _isLoading ? null : _saveUnit,
                          isLoading: _isLoading,
                          width: double.infinity,
                          height: 50,
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context),
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEditing ? 'Edit Lesson' : 'Create New Lesson',
                                  style: AppTextStyles.heading1(context),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Curriculum: ${widget.language.displayName}',
                                  style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textMedium),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (!_isLoading)
                          CustomButton(
                            text: 'Save Unit',
                            onPressed: _saveUnit,
                            backgroundColor: AppColors.success,
                            width: 200,
                            height: 54,
                          ),
                      ],
                    ),
            ),
            
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(widget.isMobile ? 20 : 40),
                  children: [
                    // --- Basic Information Card ---
                    _buildSectionCard(
                      title: 'Basic Information',
                      subtitle: 'General settings for this phonics unit',
                      icon: Icons.info_outline,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.isMobile
                              ? Column(
                                  children: [
                                    _buildStyledTextField(
                                      controller: _letterController,
                                      label: 'Letter (e.g., a, b, ch)',
                                      hint: 'Enter the letter or blend',
                                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildStyledDropdown<String>(
                                      value: _selectedCategory,
                                      label: 'Category',
                                      items: [
                                        const DropdownMenuItem(value: 'vowels', child: Text('Vowels')),
                                        const DropdownMenuItem(value: 'consonants', child: Text('Consonants')),
                                        DropdownMenuItem(
                                          value: 'blends',
                                          child: Text(
                                            widget.language == LanguageType.english
                                                ? 'Consonant Blends'
                                                : 'Kambal-katinig',
                                          ),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedCategory = val);
                                      },
                                    ),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _buildStyledTextField(
                                        controller: _letterController,
                                        label: 'Letter (e.g., a, b, ch)',
                                        hint: 'Enter the letter or blend',
                                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      flex: 3,
                                      child: _buildStyledDropdown<String>(
                                        value: _selectedCategory,
                                        label: 'Category',
                                        items: [
                                          const DropdownMenuItem(value: 'vowels', child: Text('Vowels')),
                                          const DropdownMenuItem(value: 'consonants', child: Text('Consonants')),
                                          DropdownMenuItem(
                                            value: 'blends',
                                            child: Text(
                                              widget.language == LanguageType.english
                                                  ? 'Consonant Blends'
                                                  : 'Kambal-katinig',
                                            ),
                                          ),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) setState(() => _selectedCategory = val);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 24),
                          _buildStyledTextField(
                            controller: _soundController,
                            label: 'Sound / Pronunciation',
                            hint: 'How is this letter pronounced?',
                          ),
                          const SizedBox(height: 24),
                          _buildStyledTextField(
                            controller: _descriptionController,
                            label: 'Description',
                            hint: 'Additional context for teachers',
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // --- Audio Content Card ---
                    _buildSectionCard(
                      title: 'Audio Content',
                      subtitle: 'The pronunciation sound for this unit',
                      icon: Icons.audiotrack_outlined,
                      child: widget.isMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          _letterAudioBytes != null || (_letterAudioPath != null && _letterAudioPath!.isNotEmpty)
                                              ? Icons.check_circle
                                              : Icons.audiotrack,
                                          size: 32,
                                          color: _letterAudioBytes != null || (_letterAudioPath != null && _letterAudioPath!.isNotEmpty)
                                              ? AppColors.success
                                              : AppColors.textLight,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        _letterAudioBytes != null || (_letterAudioPath != null && _letterAudioPath!.isNotEmpty)
                                            ? 'Audio file is ready'
                                            : 'No audio file uploaded',
                                        style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                CustomButton(
                                  text: _letterAudioBytes != null || (_letterAudioPath != null && _letterAudioPath!.isNotEmpty) 
                                    ? 'Replace Audio' : 'Upload MP3/WAV',
                                  onPressed: _pickLetterAudio,
                                  icon: Icons.cloud_upload_outlined,
                                  width: double.infinity,
                                  height: 46,
                                ),
                                if (_letterAudioBytes != null || (_letterAudioPath != null && _letterAudioPath!.isNotEmpty)) ...[
                                  const SizedBox(height: 12),
                                  CustomButton(
                                    text: _isPlayingLetterAudio ? 'Stop Preview' : 'Play Preview',
                                    onPressed: _toggleLetterAudio,
                                    icon: _isPlayingLetterAudio ? Icons.stop : Icons.play_arrow,
                                    backgroundColor: _isPlayingLetterAudio ? AppColors.error : AppColors.secondary,
                                    width: double.infinity,
                                    height: 46,
                                  ),
                                ],
                              ],
                            )
                          : Row(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _letterAudioBytes != null || (_letterAudioPath != null && _letterAudioPath!.isNotEmpty)
                                          ? Icons.check_circle
                                          : Icons.audiotrack,
                                      size: 40,
                                      color: _letterAudioBytes != null || (_letterAudioPath != null && _letterAudioPath!.isNotEmpty)
                                          ? AppColors.success
                                          : AppColors.textLight,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _letterAudioBytes != null || (_letterAudioPath != null && _letterAudioPath!.isNotEmpty)
                                            ? 'Audio file is ready'
                                            : 'No audio file uploaded',
                                        style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Upload a clear recording of the letter sound.',
                                        style: AppTextStyles.bodySmall(context).copyWith(color: AppColors.textMedium),
                                      ),
                                      const SizedBox(height: 16),
                                      OutlinedButton.icon(
                                        onPressed: _pickLetterAudio,
                                        icon: const Icon(Icons.cloud_upload_outlined),
                                        label: Text(_letterAudioBytes != null || (_letterAudioPath != null && _letterAudioPath!.isNotEmpty) 
                                          ? 'Replace Audio' : 'Upload MP3/WAV'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                      if (_letterAudioBytes != null || (_letterAudioPath != null && _letterAudioPath!.isNotEmpty)) ...[
                                        const SizedBox(height: 12),
                                        OutlinedButton.icon(
                                          onPressed: _toggleLetterAudio,
                                          icon: Icon(_isPlayingLetterAudio ? Icons.stop : Icons.play_arrow),
                                          label: Text(_isPlayingLetterAudio ? 'Stop Audio' : 'Play Audio'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: _isPlayingLetterAudio ? AppColors.error : AppColors.secondary,
                                            side: BorderSide(color: _isPlayingLetterAudio ? AppColors.error : AppColors.secondary),
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // --- Word Examples Header ---
                    widget.isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Flashcards', style: AppTextStyles.heading2(context)),
                              const SizedBox(height: 12),
                              CustomButton(
                                text: '+ Add New Word',
                                onPressed: () => _addOrEditWord(),
                                backgroundColor: AppColors.primary,
                                width: double.infinity,
                                height: 46,
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Flashcards', style: AppTextStyles.heading2(context)),
                                  Text('Example words using this sound', style: AppTextStyles.bodySmall(context).copyWith(color: AppColors.textMedium)),
                                ],
                              ),
                              CustomButton(
                                text: '+ Add New Word',
                                onPressed: () => _addOrEditWord(),
                                backgroundColor: AppColors.primary,
                                width: 220,
                                height: 44,
                              ),
                            ],
                          ),
                    const SizedBox(height: 24),
                    
                    if (_examples.isEmpty)
                      _buildEmptyState()
                    else
                      ..._examples.map((word) => _buildWordCard(word)),
                      
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String subtitle, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.heading3(context)),
                  Text(subtitle, style: AppTextStyles.bodySmall(context).copyWith(color: AppColors.textMedium)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall(context).copyWith(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyledDropdown<T>({
    required T value,
    required String label,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall(context).copyWith(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5), style: BorderStyle.none), // dashed border not native in Flutter basic but we can simulate with boxshadow
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)
        ]
      ),
      child: Column(
        children: [
          Icon(Icons.style_outlined, size: 64, color: AppColors.textLight.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('No flashcards yet', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Add some example words to make this unit more engaging.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMedium)),
        ],
      ),
    );
  }

  Widget _buildWordCard(WordExample word) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: word.imageAsset.isNotEmpty
                ? (word.imageAsset.startsWith('http')
                    ? Image.network(word.imageAsset, fit: BoxFit.cover)
                    : Image.asset(word.imageAsset, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image)))
                : const Icon(Icons.image_outlined, color: AppColors.textLight),
          ),
        ),
        title: Text(word.word, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(word.phonetic, style: TextStyle(color: AppColors.textMedium)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (word.audioAsset.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.volume_up, color: AppColors.secondary),
                onPressed: () => _audioPlayer.play(UrlSource(word.audioAsset)),
              ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _addOrEditWord(word),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _deleteWord(word),
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

  bool _isUploading = false;
  Uint8List? _imageBytes;
  String? _imageExtension;
  Uint8List? _audioBytes;
  String? _audioExtension;

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(text: widget.word?.word ?? '');
    _phoneticController = TextEditingController(
      text: widget.word?.phonetic ?? '',
    );
    _imagePath = widget.word?.imageAsset;
    _audioPath = widget.word?.audioAsset;
  }

  @override
  void dispose() {
    _wordController.dispose();
    _phoneticController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageExtension = pickedFile.name.split('.').last;
        _imagePath = null;
      });
    }
  }

  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _audioBytes = result.files.single.bytes;
        _audioExtension = result.files.single.extension ?? 'mp3';
        _audioPath = null;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      final String wordId = widget.word?.id ?? const Uuid().v4();
      final langPrefix = widget.language == LanguageType.english ? 'eng' : 'fil';
      
      String finalImagePath = _imagePath ?? '';
      if (_imageBytes != null) {
        final fileName = '${const Uuid().v4()}.${_imageExtension ?? 'png'}';
        final ref = FirebaseStorage.instance.ref().child('words/$langPrefix/$fileName');
        final metadata = SettableMetadata(contentType: 'image/$_imageExtension');
        await ref.putData(_imageBytes!, metadata);
        finalImagePath = await ref.getDownloadURL();
      }

      String finalAudioPath = _audioPath ?? '';
      if (_audioBytes != null) {
        final fileName = '${const Uuid().v4()}.${_audioExtension ?? 'mp3'}';
        final ref = FirebaseStorage.instance.ref().child('audio/words/$langPrefix/$fileName');
        final metadata = SettableMetadata(contentType: 'audio/$_audioExtension');
        await ref.putData(_audioBytes!, metadata);
        finalAudioPath = await ref.getDownloadURL();
      }

      final newWord = WordExample(
        id: wordId,
        word: _wordController.text.trim(),
        phonetic: _phoneticController.text.trim(),
        imageAsset: finalImagePath,
        audioAsset: finalAudioPath,
        language: widget.language,
      );

      if (mounted) Navigator.pop(context, newWord);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 24),
      child: Container(
        width: isMobile ? double.infinity : 500,
        padding: EdgeInsets.all(isMobile ? 20 : 32),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      Text(
                        widget.word == null ? 'Add Flashcard' : 'Edit Flashcard',
                        style: AppTextStyles.heading2(context),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                _buildFieldLabel('Word'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _wordController,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  decoration: _buildInputDecoration('Enter example word (e.g. Apple)'),
                ),
                const SizedBox(height: 24),
                
                _buildFieldLabel('Phonetic Guide'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneticController,
                  decoration: _buildInputDecoration('e.g. /æpəl/'),
                ),
                const SizedBox(height: 32),
                
                _buildFieldLabel('Media Content'),
                const SizedBox(height: 16),
                
                isMobile
                    ? Column(
                        children: [
                          Row(
                            children: [
                              _buildMediaPreview(
                                child: _imageBytes != null
                                    ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                                    : (_imagePath != null && _imagePath!.isNotEmpty)
                                        ? (_imagePath!.startsWith('http') 
                                            ? Image.network(_imagePath!, fit: BoxFit.cover)
                                            : Image.asset(_imagePath!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image)))
                                        : const Icon(Icons.image_outlined, color: AppColors.textLight),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.camera_alt_outlined),
                                  label: const Text('Image'),
                                  style: _outlinedButtonStyle(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildMediaPreview(
                                width: 80,
                                height: 50,
                                child: Icon(
                                  _audioBytes != null || (_audioPath != null && _audioPath!.isNotEmpty)
                                      ? Icons.volume_up
                                      : Icons.audiotrack_outlined,
                                  color: _audioBytes != null || (_audioPath != null && _audioPath!.isNotEmpty)
                                      ? AppColors.primary
                                      : AppColors.textLight,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickAudioFile,
                                  icon: const Icon(Icons.mic_none_outlined),
                                  label: const Text('Audio'),
                                  style: _outlinedButtonStyle(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          _buildMediaPreview(
                            child: _imageBytes != null
                                ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                                : (_imagePath != null && _imagePath!.isNotEmpty)
                                    ? (_imagePath!.startsWith('http') 
                                        ? Image.network(_imagePath!, fit: BoxFit.cover)
                                        : Image.asset(_imagePath!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image)))
                                    : const Icon(Icons.image_outlined, color: AppColors.textLight),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.camera_alt_outlined),
                              label: const Text('Add Image'),
                              style: _outlinedButtonStyle(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          _buildMediaPreview(
                            width: 60,
                            height: 60,
                            child: Icon(
                              _audioBytes != null || (_audioPath != null && _audioPath!.isNotEmpty)
                                  ? Icons.volume_up
                                  : Icons.audiotrack_outlined,
                              color: _audioBytes != null || (_audioPath != null && _audioPath!.isNotEmpty)
                                  ? AppColors.primary
                                  : AppColors.textLight,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickAudioFile,
                              icon: const Icon(Icons.mic_none_outlined),
                              label: const Text('Add Audio'),
                              style: _outlinedButtonStyle(),
                            ),
                          ),
                        ],
                      ),
                
                const SizedBox(height: 48),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isUploading ? null : () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: AppColors.textMedium)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: _isUploading ? 'Uploading...' : 'Done',
                        onPressed: _isUploading ? null : _save,
                        backgroundColor: AppColors.primary,
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark));
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
    );
  }

  Widget _buildMediaPreview({double width = 80, double height = 80, required Widget child}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Center(child: child),
      ),
    );
  }

  ButtonStyle _outlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
