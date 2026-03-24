import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/language.dart';
import '../data/models/phonics_unit.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/responsive_layout.dart';
import 'unit_edit_screen.dart';
import 'package:audioplayers/audioplayers.dart';

class UnitsListScreen extends StatefulWidget {
  final LanguageType language;
  final bool isMobile;
  final VoidCallback? onMenuPressed;

  const UnitsListScreen({
    super.key,
    required this.language,
    this.isMobile = false,
    this.onMenuPressed,
  });

  @override
  State<UnitsListScreen> createState() => _UnitsListScreenState();
}

class _UnitsListScreenState extends State<UnitsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: widget.isMobile ? AppSpacing.l : AppSpacing.xl,
                vertical: widget.isMobile ? AppSpacing.xl : AppSpacing.xxl,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.divider.withValues(alpha: 0.5))),
              ),
              child: responsiveValue<Widget>(
                context,
                mobile: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (widget.onMenuPressed != null) ...[
                          IconButton(
                            icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
                            onPressed: widget.onMenuPressed,
                          ),
                          AppSpacing.horizontalXS,
                        ],
                        Text('Manage Content', style: AppTextStyles.heading2(context)),
                      ],
                    ),
                    AppSpacing.verticalM,
                    CustomButton(
                      text: 'Add New Unit',
                      onPressed: () => _navigateToEdit(context, null),
                      icon: Icons.add_rounded,
                      width: double.infinity,
                    ),
                  ],
                ),
                desktop: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Curriculum Management', style: AppTextStyles.heading1(context)),
                          AppSpacing.verticalXS,
                          Text(
                            'Viewing ${widget.language.displayName} lessons and activities',
                            style: AppTextStyles.bodyMedium(context),
                          ),
                        ],
                      ),
                    ),
                    CustomButton(
                      text: 'Create New Unit',
                      onPressed: () => _navigateToEdit(context, null),
                      icon: Icons.add_rounded,
                      width: 200,
                    ),
                  ],
                ),
              ),
            ),
            
            // Tab Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isMobile ? AppSpacing.m : AppSpacing.xl,
                ),
                child: Column(
                  children: [
                    AppSpacing.verticalL,
                    // Modern TabBar
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.surface,
                          boxShadow: AppColors.softShadow,
                        ),
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textLight,
                        labelStyle: AppTextStyles.label(context),
                        tabs: [
                          const Tab(text: 'Vowels'),
                          const Tab(text: 'Consonants'),
                          Tab(text: widget.language == LanguageType.english 
                              ? 'Blends' 
                              : 'Kambal'),
                        ],
                      ),
                    ),
                    AppSpacing.verticalL,
                    
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('phonics_units')
                            .where('language', isEqualTo: widget.language.name)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                          }

                          final docs = snapshot.data!.docs;
                          final List<PhonicsUnit> units = docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            data['id'] = doc.id; 
                            return PhonicsUnit.fromJson(data);
                          }).where((unit) {
                            final data = docs.firstWhere((d) => d.id == unit.id).data() as Map<String, dynamic>;
                            return data['isDeleted'] != true; 
                          }).toList();
                          
                          units.sort((a, b) => a.letter.compareTo(b.letter));

                          return TabBarView(
                            controller: _tabController,
                            children: [
                              _buildUnitsGrid(units.where((u) => u.categoryId.toLowerCase().contains('vowel')).toList()),
                              _buildUnitsGrid(units.where((u) => u.categoryId.toLowerCase().contains('consonant')).toList()),
                              _buildUnitsGrid(units.where((u) => u.categoryId.toLowerCase().contains('blends')).toList()),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitsGrid(List<PhonicsUnit> units) {
    if (units.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: AppColors.softShadow,
              ),
              child: const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textLight),
            ),
            AppSpacing.verticalL,
            Text('No units found', style: AppTextStyles.heading3(context).copyWith(color: AppColors.textLight)),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = responsiveValue<int>(
          context,
          mobile: 1,
          tablet: 2,
          desktop: 3,
        );
        
        return GridView.builder(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: widget.isMobile ? 1.5 : 1.3,
            crossAxisSpacing: AppSpacing.m,
            mainAxisSpacing: AppSpacing.m,
          ),
          itemCount: units.length,
          itemBuilder: (context, index) {
            final unit = units[index];
            return _buildUnitCard(unit);
          },
        );
      },
    );
  }

  Widget _buildUnitCard(PhonicsUnit unit) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.8)),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToEdit(context, unit),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          unit.letter.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (unit.letterAudio != null && unit.letterAudio!.isNotEmpty)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.volume_up_rounded, color: AppColors.secondary, size: 20),
                            onPressed: () => _audioPlayer.play(UrlSource(unit.letterAudio!)),
                          ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textLight, size: 20),
                          onPressed: () => _confirmDelete(context, unit),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Text('Letter ${unit.letter.toUpperCase()}', style: AppTextStyles.heading3(context)),
                AppSpacing.verticalXS,
                Row(
                  children: [
                    Icon(Icons.style_outlined, size: 14, color: AppColors.textLight),
                    AppSpacing.horizontalXS,
                    Text(
                      '${unit.examples.length} flashcards',
                      style: AppTextStyles.bodySmall(context),
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

  Future<void> _confirmDelete(BuildContext context, PhonicsUnit unit) async {
    final isBuiltIn = unit.id.startsWith('eng_vowel') || 
                      unit.id.startsWith('fil_vowel') || 
                      unit.id.startsWith('hil_vowel') || 
                      unit.id.startsWith('eng_c_') ||
                      unit.id.startsWith('eng_b_');
                      
    if (isBuiltIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot delete built-in unit "${unit.letter.toUpperCase()}"'),
          backgroundColor: AppColors.textDark,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete "${unit.letter.toUpperCase()}"?'),
        content: const Text('This action cannot be undone and will remove all associated flashcards.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textLight)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete Forever', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('phonics_units').doc(unit.id).update({'isDeleted': true});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unit deleted securely'), backgroundColor: AppColors.success),
        );
      }
    }
  }

  void _navigateToEdit(BuildContext context, PhonicsUnit? unit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnitEditScreen(
          language: widget.language,
          unit: unit,
          isMobile: widget.isMobile,
        ),
      ),
    );
  }
}
