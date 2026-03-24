import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/language.dart';
import '../data/models/phonics_unit.dart';
import '../data/models/word_example.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/responsive_layout.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../core/helpers/cloudinary_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  final _audioPlayer = AudioPlayer();
  
  late TextEditingController _letterController;
  late TextEditingController _soundController;
  late TextEditingController _descriptionController;
  late TextEditingController _letterAudioController;
  late String _category;
  late List<WordExample> _examples;
  
  bool _isSaving = false;
  final Map<String, bool> _uploadingFields = {}; // Tracks loading state per field
  String? _currentlyPlayingUrl;



  @override
  void initState() {
    super.initState();
    _letterController = TextEditingController(text: widget.unit?.letter ?? '');
    _soundController = TextEditingController(text: widget.unit?.sound ?? '');
    _descriptionController = TextEditingController(text: widget.unit?.description ?? '');
    _letterAudioController = TextEditingController(text: widget.unit?.letterAudio ?? '');
    
    // Determine category from unit's categoryId or default to vowels
    _category = 'vowels';
    if (widget.unit != null) {
      if (widget.unit!.categoryId.contains('vowel')) _category = 'vowels';
      else if (widget.unit!.categoryId.contains('consonant')) _category = 'consonants';
      else if (widget.unit!.categoryId.contains('blends')) _category = 'blends';
    }

    _examples = widget.unit?.examples != null 
        ? List.from(widget.unit!.examples) 
        : [WordExample(
            id: const Uuid().v4(),
            word: '', 
            audioAsset: '', 
            imageAsset: '', 
            phonetic: '', 
            language: widget.language
          )];
  }

  @override
  void dispose() {
    _letterController.dispose();
    _soundController.dispose();
    _descriptionController.dispose();
    _letterAudioController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final langPrefix = widget.language == LanguageType.english ? 'eng' : 
                         (widget.language == LanguageType.filipino ? 'fil' : 'hil');
      final categoryId = '${langPrefix}_$_category';

      final PhonicsUnit finalUnit = PhonicsUnit(
        id: widget.unit?.id ?? '${langPrefix}_${_category[0]}_${_letterController.text.trim().toLowerCase()}',
        letter: _letterController.text.trim().toLowerCase(),
        sound: _soundController.text.trim(),
        description: _descriptionController.text.trim(),
        letterAudio: _letterAudioController.text.trim(),
        categoryId: categoryId,
        language: widget.language,
        examples: _examples,
      );

      final docRef = FirebaseFirestore.instance.collection('phonics_units').doc(finalUnit.id);
      
      if (widget.unit == null) {
        await docRef.set(finalUnit.toJson());
      } else {
        await docRef.update(finalUnit.toJson());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unit saved successfully'), backgroundColor: AppColors.success),
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAndUpload({
    required String fieldId,
    required bool isImage,
    TextEditingController? controller,
    int? exampleIndex,
  }) async {
    setState(() => _uploadingFields[fieldId] = true);

    try {
      String? secureUrl;

      if (isImage) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        
        if (image != null) {
          if (kIsWeb) {
            final bytes = await image.readAsBytes();
            secureUrl = await CloudinaryService.uploadBytes(
              bytes: bytes,
              filename: image.name,
              resourceType: 'image',
            );
          } else {
            secureUrl = await CloudinaryService.uploadFile(
              file: File(image.path),
              resourceType: 'image',
            );
          }
        }
      } else {
        final FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.audio,
          allowMultiple: false,
        );

        if (result != null && result.files.single.bytes != null) {
          secureUrl = await CloudinaryService.uploadBytes(
            bytes: result.files.single.bytes!,
            filename: result.files.single.name,
            resourceType: 'video', // Cloudinary uses 'video' for audio
          );
        } else if (result != null && result.files.single.path != null) {
          secureUrl = await CloudinaryService.uploadFile(
            file: File(result.files.single.path!),
            resourceType: 'video',
          );
        }
      }

      if (secureUrl != null) {
        setState(() {
          if (controller != null) {
            controller.text = secureUrl!;
          } else if (exampleIndex != null) {
            if (isImage) {
              _examples[exampleIndex] = _examples[exampleIndex].copyWith(imageAsset: secureUrl);
            } else {
              _examples[exampleIndex] = _examples[exampleIndex].copyWith(audioAsset: secureUrl);
            }
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload successful'), backgroundColor: AppColors.success),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload failed. Check Cloudinary configuration.'), backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingFields[fieldId] = false);
    }
  }

  Future<void> _toggleAudioPreview(String url) async {
    if (_currentlyPlayingUrl == url) {
      await _audioPlayer.stop();
      setState(() => _currentlyPlayingUrl = null);
    } else {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(url));
        setState(() => _currentlyPlayingUrl = url);
        
        _audioPlayer.onPlayerComplete.first.then((_) {
          if (mounted && _currentlyPlayingUrl == url) {
            setState(() => _currentlyPlayingUrl = null);
          }
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error playing audio: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        title: Text(
          widget.unit == null ? 'Create New Unit' : 'Edit Unit ${widget.unit!.letter.toUpperCase()}',
          style: AppTextStyles.heading3(context),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!isDesktop)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.m),
              child: Center(
                child: TextButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text('SAVE', style: AppTextStyles.label(context).copyWith(color: AppColors.primary)),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? AppSpacing.xxl : AppSpacing.m,
            vertical: AppSpacing.l
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Unit Configuration', style: AppTextStyles.heading2(context)),
                            Text('Configure phonics properties and flashcards', style: AppTextStyles.bodySmall(context)),
                          ],
                        ),
                        CustomButton(
                          text: 'Save Changes',
                          onPressed: _isSaving ? null : _save,
                          isLoading: _isSaving,
                          width: 180,
                        ),
                      ],
                    ),
                    AppSpacing.verticalL,
                  ],
                  
                  _buildSectionLayout(
                    isDesktop: isDesktop,
                    sections: [
                      _buildInfoSection(context),
                      _buildExamplesSection(context),
                    ],
                  ),
                  
                  AppSpacing.verticalXXL,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLayout({required bool isDesktop, required List<Widget> sections}) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 340, child: sections[0]),
          AppSpacing.horizontalL,
          Expanded(child: sections[1]),
        ],
      );
    }
    return Column(children: sections);
  }

  Widget _buildInfoSection(BuildContext context) {
    return _CardWrapper(
      title: 'Common Properties',
      icon: Icons.settings_input_component_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _letterController,
            label: 'Phonics Letter',
            hint: 'e.g., Ah, Bb, Ch',
            validator: (v) => v!.isEmpty ? 'Letter is required' : null,
          ),
          AppSpacing.verticalL,
          _buildTextField(
            controller: _soundController,
            label: 'Sound / Pronunciation',
            hint: 'How is it pronounced?',
          ),
          AppSpacing.verticalL,
          _buildMediaPicker(
            label: 'Phonics Sound Audio',
            fieldId: 'letter_audio',
            isImage: false,
            previewUrl: _letterAudioController.text,
            onUpload: () => _pickAndUpload(
              fieldId: 'letter_audio',
              isImage: false,
              controller: _letterAudioController,
            ),
            onClear: () => setState(() => _letterAudioController.clear()),
          ),
          AppSpacing.verticalL,
          Text('Category', style: AppTextStyles.label(context)),
          AppSpacing.verticalXS,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _category,
                isExpanded: true,
                style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textDark),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textLight),
                items: [
                  const DropdownMenuItem(value: 'vowels', child: Text('Vowels')),
                  const DropdownMenuItem(value: 'consonants', child: Text('Consonants')),
                  DropdownMenuItem(value: 'blends', child: Text(widget.language == LanguageType.english ? 'Blends' : 'Kambal')),
                ],
                onChanged: (v) => setState(() => _category = v!),
              ),
            ),
          ),
          AppSpacing.verticalL,
          _buildTextField(
            controller: _descriptionController,
            label: 'Notes / Description',
            hint: 'Internal notes...',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildExamplesSection(BuildContext context) {
    return _CardWrapper(
      title: 'Flashcard Examples',
      icon: Icons.collections_rounded,
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _examples.length,
            separatorBuilder: (context, index) => AppSpacing.verticalM,
            itemBuilder: (context, index) => _buildExampleItem(context, index),
          ),
          AppSpacing.verticalL,
          IconButton.filledTonal(
            onPressed: () => setState(() => _examples.add(WordExample(
              id: const Uuid().v4(),
              word: '', 
              audioAsset: '', 
              imageAsset: '', 
              phonetic: '', 
              language: widget.language
            ))),
            icon: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded),
                SizedBox(width: 8),
                Text('Add Example'),
              ],
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.m),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleItem(BuildContext context, int index) {
    final example = _examples[index];
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('#${index + 1}', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              AppSpacing.horizontalM,
              Text('Flashcard Settings', style: AppTextStyles.label(context)),
              const Spacer(),
              if (_examples.length > 1)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error, size: 20),
                  onPressed: () => setState(() => _examples.removeAt(index)),
                ),
            ],
          ),
          AppSpacing.verticalM,
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  label: 'Word',
                  hint: 'e.g., Apple',
                  initialValue: example.word,
                  onChanged: (v) => _examples[index] = example.copyWith(word: v),
                ),
              ),
              AppSpacing.horizontalM,
              Expanded(
                child: _buildTextField(
                  label: 'Phonetic',
                  hint: '/ˈæp.əl/',
                  initialValue: example.phonetic,
                  onChanged: (v) => _examples[index] = example.copyWith(phonetic: v),
                ),
              ),
            ],
          ),
          AppSpacing.verticalM,
          Row(
            children: [
              Expanded(
                child: _buildMediaPicker(
                  label: 'Flashcard Audio',
                  fieldId: 'example_${index}_audio',
                  isImage: false,
                  previewUrl: example.audioAsset,
                  onUpload: () => _pickAndUpload(
                    fieldId: 'example_${index}_audio',
                    isImage: false,
                    exampleIndex: index,
                  ),
                  onClear: () => setState(() => _examples[index] = example.copyWith(audioAsset: '')),
                ),
              ),
              AppSpacing.horizontalM,
              Expanded(
                child: _buildMediaPicker(
                  label: 'Flashcard Image',
                  fieldId: 'example_${index}_image',
                  isImage: true,
                  previewUrl: example.imageAsset,
                  onUpload: () => _pickAndUpload(
                    fieldId: 'example_${index}_image',
                    isImage: true,
                    exampleIndex: index,
                  ),
                  onClear: () => setState(() => _examples[index] = example.copyWith(imageAsset: '')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? initialValue,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label(context).copyWith(fontSize: 12, color: AppColors.textMedium)),
        AppSpacing.verticalXS,
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          onChanged: onChanged,
          validator: validator,
          maxLines: maxLines,
          style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall(context).copyWith(color: AppColors.textLight),
            filled: true,
            fillColor: AppColors.surfaceVariant.withValues(alpha: 0.4),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), 
              borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.2))
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), 
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5)
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPicker({
    required String label,
    required String fieldId,
    required bool isImage,
    required String? previewUrl,
    required VoidCallback onUpload,
    required VoidCallback onClear,
  }) {
    final bool isUploading = _uploadingFields[fieldId] ?? false;
    final bool hasPreview = previewUrl != null && previewUrl.isNotEmpty && previewUrl.startsWith('http');
    final bool isPlaying = !isImage && _currentlyPlayingUrl == previewUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label(context).copyWith(fontSize: 12, color: AppColors.textMedium)),
        AppSpacing.verticalXS,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.3),
              style: hasPreview ? BorderStyle.solid : BorderStyle.none,
            ),
          ),
          child: isUploading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
                        SizedBox(height: 12),
                        Text('Uploading...', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                )
              : !hasPreview
                  ? InkWell(
                      onTap: onUpload,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), style: BorderStyle.solid),
                          color: AppColors.primary.withValues(alpha: 0.05),
                        ),
                        child: Column(
                          children: [
                            Icon(isImage ? Icons.add_photo_alternate_rounded : Icons.library_music_rounded, 
                                 size: 32, color: AppColors.primary),
                            const SizedBox(height: 8),
                            Text('Tap to Upload ${isImage ? 'Image' : 'Audio'}', 
                                 style: AppTextStyles.label(context).copyWith(color: AppColors.primary)),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        if (isImage)
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(image: NetworkImage(previewUrl), fit: BoxFit.cover),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton.filled(
                                  onPressed: onClear,
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.black54,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.all(4),
                                    minimumSize: const Size(28, 28),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              IconButton.filledTonal(
                                onPressed: () => _toggleAudioPreview(previewUrl),
                                icon: Icon(isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded, color: AppColors.primary),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                              AppSpacing.horizontalM,
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Audio Ready', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text('Click play to preview', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: onClear,
                                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                              ),
                            ],
                          ),
                        AppSpacing.verticalM,
                        OutlinedButton.icon(
                          onPressed: onUpload,
                          icon: const Icon(Icons.sync_rounded, size: 16),
                          label: Text('Change ${isImage ? 'Image' : 'Audio'}', style: const TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 36),
                            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }



}

class _CardWrapper extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _CardWrapper({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.primary),
                ),
                AppSpacing.horizontalM,
                Text(title, style: AppTextStyles.heading3(context)),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: child,
          ),
        ],
      ),
    );
  }
}
