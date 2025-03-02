# MedicRecall2 Handover Document

## Contents
- [Project Overview](#project-overview)

## Project Overview
- **Project Name:** MedicRecall
- **Description:** A cross-platform application built with Flutter, using Firebase for backend services such as authentication, Firestore database, and cloud functions.
- **Tech Stack:**
  - Frontend: Flutter (Dart)
  - Backend: Firebase (Auth, Firestore, Functions, Hosting)
  - CI/CD: GitHub Actions

## Repository Details
- **GitHub Repository URL:** [GitHub Repo](https://github.com/spe-uob/2024-MedicRecall2)
- **Branching Strategy:**
  - `main` → Stable production branch
  - `develop` → Active development branch
- **Access & Permissions:**
  - Firebase access is managed via Firebase Console (Google Cloud IAM roles required).

## Installation & Setup
### Prerequisites
- Install Flutter SDK ([Flutter Install Guide](https://flutter.dev/docs/get-started/install))
- Install Dart ([Dart Install Guide](https://dart.dev/get-dart))
- Install Firebase CLI ([Firebase Setup Guide](https://firebase.google.com/docs/cli))
- Node.js (for Firebase functions): `brew install node` (Mac) / `choco install nodejs` (Windows)

### Setup Steps
1. Clone the repository:
   ```sh
   git clone https://github.com/spe-uob/2024-MedicRecall2.git
   cd 2024-MedicRecall2/flashcard
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Build the app:
   - Android:
   ```flutter build apk```
   - iOS: ```flutter build ios --release --no-codesign```
   - macOS: 
   ```flutter create --platforms=macos && flutter build macos```
   - Web browser: ```flutter build web```
4. Run the app:
   ```sh
   flutter run
   ```

## 4. Code Structure
```
flashcard/
├── lib/                # Main Flutter source code
│   ├── main.dart       # App entry point
│   ├── screens/        # UI screens
│   ├── widgets/        # Reusable components
│   ├── utils/          # Utility functions
├── functions/          # Firebase functions backend
├── android/            # Android-specific code
├── ios/                # iOS-specific code
├── web/                # Web-specific configurations
├── pubspec.yaml        # Flutter dependencies
README.md               # Project documentation
```
