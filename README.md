# Lournal 📚

A modern language learning journal app that helps you track your progress, practice vocabulary, and maintain consistent study habits across multiple languages.

## ✨ Features

- **Multi-language Support**: Practice and track progress in multiple languages simultaneously
- **Daily Journal Entries**: Write reflections and notes about your language learning journey
- **Vocabulary Tracking**: Add new words, phrases, and their meanings with example sentences
- **Progress Analytics**: Visual charts and statistics to monitor your learning progress
- **Study Streaks**: Gamification elements to maintain consistent study habits
- **Offline Support**: Continue learning even without internet connection
- **Export & Backup**: Save your progress and export data for backup purposes
- **Clean, Intuitive UI**: Modern Material Design interface for seamless user experience

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Provider
- **Database**: Firebase Firestore
- **Local Storage**: SharedPreferences
- **UI Components**: Material Design 3
- **Platform**: iOS & Android

## 📱 How It Works

Lournal combines journaling, vocabulary building, and progress tracking to create a comprehensive language learning companion:

### 1. **Language Selection & Setup**
- Choose your target language(s) from a comprehensive list
- Set daily study goals and preferred study times
- Customize difficulty levels and learning objectives

### 2. **Daily Journaling**
- Write daily entries about your language learning experience
- Reflect on challenges, breakthroughs, and new discoveries
- Track mood and confidence levels for each study session

### 3. **Vocabulary Management**
- Add new words and phrases you encounter
- Include definitions, example sentences, and personal notes
- Organize vocabulary by topics, difficulty, or frequency of use
- Review words using spaced repetition algorithms

### 4. **Progress Tracking**
- Monitor daily study time and consistency
- View learning streaks and milestone achievements
- Analyze vocabulary growth over time
- Track confidence levels across different language skills

### 5. **Smart Reminders**
- Customizable notifications for study sessions
- Weekly review reminders for vocabulary practice
- Celebration notifications for achieving goals and milestones

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- iOS Simulator (for iOS development) or Android Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/lournal.git
   cd lournal
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For debug mode
   flutter run
   
   # For specific platform
   flutter run -d ios
   flutter run -d android
   ```

### Building for Production

```bash
# Build APK (Android)
flutter build apk --release

# Build iOS
flutter build ios --release

# Build App Bundle (Android)
flutter build appbundle --release
```

## 📊 Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── assets/                   # Static files like images
│   ├── google.png
│   ├── lournal-logo-background.png
│   └── ...
├── auth/                     # Authentication logic
│   ├── auth.dart
│   └── google_auth.dart
├── components/               # Reusable UI widgets
│   ├── custom_circular_progress_indicator.dart
│   ├── custom_snackbar.dart
│   └── ...
├── helper/                   # Helper & utility functions
│   ├── congrats_helper.dart
│   ├── date_format_helper.dart
│   └── ...
├── pages/                    # UI screens/pages
│   ├── create_page.dart
│   ├── edit_page.dart
│   └── ...
├── providers/                # State management
│   ├── cooldown_service.dart
│   └── notes_provider.dart
├── services/                 # Business logic & API services
│   ├── firestore.dart
│   └── storage_service.dart
├── sheets/                   # Bottom sheet widgets
│   ├── language_bottomsheet.dart
│   ├── privacy_policy_bottomsheet.dart
│   └── ...
└── theme/                    # App theme & styling
    ├── dark_mode.dart
    └── light_mode.dart

```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- The language learning community for inspiration and feedback
- Contributors and beta testers who helped improve the app

## 📧 Contact

For questions, suggestions, or support, please reach out:
- Create an issue on GitHub
- Email: [contact@maxaffinity.co.uk]

---

**Happy Learning! 🌟**