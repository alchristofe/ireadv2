import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iread/core/constants/app_colors.dart';
import 'package:iread/core/constants/app_text_styles.dart';
import 'package:iread/core/routes/route_names.dart';
import 'package:iread/data/models/story.dart';
import 'package:iread/data/repositories/story_repository.dart';

class StoryBookshelfScreen extends StatefulWidget {
  const StoryBookshelfScreen({super.key});

  @override
  State<StoryBookshelfScreen> createState() => _StoryBookshelfScreenState();
}

class _StoryBookshelfScreenState extends State<StoryBookshelfScreen> {
  late List<Story> _stories;

  @override
  void initState() {
    super.initState();
    _stories = StoryRepository().getAllStories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7CCC8),
      body: Stack(
        children: [
          // Filipino Background
          _buildBackground(),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 40, bottom: 60),
                    child: Column(children: _buildShelves()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFFEFDDC5)),
      child: Stack(
        children: [
          // Capiz Windows
          Positioned(top: 80, left: -20, child: _buildCapizWindow()),
          Positioned(top: 300, right: -40, child: _buildCapizWindow()),
          Positioned(bottom: 50, left: 100, child: _buildCapizWindow()),
          // Simple bamboo wall texture effect
          for (int i = 0; i < 20; i++)
            Positioned(
              left: i * 40.0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 1,
                color: Colors.brown.withValues(alpha: 0.1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCapizWindow() {
    return Opacity(
      opacity: 0.4,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF795548), width: 3),
        ),
        child: Column(
          children: List.generate(
            3,
            (r) => Expanded(
              child: Row(
                children: List.generate(
                  3,
                  (c) => Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF795548),
                          width: 1,
                        ),
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Color(0xFF5D4037),
            ),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          Text(
            'Library',
            style: AppTextStyles.heading2.copyWith(
              color: const Color(0xFF5D4037),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildShelves() {
    List<Widget> shelves = [];
    for (int i = 0; i < _stories.length; i += 2) {
      final shelfStories = _stories.skip(i).take(2).toList();
      shelves.add(
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: shelfStories.map((story) {
                  return LongPressDraggable<Story>(
                    data: story,
                    feedback: SizedBox(
                      width: 120,
                      height: 200,
                      child: _BookshelfBook(story: story, isDragging: true),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _BookshelfBook(story: story),
                    ),
                    child: DragTarget<Story>(
                      onWillAcceptWithDetails: (details) =>
                          details.data != story,
                      onAcceptWithDetails: (details) {
                        setState(() {
                          final oldIndex = _stories.indexOf(details.data);
                          final newIndex = _stories.indexOf(story);
                          _stories.removeAt(oldIndex);
                          _stories.insert(newIndex, details.data);
                        });
                      },
                      builder: (context, _, __) => _BookshelfBook(story: story),
                    ),
                  );
                }).toList(),
              ),
            ),
            // The Wooden Shelf
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 25,
              decoration: BoxDecoration(
                color: const Color(0xFF8D6E63),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
                gradient: const LinearGradient(
                  colors: [Color(0xFFA1887F), Color(0xFF6D4C41)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      );
    }
    return shelves;
  }
}

class _BookshelfBook extends StatelessWidget {
  final Story story;
  final bool isDragging;

  const _BookshelfBook({required this.story, this.isDragging = false});

  @override
  Widget build(BuildContext context) {
    // Determine title to show
    final displayTitle = story.getTitle('english').isNotEmpty
        ? story.getTitle('english')
        : story.getTitle('filipino');

    return GestureDetector(
      onTap: isDragging
          ? null
          : () => context.push(RouteNames.storyReader, extra: story),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Book with 3D-ish feel
          Container(
            width: 110,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(4, 0),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Book Spine highlight
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    child: Image.asset(
                      story.coverAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              displayTitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Spine shading
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 120,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.brown.shade200),
            ),
            child: Text(
              displayTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: const Color(0xFF3E2723),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
