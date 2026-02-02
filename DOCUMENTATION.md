# iRead: Bilingual Phonics Learning App - Documentation

iRead is a mobile application designed to help young learners master phonics in both English and Filipino (Tagalog). The app provides an interactive, offline-first experience with a focus on ease of use for children and flexibility for educators.

---

## 🚀 Overview

- **Purpose**: To provide a structured, bilingual phonics curriculum.
- **Target Audience**: Preschool and early elementary children learning to read.
- **Key Philosophy**: Learning through listening, seeing, and speaking.

---

## ✨ Key Features

### 1. Bilingual Phonics Support

Lessons are tailored to the phonemic structures of both English and Filipino.

- **English**: Standard phonics following a proven curriculum.
- **Filipino**: Focus on Tagalog phonology (Patinig and Katinig).

### 2. Interactive Lessons

Each lesson unit focuses on a specific letter or sound.

- **Audio Clues**: Professional (or simulated) pronunciation audio.
- **Visual Aids**: Vivid illustrations for word examples.
- **Speech Practice**: Real-time feedback using on-device speech recognition.

### 3. Story Mode (iRead Stories)

Beyond basic phonics, children can engage with classic Filipino fables and legends.

- **Bilingual Narratives**: Stories available in English, Filipino, and Hiligaynon.
- **Original Art**: High-quality illustrations in a consistent "Filipino Art" style.

### 4. Teacher/Parent Mode

A secure area for managing content and monitoring student needs.

- **PIN Protected**: Secure entrance (Default PIN: `1234`).
- **Content Editor**: Teachers can modify or add new lesson units directly in the app.

---

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (Cross-platform UI)
- **Local Storage**: [Hive](https://docs.hivedb.dev/) (NoSQL, lightweight, fast)
- **Animations**: [Rive](https://rive.app/) (Vector-based, interactive animations)
- **Speech Recognition**: [Vosk](https://alphacephei.com/vosk/) (Offline-first speech-to-text)
- **State Management**: Provider (Simple and efficient)

---

## 🏗️ Architecture

iRead follows a **Clean Architecture** approach to ensure maintainability and testability.

### Layers

1. **Presentation Layer (`lib/presentation`)**:
   - Contains Widgets (Screens/Components).
   - Manages UI state and user interactions.
   - Organized by feature (e.g., `feature/lesson`, `feature/teacher_mode`).

2. **Domain Layer (`lib/domain`)**:
   - Contains business logic definitions (Entities and Use Cases).
   - Acts as a bridge between Data and Presentation.

3. **Data Layer (`lib/data`)**:
   - Implements Data Sources (local JSON, Hive).
   - Handles API calls (if any) and Repository implementations.
   - **Models**: Defines the structure of Lessons, Stories, and Progress.

---

## 📁 Project Structure Detailed

```text
iread_test/
├── assets/
│   ├── audio/           # Localized pronunciation MP3s
│   ├── data/            # lessons.json (Master content file)
│   ├── images/
│   │   └── stories/     # Assets for story mode
│   ├── models/          # Vosk speech models (offline STT)
│   └── rive/            # Antfly and other interactive animations
├── lib/
│   ├── core/
│   │   ├── constants/   # App-wide strings, colors, sizes
│   │   ├── utils/       # Speech services, audio players, fuzzy logic
│   │   └── widgets/     # Common UI components
│   ├── data/
│   │   ├── data_sources/# Story definitions and content
│   │   ├── local/       # Hive box management
│   │   ├── models/      # Plain old data classes (Hive adapted)
│   │   └── repositories/# Repository pattern implementations
│   ├── domain/          # (Entities & Use Cases)
│   └── presentation/    # Screens and visual components
```

---

## 🔊 Speech Recognition & Fuzzy Matching

One of the core features is the **Child-Friendly Speech Recognition**.

- **Offline STT**: Uses Vosk to recognize speech without an internet connection.
- **Fuzzy Matching**: To accommodate developing speech in young children, we use Levenshtein Distance logic.
  - **Threshold**: Currently set to allow ~80% similarity.
  - **Feedback**: Provides "Almost there!" or "Great job!" based on the closeness of the match.

---

## 📝 Content Management (lessons.json)

The app's curriculum is defined in `assets/data/lessons.json`. This makes it easy to update content without modifying the Flutter source code.

**Structure**:

- `languages`: Array of English/Filipino.
- `categories`: Vowels/Consonants/Blends.
- `units`: Individual letter sounds.
- `examples`: Word, image path, and audio path.

---

## 🔒 Security

- **Teacher Mode**: Protected by a 4-digit PIN stored securely.
- **Local Storage**: All student progress remains on the device, ensuring privacy and offline access.

---

## 📋 Asset Management

### 🎨 Images

- Use `SVG` for icons and `PNG` for complex illustrations.
- Story images are kept in feature-specific subfolders in `assets/images/stories/`.

### 🎵 Audio

- Stored as `mp3` or `wav`.
- Organized by language code (e.g., `assets/audio/english/`).

---

## 🧪 Testing & Quality Assurance

iRead maintains a comprehensive test suite to ensure the reliability of its bilingual curriculum and speech recognition logic.

- **Unit Tests**: Logic for fuzzy matching and data models.
- **Widget Tests**: UI components and navigation.
- **Regression Tests**: End-to-end smoke tests.

For a full guide on testing, see [TESTING.md](file:///c:/Users/User/Desktop/iread_test/TESTING.md).

---

## 🛠️ Setup and Installation

1. **Clone the repository.**
2. **Install Dependencies**: `flutter pub get`
3. **Generate Hive Adapters**: `flutter pub run build_runner build --delete-conflicting-outputs`
4. **Run App**: `flutter run`

---

## 🚀 Roadmap

- [ ] Multi-user profiles (Student switcher).
- [ ] Gamified reward system (Badges and points).
- [ ] Direct recording in Teacher Mode.
- [ ] Cloud syncing (Optional for schools).

---

Made with ❤️ by the iRead Team.
