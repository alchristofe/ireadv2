import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iread/core/constants/app_colors.dart';
import 'package:iread/core/constants/app_text_styles.dart';
import 'package:iread/core/widgets/custom_button.dart';
import 'package:iread/core/routes/route_names.dart';
import 'package:iread/data/models/language.dart';
import 'package:iread/data/models/phonics_unit.dart';
import 'package:iread/data/repositories/lesson_repository.dart';

/// Content editor screen for teachers with category organization
class ContentEditorScreen extends StatefulWidget {
  const ContentEditorScreen({super.key});

  @override
  State<ContentEditorScreen> createState() => _ContentEditorScreenState();
}

class _ContentEditorScreenState extends State<ContentEditorScreen>
    with SingleTickerProviderStateMixin {
  final LessonRepository _repository = LessonRepository();
  List<PhonicsUnit> _units = [];
  bool _isLoading = true;
  LanguageType _selectedLanguage = LanguageType.english;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUnits();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUnits() async {
    setState(() => _isLoading = true);
    
    try {
      // Get all categories for the selected language
      final categories = await _repository.getCategoriesByLanguage(_selectedLanguage);
      
      List<PhonicsUnit> allUnits = [];
      for (var category in categories) {
        final units = await _repository.getUnitsByCategory(
          _selectedLanguage,
          category.id,
        );
        allUnits.addAll(units);
      }
      
      if (mounted) {
        setState(() {
          _units = allUnits;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading content: $e')),
        );
      }
    }
  }

  List<PhonicsUnit> _getVowelUnits() {
    return _units.where((unit) => 
      unit.categoryId.toLowerCase().contains('vowel')
    ).toList();
  }

  List<PhonicsUnit> _getConsonantUnits() {
    return _units.where((unit) => 
      unit.categoryId.toLowerCase().contains('consonant')
    ).toList();
  }

  List<PhonicsUnit> _getBlendsUnits() {
    return _units.where((unit) => 
      unit.categoryId.toLowerCase().contains('blends')
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Content Editor',
          style: AppTextStyles.heading3.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          // Settings Button
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => context.push(RouteNames.settings),
          ),
          // Language Filter
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<LanguageType>(
              value: _selectedLanguage,
              dropdownColor: AppColors.primary,
              icon: const Icon(Icons.language, color: Colors.white),
              underline: const SizedBox(),
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              items: LanguageType.values.map((lang) {
                return DropdownMenuItem(
                  value: lang,
                  child: Text(lang.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedLanguage = value);
                  _loadUnits();
                }
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage Lessons (${_selectedLanguage.displayName})',
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_units.length} Units Available',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Add New Unit Button
                    CustomButton(
                      text: '+ Add New Unit',
                      onPressed: () async {
                        final result = await context.push(RouteNames.teacherUnitEditor);
                        if (result == true) {
                          _loadUnits();
                        }
                      },
                      backgroundColor: AppColors.secondary,
                    ),
                    const SizedBox(height: 24),

                    // Category Tabs
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textMedium,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      labelStyle: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                        tabs: [
                          const Tab(text: 'Vowels'),
                          const Tab(text: 'Consonants'),
                          Tab(text: _selectedLanguage == LanguageType.english 
                              ? 'Consonant Blends' 
                              : 'Kambal-katinig'),
                        ],
                    ),
                    const SizedBox(height: 16),

                    // Units List by Category
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildUnitsList(_getVowelUnits()),
                          _buildUnitsList(_getConsonantUnits()),
                          _buildUnitsList(_getBlendsUnits()),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'To access Teacher Mode: Long press "Filipino" for 3 seconds on Language Selection.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMedium.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUnitsList(List<PhonicsUnit> units) {
    if (units.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: AppColors.textMedium.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No units in this category',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: units.length,
      itemBuilder: (context, index) {
        final unit = units[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  unit.letter.toUpperCase(),
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            title: Text(
              'Letter ${unit.letter.toUpperCase()}',
              style: AppTextStyles.bodyLarge,
            ),
            subtitle: Text(
              '${unit.examples.length} words',
              style: AppTextStyles.bodySmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.textMedium),
                  onPressed: () async {
                    final result = await context.push(
                      RouteNames.teacherUnitEditor,
                      extra: unit,
                    );
                    if (result == true) {
                      _loadUnits();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: () => _deleteUnit(unit),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteUnit(PhonicsUnit unit) async {
    // Check if unit can be deleted first
    final canDelete = _repository.canDeleteUnit(unit.id);
    
    if (!canDelete) {
      // Show info message for built-in units
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot delete "${unit.letter.toUpperCase()}" - This is a built-in unit.\\n\\nYou can only delete custom units you created.',
          ),
          backgroundColor: AppColors.textMedium,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }
    
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Unit?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${unit.letter.toUpperCase()}"?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'This will permanently remove the unit and all ${unit.examples.length} associated word examples.',
            ),
            const SizedBox(height: 12),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(color: AppColors.error, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete Forever', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final deleted = await _repository.deleteUnit(unit.id);
      _loadUnits();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              deleted 
                ? 'Unit "${unit.letter.toUpperCase()}" deleted'
                : 'Failed to delete unit',
            ),
            backgroundColor: deleted ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }
}
