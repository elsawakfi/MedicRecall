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
- **GitHub Repository URL:** [2024-MedicRecall2](https://github.com/spe-uob/2024-MedicRecall2)
- **Branching Strategy:**
  - `main` → Stable production branch
  - `dev` → Active development branch
- **Access & Permissions:**
  - Firebase access is managed via Firebase Console (Google Cloud IAM roles required).

## Installation & Setup
### Prerequisites
- Install - Flutter SDK version 3.24.3 ([Flutter Install Guide](https://docs.flutter.dev/release/archive))
  - Running Dart v3.5.3 ([Dart Install Guide](https://dart.dev/get-dart))
- Install Firebase CLI ([Firebase Setup Guide](https://firebase.google.com/docs/cli))
- Node.js (for Firebase functions): `brew install node` (Mac) / `choco install nodejs` (Windows)
- Chromedriver (for local CI testing): `brew install chromedriver` (Mac) / `choco install chromedriver` (Windows) 
- Android Studio (For mobile development): ([Android Studio Install Guide](https://developer.android.com/studio/install))

### Setup Steps
1. Clone the repository via:
   ```sh
   git clone https://github.com/spe-uob/2024-MedicRecall2.git
   ``` 
   or 
   ```sh
   git clone git@github.com:spe-uob/2024-MedicRecall2.git
   ```
2. Install dependencies:
   ```sh
   cd flashcard/
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

## Architecture Diagram
<p align="left">
  <img width="470" alt="architecture image" src="./Architecture/Architecture.png" style="box-shadow: 5px 5px 10px rgba(0,0,0,0.5)";>
</p>

## Project Structure
An overview of the important files contained within the project structure:
- [Root](#root-directory)
- [./.github](#github)
- [./flashcard](#flashcard)

### Root
The root directory contains essential files for project setup, documentation, and configuration.
```
2024-MedicRecall2
├── .github/         # GitHub files
├── docs/            # Project documentation
├── flashcard/       # Project code
└── README.md        # General overview
```

### ./.github
The `.github` directory houses our GitHub configurations, such as Continuous Integration/ Deployment pipelines, issue templates, and pull request guidelines.
```
.github/
├── workflows/                       # CI/CD pipelines (GitHub Actions)
│   ├── ci.yml                       # Workflow for testing & building Flutter app
│   └── deploy.yml                   # Deployment pipeline
├── ISSUE_TEMPLATE/                  # GitHub issue templates
│   └── OTHER.md                     # Template for creating issues
└── pull_request_template.md         # Standard PR guidelines
```


### ./flashcard
The `flashcard/` directory contains the main code for the app, which includes the Flutter source code, Firebase functions for the backend, and platform-specific configurations (Android, iOS, and Web).
```
flashcard/
├── integration_test/   # Contains integration tests for the entire app
├── functions/          # Firebase functions backend
├── lib/                # Main Flutter source code
│   ├── main.dart       # App entry point
│   ├── screens/        # UI screens
│   ├── widgets/        # Reusable components
│   └── utils/          # Utility functions
├── test/               # Unit tests
└── pubspec.yaml        # Flutter dependencies
```

## Testing & Debugging
**Running Tests:**
  ```sh
  cd flashcard/
  flutter test
  ```
**Running CI Locally:**

   To run Continuous Integration (CI) locally, follow these steps:

   1. Start the ChromeDriver

      In the first terminal, start the ChromeDriver by running the following command:

      ```
      chromedriver --port=4444
      ```

      This will start the ChromeDriver on port 4444.

   2. Run the Flutter Integration Test

      In the second terminal, execute the following command to run the Flutter integration test:

      ```
      flutter drive --driver=test_driver/integration_test_driver.dart --target=integration_test/app_test.dart -d web-server --headless
      ```

      Alternatively, you can use `"Chrome"` instead of `web-server --headless`:

      ```
      flutter drive --driver=test_driver/integration_test_driver.dart --target=integration_test/app_test.dart -d Chrome
      ```

      This will run the integration test on Chrome or in a headless web server environment.

