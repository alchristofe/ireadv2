enum StoryCategory {
  myths,
  legends,
  epics,
  fables,
  supernatural;

  String get displayName {
    switch (this) {
      case StoryCategory.myths:
        return 'Myths (Alamat)';
      case StoryCategory.legends:
        return 'Legends';
      case StoryCategory.epics:
        return 'Epics';
      case StoryCategory.fables:
        return 'Fables';
      case StoryCategory.supernatural:
        return 'Tales of the Supernatural';
    }
  }
}

class Story {
  final String id;
  final String coverAsset;
  final StoryCategory category;
  final Map<String, StoryContent> content; // Key is language code (e.g., 'english', 'filipino')

  Story({
    required this.id,
    required this.coverAsset,
    required this.category,
    required this.content,
  });

  String getTitle(String languageId) {
    return content[languageId]?.title ?? content['english']?.title ?? '';
  }
}

class StoryContent {
  final String title;
  final List<StoryPage> pages;

  StoryContent({
    required this.title,
    required this.pages,
  });
}

class StoryPage {
  final String text;
  final String? imageAsset;

  StoryPage({
    required this.text,
    this.imageAsset,
  });
}
