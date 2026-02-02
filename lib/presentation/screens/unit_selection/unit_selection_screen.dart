import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iread/core/constants/app_colors.dart';
import 'package:iread/core/constants/app_text_styles.dart';
import 'package:iread/core/widgets/progress_bar.dart';
import 'package:iread/core/routes/route_names.dart';
import 'package:iread/data/models/language.dart';
import 'package:iread/data/models/phonics_unit.dart';
import 'package:iread/data/repositories/lesson_repository.dart';
import 'package:iread/data/repositories/progress_repository.dart';

/// Unit selection screen (grid of letters)
class UnitSelectionScreen extends StatefulWidget {
  final String languageType;
  final String categoryId;

  const UnitSelectionScreen({
    super.key,
    required this.languageType,
    required this.categoryId,
  });

  @override
  State<UnitSelectionScreen> createState() => _UnitSelectionScreenState();
}

class _UnitSelectionScreenState extends State<UnitSelectionScreen> {
  final LessonRepository _lessonRepository = LessonRepository();
  final ProgressRepository _progressRepository = ProgressRepository();
  List<PhonicsUnit> _units = [];
  Set<String> _completedUnits = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    try {
      final language = LanguageType.fromString(widget.languageType);
      final units = await _lessonRepository.getUnitsByCategory(
        language,
        widget.categoryId,
      );
      final completed = await _progressRepository.getCompletedUnits();

      if (mounted) {
        setState(() {
          _units = units;
          _completedUnits = completed.toSet();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading units: $e')),
        );
      }
    }
  }

  Future<void> _selectUnit(PhonicsUnit unit) async {
    await context.push(
      RouteNames.letterSound,
      extra: {
        'unitId': unit.id,
        'languageType': widget.languageType,
      },
    );
    // Reload units when returning from lesson (to update progress)
    if (mounted) {
      _loadUnits();
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
          onPressed: () => context.pop(),
        ),
        title: Text(
          LanguageType.fromString(widget.languageType).chooseLetterLabel,
          style: AppTextStyles.heading3,
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Progress Bar
                    ProgressBar(
                      progress: _units.isEmpty ? 0.0 : _completedUnits.length / _units.length,
                    ),
                    const SizedBox(height: 40),
                    // Units Grid
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: _units.length,
                        itemBuilder: (context, index) {
                          final unit = _units[index];
                          final isCompleted = _completedUnits.contains(unit.id);
                          return _UnitCard(
                            unit: unit,
                            isCompleted: isCompleted,
                            onTap: () => _selectUnit(unit),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final PhonicsUnit unit;
  final bool isCompleted;
  final VoidCallback onTap;

  const _UnitCard({
    required this.unit,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.cardBackground,
          border: Border.all(
            color: isCompleted ? AppColors.success : AppColors.cardBorder,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                unit.letter.toUpperCase(),
                style: AppTextStyles.letterDisplay.copyWith(
                  fontSize: 48,
                  color: isCompleted ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
            if (isCompleted)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
