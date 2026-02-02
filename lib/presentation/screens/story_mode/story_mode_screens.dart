import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iread/data/models/story.dart';

// --- Story Reader Screen ---
class StoryReaderScreen extends StatefulWidget {
  final Story story;

  const StoryReaderScreen({super.key, required this.story});

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _currentLanguage = 'english'; // Default to English

  // Available languages for this story (based on content map keys)
  List<String> get _availableLanguages => widget.story.content.keys.toList();

  @override
  Widget build(BuildContext context) {
    // Get content for current language, fallback to first available if missing
    final content =
        widget.story.content[_currentLanguage] ??
        widget.story.content.values.first;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Paper color
      appBar: AppBar(
        title: Text(
          content.title,
          style: const TextStyle(color: Color(0xFF3E2723)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3E2723)),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Language Switcher
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<String>(
              value: _currentLanguage,
              icon: const Icon(Icons.language, color: Color(0xFF3E2723)),
              dropdownColor: const Color(0xFFFFF8E1),
              underline: const SizedBox(),
              items: _availableLanguages.map((String langCode) {
                // Map code to display name
                String displayName;
                switch (langCode) {
                  case 'english':
                    displayName = 'English';
                    break;
                  case 'filipino':
                    displayName = 'Filipino';
                    break;
                  case 'hiligaynon':
                    displayName = 'Hiligaynon';
                    break;
                  default:
                    displayName = langCode.toUpperCase();
                }
                return DropdownMenuItem<String>(
                  value: langCode,
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      color: Color(0xFF3E2723),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _currentLanguage = newValue;
                  });
                }
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: content.pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = content.pages[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (page.imageAsset != null)
                          Container(
                            height: MediaQuery.of(context).size.height * 0.4,
                            constraints: const BoxConstraints(maxHeight: 400),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                page.imageAsset!,
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, s) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Text(
                          page.text,
                          style: const TextStyle(
                            fontSize: 22,
                            height: 1.5,
                            color: Color(0xFF3E2723),
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page Indicators and Navigation
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFFFECB3).withValues(alpha: 0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: _currentPage > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                  ),
                  Text(
                    'Page ${_currentPage + 1} of ${content.pages.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: _currentPage < content.pages.length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
