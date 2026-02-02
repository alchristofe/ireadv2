# iRead App Walkthrough

This document provides a comprehensive guide to understanding, running, and navigating the current state of the **iRead** application.

## 1. Application Overview

**iRead** is a bilingual phonics learning application designed for young children. Its primary goal is to teach reading skills in **English** and **Filipino (Tagalog)** through an interactive, offline-first experience.

### Key Highlights

* **Bilingual Support**: Seamlessly switch between learning English and Filipino phonics.
* **Offline-First**: Functionality (including speech recognition) works fully offline.
* **Speech Recognition**: Uses **Vosk** for on-device speech-to-text to provide feedback on pronunciation.
* **Story Mode**: Includes bilingual fables like "Biag ni Lam-ang".
* **Teacher Mode**: A protected area for content management and settings.

---

## 2. How to Run the App

Follow these steps to set up and run the application on your local machine.

### Prerequisites

* **Flutter SDK**: Version 3.9.0 or higher.
* **Device**: Android Emulator or Physical Android Device (Recommended for Speech Recognition).

### Installation & Setup

1. **Install Dependencies**
    Fetch all the packages listed in `pubspec.yaml`.

    ```bash
    flutter pub get
    ```

2. **Generate Code (Hive Adapters)**
    Since the app uses Hive for local storage, you must generate the type adapters.

    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

3. **Run the Application**
    Launch the app on your connected device.

    ```bash
    flutter run
    ```

---

## 3. Core Features & User Flow

Here is a walkthrough of the primary screens and features currently implemented.

### A. Onboarding & Navigation

1. **Splash Screen**: Initializes the app, loads local storage (Hive), and starts background music.
2. **Language Selection**: The first interactive screen where the user selects the learning language (English or Filipino).
3. **Home / Category Selection**: Users choose between "Consonants" (Katinig), "Vowels" (Patinig), or "Stories".

### B. The Learning Loop (Lessons)

1. **Unit Selection**: Displays a grid of letters/units (e.g., 'A', 'B', 'C'). Completion status is tracked here.
2. **Lesson Screen**:
    * **Listen**: The app pronounces the letter/sound and provides word examples.
    * **Visuals**: High-quality images accompany every word.
    * **Speak**: The user is prompted to say the word. The app listens via the microphone and checks the pronunciation.
3. **Feedback**:
    * **Positive**: "Correct!", "Great job!"
    * **Constructive**: "Try again", "I heard [what caused the mismatch]".
4. **Completion**: A "Congratulations" screen appears with animations upon creating a unit.

### C. Story Mode

* Accessible from the main menu.
* Users can read stories like "The Monkey and the Turtle" or "Biag ni Lam-ang".
* Supports toggling between English and local languages for the narrative text.

### D. Teacher Mode

* **Access**: Hidden or via a specific button with a PIN lock (Default: `1234`).
* **Capabilities**:
  * Edit lesson content (JSON based).
  * View or reset progress.
  * Configure app settings.

---

## 4. Technical Snapshot

The application is built using a **Clean Architecture** pattern to ensure scalability.

### Architecture Layers

* **Presentation**: Flutter Widgets, Screens, and State Management (Provider).
* **Domain**: Business rules, Entities, and Use Cases.
* **Data**: Repositories, Data Sources (Local/Asset), and Hive Models.

### Key Tech Stack

* **State Management**: `Provider`
* **Local Database**: `Hive` (NoSQL)
* **Speech Recognition**: `vosk_flutter` (Offline)
* **Animations**: `rive` and standard Flutter animations.
* **Audio**: `audioplayers` for SFX and pronunciation.

---

## 5. Current State & Known Issues

### Functional

* ✅ Core navigation for English and Filipino.
* ✅ Lesson looping logic (Listen -> Speak -> Feedback).
* ✅ Offline speech recognition for English.
* ✅ Story mode asset rendering.

### Known Limitations / In Progress

* **Assets**: Some images or audio files might be using placeholders.
* **Filipino Speech Recognition**: Sensitivity may vary depending on the device and background noise.
* **Teacher Mode**: CRUD operations for adding new lessons are visually implemented but may require restarting to reflect file changes fully if not perfectly synced with Hive.

For more technical details, refer to `ARCHITECTURE.md` or `DOCUMENTATION.md`.
