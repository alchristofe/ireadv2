import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iread/core/constants/app_colors.dart';
import 'package:iread/core/constants/app_text_styles.dart';
import 'package:iread/core/widgets/custom_button.dart';
import 'package:iread/core/widgets/character_avatar.dart';
import 'package:iread/core/widgets/animated_text.dart';
import 'package:iread/core/widgets/progress_bar.dart';
import 'package:iread/core/routes/route_names.dart';
import 'package:iread/data/models/language.dart';
import 'package:iread/data/models/phonics_category.dart';
import 'package:iread/data/repositories/lesson_repository.dart';

/// Category selection screen (consonants/vowels)
class CategorySelectionScreen extends StatefulWidget {
  final String languageType;

  const CategorySelectionScreen({super.key, required this.languageType});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final LessonRepository _repository = LessonRepository();
  List<PhonicsCategory> _categories = [];
  CategoryType? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final language = LanguageType.fromString(widget.languageType);
    final categories = await _repository.getCategoriesByLanguage(language);
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  void _selectCategory(CategoryType category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _continue() {
    if (_selectedCategory != null) {
      final categoryId = _categories
          .firstWhere((c) => c.type == _selectedCategory)
          .id;
      context.push(
        RouteNames.unitSelection,
        extra: {'languageType': widget.languageType, 'categoryId': categoryId},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.languageSelection);
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Progress Bar
                    const ProgressBar(progress: 0.3),
                    const SizedBox(height: 40),
                    // Character with instruction
                    CharacterAvatar(
                      imagePath: widget.languageType == 'english'
                          ? 'assets/images/characters/english_character.png'
                          : widget.languageType == 'hiligaynon'
                          ? 'assets/images/characters/hiligaynon.png'
                          : 'assets/images/characters/filipino_character.png',
                      size: 140, // Increased size to match reference
                      animate: true,
                    ),
                    const SizedBox(height: 16),
                    AnimatedTypewriterText(
                      text: widget.languageType == 'english'
                          ? 'Choose what you want to learn!'
                          : widget.languageType == 'hiligaynon'
                          ? 'Pilia ang gusto mo tun-an subong!'
                          : 'Anong gusto mong matutunan ngayon?',
                      style: AppTextStyles.heading3.copyWith(
                        color: const Color(0xFF3D2C29),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      duration: const Duration(milliseconds: 60),
                    ),
                    const SizedBox(height: 40),
                    // Category Cards
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _CategoryCard(
                              category: CategoryType.vowels,
                              isSelected:
                                  _selectedCategory == CategoryType.vowels,
                              onTap: () => _selectCategory(CategoryType.vowels),
                              languageType: widget.languageType,
                            ),
                            const SizedBox(height: 16),
                            _CategoryCard(
                              category: CategoryType.consonants,
                              isSelected:
                                  _selectedCategory == CategoryType.consonants,
                              onTap: () =>
                                  _selectCategory(CategoryType.consonants),
                              languageType: widget.languageType,
                            ),
                            const SizedBox(height: 16),
                            _CategoryCard(
                              category: CategoryType.blends,
                              isSelected:
                                  _selectedCategory == CategoryType.blends,
                              onTap: () => _selectCategory(CategoryType.blends),
                              languageType: widget.languageType,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Continue Button
                    CustomButton(
                      text: LanguageType.fromString(
                        widget.languageType,
                      ).continueLabel,
                      onPressed: _selectedCategory != null ? _continue : null,
                      isDisabled: _selectedCategory == null,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryType category;
  final bool isSelected;
  final VoidCallback onTap;
  final String languageType;

  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
    required this.languageType,
  });

  @override
  Widget build(BuildContext context) {
    // Determine text based on language
    String categoryName = category.displayName;
    if (languageType == 'filipino' || languageType == 'hiligaynon') {
      if (category == CategoryType.vowels) {
        categoryName = 'Patinig';
      } else if (category == CategoryType.consonants) {
        categoryName = 'Katinig';
      } else if (category == CategoryType.blends) {
        categoryName = 'Kambal-katinig';
      }
    }

    // Determine colors based on category
    const Color activeBorderColor = Color(0xFFFF9F43); // Orange for selected
    const Color inactiveBorderColor = Color(0xFFC4A484); // Beige for unselected

    const Color cardColor = Color(0xFFFFF4E6); // Light peach background

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120, // Fixed height matching reference
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isSelected ? activeBorderColor : inactiveBorderColor,
            width: isSelected ? 6 : 4,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeBorderColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Image - Fixed size container
            Container(
              width: 140, // Increased from 140
              height: 90, // Increased from 90
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(category.imageAsset, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 20),
            // Category Name
            Expanded(
              child: Text(
                categoryName,
                style: AppTextStyles.heading2.copyWith(
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
