import '../models/story.dart';
import '../data_sources/stories/monkey_and_turtle.dart';
import '../data_sources/stories/legend_of_kanlaon.dart';
import '../data_sources/stories/biag_ni_lam_ang.dart';
import '../data_sources/stories/moth_story.dart';

class StoryRepository {
  // Aggregated list of all stories from separate files
  final List<Story> _allStories = [
    monkeyAndTurtle,
    legendOfKanlaon,
    biagNiLamAng,
    mothStory,
  ];

  List<Story> getStoriesByCategory(StoryCategory category) {
    return _allStories.where((s) => s.category == category).toList();
  }

  List<Story> getAllStories() {
    return _allStories;
  }
}
