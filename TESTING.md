# iRead Testing & Quality Assurance Documentation

This document provides a detailed overview of the testing infrastructure, strategies, and coverage for the iRead application.

## 🧪 Testing Philosophy

iRead uses a multi-layered testing approach to ensure stability across different components:

1. **Unit Tests**: Focused on pure business logic, such as fuzzy matching algorithms and data parsing.
2. **Widget Tests**: Focused on UI components, navigation, and user interaction flows.
3. **Regression Tests**: High-level smoke tests that ensure core user journeys remain unbroken after changes.

---

## 🛠️ Testing Infrastructure

### 1. Rive Animation Mocking (`AppRiveAnimation`)

Rive animations require native DLLs (`rive_common_plugin.dll`) which are often unavailable in CI/CD or local test environments. We use a wrapper called `AppRiveAnimation` to handle this.

- **File**: `lib/core/widgets/app_rive_animation.dart`
- **Behavior**: During tests (detected via `kDebugMode` and environment variables), it displays a simple colored placeholder instead of attempting to load the Rive file.
- **Usage**:

  ```dart
  const AppRiveAnimation.asset('assets/rive/antfly.riv')
  ```

### 2. Audio Player Mocking (`AudioPlayerUtil`)

Playing audio during tests can cause crashes or hangs if the native audio engine isn't initialized.

- **File**: `lib/core/utils/audio_player_util.dart`
- **Behavior**: Detects the test environment using `bool.fromEnvironment('flutter.test')` and skips all `play` and `stop` calls.

### 3. Responsive UI Initialization

Many widgets use `Responsive` utilities for scaling. Tests must initialize this to avoid `LateInitializationError`.

- **Pattern**:

  ```dart
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          Responsive.init(context);
          return MyWidget();
        },
      ),
    ),
  );
  ```

---

## 📋 Test Coverage Details

### 1. Speech Recognition Logic (`test/unit/speech_logic_test.dart`)

Verifies the fuzzy matching algorithm that handles children's speech.

- **Exact Matches**: "Apple" vs "apple".
- **Homophones**: "Meet" vs "meat".
- **Fuzzy Matches**: "Aple" vs "apple" (Levenshtein distance).
- **Partial Matches**: Substring detection for long phrases.

### 2. Content Loading & Models (`test/unit/content_loading_test.dart`)

Ensures that the app's curriculum can be correctly parsed from JSON.

- **Category Extraction**: Vowels, Consonants, etc.
- **Language Mapping**: Correct labels for English, Filipino, and Hiligaynon.

### 3. Teacher Mode Security (`test/widget/teacher_security_test.dart`)

Verifies the security barrier for educator tools.

- **PIN Verification**: Success with `1234`, failure with incorrect PINs.
- **Navigation**: Ensures the app moves to the Editor screen upon success.

### 4. Navigation Flow (`test/widget/language_navigation_test.dart`)

Verifies the onboarding path.

- **Language Selection**: Ensures buttons for English and Filipino are present and tappable.

### 5. Regression Smoke Tests (`test/regression/smoke_test.dart`)

A high-level test that simulates a user opening the app.

- **Flow**: Loading Screen -> Splash Screen -> Main Learning Start.

---

## 🚀 Running Tests

### Run All Tests

```bash
flutter test
```

### Run Specific Categories

```bash
flutter test test/unit      # Logic only
flutter test test/widget    # UI components only
flutter test test/regression # Integration/Smoke tests
```

### Run with Coverage Report (LCOV)

```bash
flutter test --coverage
# To view HTML:
genhtml coverage/lcov.info -o coverage/html
```

---

## 🛡️ Best Practices for New Tests

- **Always use `AppRiveAnimation`** for any interactive animations.
- **Mock Repositories** rather than using real Hive databases where possible.
- **Test localized strings** by checking for both the key and the displayed value across languages.
