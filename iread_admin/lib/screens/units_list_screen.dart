import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/language.dart';
import '../data/models/phonics_unit.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/widgets/custom_button.dart';
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
                            if (widget.onMenuPressed != null) ...[
                              IconButton(
                                icon: const Icon(Icons.menu),
                                onPressed: widget.onMenuPressed,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              'Manage Lessons',
                              style: AppTextStyles.heading2(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: '+ Add New Unit',
                          onPressed: () => _navigateToEdit(context, null),
                          backgroundColor: AppColors.secondary,
                          width: double.infinity,
                          height: 50,
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manage Lessons',
                              style: AppTextStyles.heading1(context),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Currently viewing: ${widget.language.displayName} curriculum',
                              style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textMedium),
                            ),
                          ],
                        ),
                        CustomButton(
                          text: '+ Add New Unit',
                          onPressed: () => _navigateToEdit(context, null),
                          backgroundColor: AppColors.secondary,
                          width: 220,
                          height: 54,
                        ),
                      ],
                    ),
            ),
            
            // Content Tracking
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isMobile ? 20.0 : 40.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Segmented Style TabBar
                    Container(
                      height: widget.isMobile ? 44 : 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: AppColors.primary.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textMedium,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                        tabs: [
                          const Tab(text: 'Vowels'),
                          const Tab(text: 'Consonants'),
                          Tab(text: widget.language == LanguageType.english 
                              ? 'Consonant Blends' 
                              : 'Kambal-katinig'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Main Grid Content
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('phonics_units')
                            .where('language', isEqualTo: widget.language.name)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
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
                          
                          // Sort alphabetically by letter
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  )
                ]
              ),
              child: Icon(
                Icons.folder_open,
                size: 64,
                color: AppColors.textMedium.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No units in this category yet',
              style: AppTextStyles.bodyLarge(context).copyWith(
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: widget.isMobile ? 300 : 350,
        childAspectRatio: widget.isMobile ? 1.1 : 1.2,
        crossAxisSpacing: widget.isMobile ? 16 : 24,
        mainAxisSpacing: widget.isMobile ? 16 : 24,
      ),
      itemCount: units.length,
      itemBuilder: (context, index) {
        final unit = units[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UnitEditScreen(
                      language: widget.language,
                      unit: unit,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Large vibrant letter block
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFAC6B), Color(0xFFFF8C42)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              unit.letter.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        
                        // Action Buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (unit.letterAudio != null && unit.letterAudio!.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.volume_up),
                                color: AppColors.secondary,
                                tooltip: 'Preview Sound',
                                onPressed: () => _audioPlayer.play(UrlSource(unit.letterAudio!)),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: AppColors.textLight,
                              hoverColor: AppColors.error.withValues(alpha: 0.1),
                              onPressed: () => _confirmDelete(context, unit),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    
                    // Details
                    Text(
                      'Letter ${unit.letter.toUpperCase()}',
                      style: AppTextStyles.heading3(context),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.style, size: 14, color: AppColors.textMedium),
                          const SizedBox(width: 6),
                          Text(
                            '${unit.examples.length} flashcards',
                            style: AppTextStyles.bodySmall(context).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, PhonicsUnit unit) async {
    // Basic check for built-in units based on ID convention in iread_test
    final isBuiltIn = unit.id.startsWith('eng_vowel') || 
                      unit.id.startsWith('fil_vowel') || 
                      unit.id.startsWith('hil_vowel') || 
                      unit.id.startsWith('eng_c_') ||
                      unit.id.startsWith('eng_b_');
                      
    if (isBuiltIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot delete "${unit.letter.toUpperCase()}" - This is a built-in unit.\n\nYou can only delete custom units you created.',
          ),
          backgroundColor: AppColors.textMedium,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: const Text(
                'This action cannot be undone.',
                style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMedium)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('phonics_units').doc(unit.id).update({
        'isDeleted': true,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unit deleted securely'), backgroundColor: AppColors.success,),
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
