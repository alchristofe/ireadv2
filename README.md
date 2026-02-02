# iRead - Bilingual Phonics Learning App

A Flutter mobile application for young children to learn phonics in English and Filipino. Features offline-first architecture, speech recognition, and teacher content management.

## 🎯 Features

### Core Learning Features
- **Bilingual Support**: Learn phonics in English or Filipino
- **Phonics Categories**: Separate lessons for consonants and vowels
- **Interactive Lessons**: Word examples with images and audio pronunciation
- **Speech Recognition**: On-device speech-to-text for pronunciation practice
- **Real-time Feedback**: Immediate "Correct" or "Try again" responses
- **Progress Tracking**: Local storage of completion and performance
- **Celebration Screens**: Animated congratulations after completing units

### Teacher Mode
- **PIN Protection**: Secure access with default PIN: 1234
- **Content Management**: Framework for adding/editing lessons (UI ready, full implementation pending)
- **Editable Data**: All lessons stored in JSON format for easy modification

### Technical Features
- **Offline-First**: Works completely without internet connection
- **Local Storage**: Hive database for progress and settings
- **Clean Architecture**: Separated data, domain, and presentation layers
- **Responsive Design**: Child-friendly UI with large buttons and clear icons
- **Audio Playback**: Pronunciation audio for all words
- **Animations**: Smooth transitions and celebratory effects

## 📁 Project Structure

```
iread/
├── lib/
│   ├── core/              # Constants, routes, utils, widgets
│   ├── data/              # Models, repositories, local storage
│   ├── domain/            # Business entities and use cases
│   └── presentation/      # Screens and providers
├── assets/
│   ├── images/            # Character, flag, word images
│   ├── audio/             # Pronunciation audio files
│   └── data/              # lessons.json
└── android/               # Android configuration
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Android device or emulator

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

1. **Splash Screen** - Animated logo with initialization
2. **Language Selection** - Choose English or Filipino
3. **Category Selection** - Choose Consonants or Vowels
4. **Unit Selection** - Grid of letter cards with completion indicators
5. **Lesson Screen** - Interactive learning with speech recognition
6. **Congratulations Screen** - Celebration after completing units
7. **Teacher Mode** - PIN-protected content editor (PIN: 1234)

## 🎨 Design System

### Colors
- Background: Warm beige (#FFF4E6)
- Primary: Orange (#FF8C42)
- Secondary: Blue (#4A90E2)
- Success: Green (#4CAF50)

### Typography
- Headings: Poppins (Bold)
- Body: Nunito (Regular)

## 📊 Data Structure

Edit `assets/data/lessons.json` to add content:

```json
{
  "languages": [
    {
      "type": "english",
      "categories": [
        {
          "type": "vowels",
          "units": [
            {
              "id": "eng_vowel_a",
              "letter": "A",
              "sound": "/æ/",
              "examples": [
                {
                  "word": "Apple",
                  "imageAsset": "assets/images/words/apple.png",
                  "audioAsset": "assets/audio/english/apple.mp3"
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

## 🔧 Adding New Content

1. **Add Word Images**: Place PNG files in `assets/images/words/`
2. **Add Audio Files**: Place MP3 files in `assets/audio/english/` or `assets/audio/filipino/`
3. **Update lessons.json**: Add new units or word examples

## 🎯 Current Sample Data

### English
- Vowels: A (Apple, Ant), E (Egg)
- Consonants: B (Ball, Book)

### Filipino
- Patinig: A (Aso, Araw)
- Katinig: B (Bola, Bahay)

## 🔊 Speech Recognition

- **English**: en-US locale
- **Filipino**: fil-PH locale
- **Matching**: Levenshtein distance with 80% similarity threshold
- **On-device**: No server calls required

## 💾 Local Storage

Uses Hive for:
- Progress tracking per unit
- Attempt history (correct/incorrect)
- User settings

## 📝 TODO

### Assets Needed
- [ ] Character illustrations (boy/girl)
- [ ] Flag images (US/Philippines)
- [ ] All word images
- [ ] Audio pronunciations
- [ ] Sound effects

### Features
- [ ] Complete teacher mode CRUD operations
- [ ] Add full alphabet coverage
- [ ] Implement progression locks
- [ ] Add mini-games
- [ ] Parent dashboard

## 🐛 Known Issues

1. Missing actual asset files (using placeholders)
2. Audio files need to be recorded
3. Teacher mode content editing not fully implemented
4. Filipino speech recognition may vary by device

## 📄 License

Created for educational purposes.

---

**Made with ❤️ for young learners**
