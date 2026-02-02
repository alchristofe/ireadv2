# iRead - Multilingual Phonics Learning App

A Flutter mobile application for young children to learn phonics in English, Filipino, and Hiligaynon. Features offline-first architecture, speech recognition, and interactive story mode.

## 🎯 Features

### Core Learning Features

- **Multilingual Support**: Learn phonics in **English**, **Filipino**, or **Hiligaynon**.
- **Interactive Story Mode**: Bilingual stories like "Biag ni Lam-ang" and "The Monkey and the Turtle" with language toggling.
- **Phonics Categories**: Lessons for consonants and vowels tailored to each language.
- **Interactive Lessons**: Word examples with high-quality images and audio pronunciation.
- **Offline Speech Recognition**: Powered by **Vosk** for on-device pronunciation practice.
- **Real-time Feedback**: Immediate "Correct" or "Try again" responses with detailed mismatch feedback.
- **Progress Tracking**: Local storage (Hive) of completion and performance history.
- **Polished Animations**: Smooth transitions and celebratory effects using **Rive** and standard Flutter animations.

### Teacher Mode

- **PIN Protection**: Secure access (Default PIN: 1234).
- **Content Management**: Edit lessons and stories (JSON-based).
- **Progress Analytics**: Reset or review student progress.

### Technical Features

- **Offline-First**: Works completely without internet connection after initial installation.
- **Local Storage**: High-performance Hive database for settings and progress.
- **Clean Architecture**: Modular structure with data, domain, and presentation separation.
- **Responsive Design**: Eye-catching, child-friendly UI with large touch targets.

## 📁 Project Structure

```
iread/
├── lib/
│   ├── core/              # Constants, routes, shared widgets
│   ├── data/              # Models, repositories, story data sources
│   ├── domain/            # Business logic and entities
│   └── presentation/      # Screens, providers, and UI logic
├── assets/
│   ├── audio/             # English, Filipino, and Hiligaynon recordings
│   ├── images/            # Word, character, and story assets
│   ├── data/              # lessons.json (Core content definition)
│   ├── rive/              # Animated mascots and logos (antfly.riv)
│   └── models/            # Vosk speech recognition models
├── packages/
│   └── vosk_flutter/      # Custom local package for offline speech
└── android/               # Android-specific configuration
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.9.2)
- Android Device (Minimum SDK 21) or Emulator

### Installation

1. **Install dependencies**

   ```bash
   flutter pub get
   ```

2. **Generate Hive adapters**

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Run the app**

   ```bash
   flutter run
   ```

## 📱 Screens Overview

1. **Splash Screen** - Rive-animated logo and system initialization.
2. **Language Selection** - Select English, Filipino, or Hiligaynon.
3. **Home / Category** - Choose Consonants, Vowels, or Story Mode.
4. **Unit Selection** - Letter cards with visual progress indicators.
5. **Lesson Screen** - "Listen -> See -> Speak" learning loop.
6. **Congratulations** - Animated celebration on unit completion.
7. **Story Mode** - Toggleable bilingual reader.
8. **Teacher Panel** - PIN-protected settings and content management.

## 🎨 Design System

- **Mascots**: Language-specific characters and animated Rive components.
- **Colors**: Primary (#FF8C42), Secondary (#4A90E2), Success (#4CAF50).
- **Typography**: Poppins for headers, Nunito for body text.

## 📊 Data Structure

The app uses a JSON-based content system (`assets/data/lessons.json`):

```json
{
  "languages": [
    {
      "type": "hiligaynon",
      "categories": [
        {
          "type": "vowels",
          "units": [
            {
              "id": "hil_vowel_a",
              "letter": "A",
              "sound": "Ah",
              "examples": [
                {
                  "word": "Abaniko",
                  "imageAsset": "assets/images/words/abaniko.png",
                  "audioAsset": "assets/audio/hiligaynon/abaniko.mp3"
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

## Speech Recognition

- **Engine**: Vosk (Offline STT).
- **Feedback**: Levenshtein Distance scoring for child-friendly accuracy thresholds.
- **Locales**: `en-US`, `fil-PH`, and Hiligaynon model support.

## 📝 TODO

- [x] Multilingual support (English, Filipino, Hiligaynon)
- [x] Offline speech recognition integration
- [x] Story Mode implementation
- [x] Animated celebratory screens
- [ ] Complete Teacher Mode CRUD via UI (currently semi-manual via JSON)
- [ ] Expansion of story library
- [ ] Gamified progression locks
- [ ] Performance optimization for low-end devices

## 📄 License

Created for educational purposes and literacy improvement.

---

**Made with ❤️ for young learners**
