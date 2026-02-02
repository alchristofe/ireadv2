import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/loading/loading_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/language_selection/language_selection_screen.dart';
import '../../presentation/screens/category_selection/category_selection_screen.dart';
import '../../presentation/screens/unit_selection/unit_selection_screen.dart';
import '../../presentation/screens/lesson/lesson_screen.dart';
import '../../presentation/screens/lesson/letter_sound_screen.dart';
import '../../presentation/screens/congratulations/congratulations_screen.dart';
import '../../presentation/screens/teacher_mode/teacher_login_screen.dart';
import '../../presentation/screens/teacher_mode/content_editor_screen.dart';
import '../../presentation/screens/teacher_mode/unit_editor_screen.dart';
import '../../presentation/screens/teacher_mode/settings_screen.dart';
import '../../data/models/phonics_unit.dart';
import '../../data/models/story.dart';
import '../../presentation/screens/story_mode/story_mode_screens.dart';
import '../../presentation/screens/story_mode/story_bookshelf_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import 'route_names.dart';

/// App router configuration using GoRouter
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.loading,
    routes: [
      GoRoute(
        path: RouteNames.loading,
        name: 'loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.languageSelection,
        name: 'languageSelection',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: RouteNames.categorySelection,
        name: 'categorySelection',
        builder: (context, state) {
          final languageType = state.extra as String?;
          return CategorySelectionScreen(
            languageType: languageType ?? 'english',
          );
        },
      ),
      GoRoute(
        path: RouteNames.unitSelection,
        name: 'unitSelection',
        builder: (context, state) {
          final params = state.extra as Map<String, String>?;
          return UnitSelectionScreen(
            languageType: params?['languageType'] ?? 'english',
            categoryId: params?['categoryId'] ?? '',
          );
        },
      ),
      GoRoute(
        path: RouteNames.letterSound,
        name: 'letterSound',
        builder: (context, state) {
          final params = state.extra as Map<String, String>?;
          return LetterSoundScreen(
            unitId: params?['unitId'] ?? '',
            languageType: params?['languageType'] ?? 'english',
          );
        },
      ),
      GoRoute(
        path: RouteNames.lesson,
        name: 'lesson',
        builder: (context, state) {
          final params = state.extra as Map<String, String>?;
          return LessonScreen(
            unitId: params?['unitId'] ?? '',
            languageType: params?['languageType'] ?? 'english',
          );
        },
      ),
      GoRoute(
        path: RouteNames.congratulations,
        name: 'congratulations',
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>?;
          return CongratulationsScreen(
            unitId: params?['unitId'] as String? ?? '',
            categoryId: params?['categoryId'] as String? ?? '',
            message: params?['message'] as String? ?? 'Great job!',
            language: params?['language'] as String? ?? 'english',
          );
        },
      ),
      GoRoute(
        path: RouteNames.teacherLogin,
        name: 'teacherLogin',
        builder: (context, state) => const TeacherLoginScreen(),
      ),
      GoRoute(
        path: RouteNames.teacherEditor,
        name: 'teacherEditor',
        builder: (context, state) => const ContentEditorScreen(),
      ),
      GoRoute(
        path: RouteNames.teacherUnitEditor,
        name: 'teacherUnitEditor',
        builder: (context, state) {
          final unit = state.extra as PhonicsUnit?;
          return UnitEditorScreen(unit: unit);
        },
      ),
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.storyCategory,
        name: 'storyCategory',
        builder: (context, state) => const StoryBookshelfScreen(),
      ),
      GoRoute(
        path: RouteNames.storyReader,
        name: 'storyReader',
        builder: (context, state) {
          final story = state.extra as Story;
          return StoryReaderScreen(story: story);
        },
      ),
    ],
  );
}
