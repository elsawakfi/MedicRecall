# MedicRecall2 Handover Document

## Contents
- [Project Overview](#-project-overview)
- [Repository Details](#-repository-details)
- [Installation & Setup](#-installation--setup)
- [Architecture Overview](#️-architecture-overview)
- [Project Structure](#-project-structure)
- [Testing & Debugging](#️-testing--debugging)

## 📌 Project Overview
- **Project Name:** MedicRecall
- **Description:** A cross-platform application built with Flutter, using Firebase for backend services such as authentication, Firestore database, and cloud functions.
- **Tech Stack:**
  - Frontend: Flutter (Dart)
  - Backend: Firebase (Auth, Firestore, Functions, Hosting)
  - CI/CD: GitHub Actions

<p align="right">(<a href="#contents">back to top</a>)</p>

## 📂 Repository Details
- **🔗 GitHub Repository URL:** [2024-MedicRecall2](https://github.com/spe-uob/2024-MedicRecall2)
- **🛠 Branching Strategy:**
  - `main` → Stable production branch
  - `dev` → Active development branch
- **🔑 Access & Permissions:**
  - Firebase access is managed via Firebase Console (Google Cloud IAM roles required).
<p align="right">(<a href="#contents">back to top</a>)</p>

## 🚀 Installation & Setup
This guide will walk you through setting up and running MedicRecall on your local machine.

<b>🔗 Quick Links</b>
- [Prerequisites](#-prerequisites)
- [Setup Guide](#️-setup-guide)

> [!WARNING]
> We highly recommend using the specified Flutter, Dart, and Firebase versions mentioned below. 
> Using different versions may lead to compatibility issues. Additionally, ensure that all dependencies are properly installed before running the application.

### 📌 Prerequisites
Before you begin, make sure you have the following installed:
- <b>Flutter SDK version 3.24.3</b> ([Flutter Install Guide](https://docs.flutter.dev/release/archive))
  - Running <b>Dart v3.5.3</b> ([Dart Install Guide](https://dart.dev/get-dart))
- <b>Firebase CLI</b> ([Firebase Setup Guide](https://firebase.google.com/docs/cli))
- <b>Node.js</b> (Required for Firebase functions): 
  - macOS: `brew install node`
  - Windows: `choco install nodejs`
- <b>Chromedriver</b> (Required for local CI testing): 
  - macOS: `brew install chromedriver`
  - Windows: `choco install chromedriver`
- Android Studio (For mobile development): ([Android Studio Install Guide](https://developer.android.com/studio/install))

> [!NOTE]
> Ensure that Firebase is set up correctly by adding the following files to the appropriate directories:
> - `google-services.json` (Android)
> - `GoogleService-Info.plist` (iOS/macOS)
> Without these files, Firebase-related features will not function properly.

### ⚙️ Setup Guide
1. Clone the repository using either HTTPS or SSH:
   ```sh
   git clone https://github.com/spe-uob/2024-MedicRecall2.git #https
   ``` 
   or 
   ```sh
   git clone git@github.com:spe-uob/2024-MedicRecall2.git #ssh
   ```
2. Install dependencies:
  Navigate to the project directory and install dependencies:
   ```sh
   cd flashcard/
   flutter pub get
   ```
3. Build the app:
  Run the appropriate command to build the app for your desired platform:
   - <b>📱 Android:</b>
   ```sh 
   flutter build apk
   ```
   - <b> 🍏 iOS: </b>
   ```sh
   flutter build ios --release --no-codesign
   ```
   - <b> 💻 macOS: </b>
   ```sh
   flutter create --platforms=macos && flutter build macos
   ```
   - <b> 🌍 Web browser: </b>
   ```sh
   flutter build web
   ```
4. Run the app:
  To launch the app, run: 
   ```sh
   flutter run
   ```
<p align="right">(<a href="#contents">back to top</a>)</p>

## 🏗️ Architecture Overview
The following diagram illustrates the MedicRecall system architecture, highlighting the interaction between the frontend Flutter application and Firebase backend services.

<p align="left">
  <img width="470" alt="architecture image" src="./Architecture/Architecture.png" style="box-shadow: 5px 5px 10px rgba(0,0,0,0.5)";>
</p>
<p align="right">(<a href="#contents">back to top</a>)</p>

## 📂 Project Structure
This section provides an overview of the important files contained within the project structure:
- [Root](#-root-directory)
- [./.github](#️-github)
- [./flashcard](#-flashcard)

### 🏠 Root Directory
The root directory contains essential files for <b>project setup, documentation, and configuration</b>.
```
2024-MedicRecall2
├── .github/         # GitHub files
├── docs/            # Project documentation
├── flashcard/       # Project code
└── README.md        # General overview
```

### ⚙️ ./.github
The `.github` directory houses our GitHub configurations, such as <b>Continuous Integration/ Deployment pipelines, issue templates, and pull request guidelines</b>.
```
.github/
├── workflows/                       # CI/CD pipelines (GitHub Actions)
│   ├── ci.yml                       # Workflow for testing & building Flutter app
│   └── deploy.yml                   # Deployment pipeline
├── ISSUE_TEMPLATE/                  # GitHub issue templates
│   └── OTHER.md                     # Template for creating issues
└── pull_request_template.md         # Standard PR guidelines
```

<b> 📝 ./.github/ISSUE_TEMPLATE </b>
This directory contains pre-defined issue templates that help </b>streamline issue reporting</b> and ensure consistency in bug reports and feature requests.

To keep things clear, we recommend maintaining two separate templates:
- 🔹 Bug Report Template – For reporting software defects, crashes, or unexpected behavior.
- 🔹 Feature Request Template – For suggesting new enhancements or functionalities.

> <b>📌 Tip:</b> Well-defined issue templates improve collaboration by providing maintainers with all necessary details upfront.

📖 More Info: [GitHub Issue Templates Guide](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/manually-creating-a-single-issue-template-for-your-repository).

### 📱 ./flashcard
The `flashcard/` directory contains the <b>main source code</b> for the app, which includes the Flutter source code, Firebase functions for the backend, and platform-specific configurations (Android, iOS, and Web).
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

<b>📌 Key Components:</b>
- ✅ `lib/screens/` – All UI screens and page layouts.
- ✅ `lib/widgets/` – Modular, reusable UI components.
- ✅ `lib/models/` – Data structures and app logic.
- ✅ `lib/services/ `– API requests, Firebase interactions, and authentication handling.
- ✅ `test/` & `integration_test/` – Unit and integration tests for app stability.

> <b>💡 Best Practice:</b> Write clean, well-organized, and well-documented code to ensure scalability and maintainability.
>
> <i>📖 We have included comments throughout the code to explain functionality, making it easier to understand and modify when needed.</i>
<p align="right">(<a href="#contents">back to top</a>)</p>

## 🛠️ Testing & Debugging
**Running Unit & Widget Tests**
Run unit and widget tests to verify core functionalities:
  ```sh
  cd flashcard/
  flutter test
  ```
This will execute all tests inside the `test/` directory.

**Running CI Locally:**

   To run Continuous Integration (CI) locally, follow these steps:

   1. Start the ChromeDriver

      In the first terminal, start the ChromeDriver by running the following command:

      ```sh
      chromedriver --port=4444
      ```

      This will start the ChromeDriver on port 4444.

   2. Run the Flutter Integration Test

      In the second terminal, execute the following command to run the Flutter integration test:

      ```sh
      flutter drive --driver=test_driver/integration_test_driver.dart --target=integration_test/app_test.dart -d web-server --headless
      ```

      Alternatively, you can use `"Chrome"` instead of `web-server --headless`:

      ```sh
      flutter drive --driver=test_driver/integration_test_driver.dart --target=integration_test/app_test.dart -d Chrome
      ```

      This will run the integration test on Chrome or in a headless web server environment.

> 💡 Debugging Tips
> - Use `flutter logs` to view real-time logs and errors.
> - Add `print()` statements inside tests or your code for debugging purposes.
> - Check Firebase logs in the Firebase Console for backend-related issues.
> - If tests fail inconsistently, try running with `flutter test --`coverage` to track untested code paths.
<p align="right">(<a href="#contents">back to top</a>)</p>
