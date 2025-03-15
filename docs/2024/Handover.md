# MedicRecall2 Handover Document

## Contents
- [Project Overview](#-project-overview)
- [Repository Details](#-repository-details)
- [Installation & Setup](#-installation--setup)
- [Architecture Overview](#️-architecture-overview)
- [Project Structure](#-project-structure)
- [Testing & Debugging](#️-testing--debugging)
- [Database Structure](#-database-structure)
- [Cloud Functions](#️-cloud-functions)

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

**🔗 Quick Links**
- [Prerequisites](#-prerequisites)
- [Setup Guide](#️-setup-guide)

> [!WARNING]
> We highly recommend using the specified Flutter, Dart, and Firebase versions mentioned below. 
> Using different versions may lead to compatibility issues. Additionally, ensure that all dependencies are properly installed before running the application.

### 📌 Prerequisites
Before you begin, make sure you have the following installed:
- **Flutter SDK version 3.24.3** ([Flutter Install Guide](https://docs.flutter.dev/release/archive))
  - Running **Dart v3.5.3** ([Dart Install Guide](https://dart.dev/get-dart))
- **Firebase CLI** ([Firebase Setup Guide](https://firebase.google.com/docs/cli))
- **Node.js** (Required for Firebase functions): 
  - macOS: `brew install node`
  - Windows: `choco install nodejs`
- **Chromedriver** (Required for local CI testing): 
  - macOS: `brew install chromedriver`
  - Windows: `choco install chromedriver`
- Android Studio (For mobile development): ([Android Studio Install Guide](https://developer.android.com/studio/install))

> [!NOTE]
> Ensure that Firebase is set up correctly by adding the following files to the appropriate directories:
> - `google-services.json` (Android)
> - `GoogleService-Info.plist` (iOS/macOS)
> Without these files, Firebase-related features will not function properly.
<p align="right">(<a href="#contents">back to top</a>)</p>

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
   - **📱 Android:**
   ```sh 
   flutter build apk
   ```
   - **🍏 iOS:**
   ```sh
   flutter build ios --release --no-codesign
   ```
   - **💻 macOS:**
   ```sh
   flutter create --platforms=macos && flutter build macos
   ```
   - **🌍 Web browser:**
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
  <img width="714" alt="architecture image" src="./Architecture/Architecture.png" style="box-shadow: 5px 5px 10px rgba(0,0,0,0.5)";>
</p>
<p align="right">(<a href="#contents">back to top</a>)</p>

## 📂 Project Structure
This section provides an overview of the important files contained within the project structure:
- [Root Directory](#-root-directory)
- [./.github](#️-github)
- [./flashcard](#-flashcard)

### 🏠 Root Directory
The root directory contains essential files for **project setup, documentation, and configuration**.
```
2024-MedicRecall2
├── .github/         # GitHub files
├── docs/            # Project documentation
├── flashcard/       # Project code
└── README.md        # General overview
```

### ⚙️ ./.github
The `.github` directory houses our GitHub configurations, such as **Continuous Integration/ Deployment pipelines, issue templates, and pull request guidelines**.
```
.github/
├── workflows/                       # CI/CD pipelines (GitHub Actions)
│   ├── ci.yml                       # Workflow for testing & building Flutter app
│   └── deploy.yml                   # Deployment pipeline
├── ISSUE_TEMPLATE/                  # GitHub issue templates
│   └── OTHER.md                     # Template for creating issues
└── pull_request_template.md         # Standard PR guidelines
```
**🔧 ./.github/workflows**
This directory contains the workflows required for **GitHub Actions** to run tests and deploy our project. The diagram outlining this can be found [here](#️-cicd-diagram).

**📝 ./.github/ISSUE_TEMPLATE**
This directory contains pre-defined issue templates that help **streamline issue reporting** and ensure consistency in bug reports and feature requests.

To keep things clear, we recommend maintaining two separate templates:
- 🔹 Bug Report Template – For reporting software defects, crashes, or unexpected behavior.
- 🔹 Feature Request Template – For suggesting new enhancements or functionalities.

> **📌 Tip:** Well-defined issue templates improve collaboration by providing maintainers with all necessary details upfront.

📖 More Info: [GitHub Issue Templates Guide](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/manually-creating-a-single-issue-template-for-your-repository).

<p align="right">(<a href="#contents">back to top</a>)</p>

### 📱 ./flashcard
The `flashcard/` directory contains the **main source code** for the app, which includes the Flutter source code, Firebase functions for the backend, and platform-specific configurations (Android, iOS, and Web).
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

**📌 Key Components:**
- ✅ `lib/screens/` – All UI screens and page layouts.
- ✅ `lib/widgets/` – Modular, reusable UI components.
- ✅ `lib/models/` – Data structures and app logic.
- ✅ `lib/services/ `– API requests, Firebase interactions, and authentication handling.
- ✅ `test/` & `integration_test/` – Unit and integration tests for app stability.

> **💡 Best Practice:** Write clean, well-organized, and well-documented code to ensure scalability and maintainability.
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

      ```console
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
> - Ensure that you have properly used tester pumps where necessary for proper widget loading.
> - Add `tester.printToConsole()` statements inside tests or your code for debugging purposes.
> - Check Firebase logs in the Firebase Console for backend-related issues.

### ⚙️ CI/CD Diagram
The following diagram illustrates the MedicRecall CI/CD system, highlighting the key paths for running both testing and deployment.
<p align="left">
  <img width="621" alt="ci/cd image" src="./CI-CD-diagram/CI-CD-Diagram.png" style="box-shadow: 5px 5px 10px rgba(0,0,0,0.5)";>
</p>

<p align="right">(<a href="#contents">back to top</a>)</p>


## 💾 Database Structure
This section provides an overview of the [firestore](https://firebase.google.com/docs/firestore) and the main root collections:
- [Flashcards](#-flashcards)
- [Markscheme](#-markscheme)
- [Mocks](#-mocks)
- [Topics](#-topics)
- [Users](#-users)

### 📇 Flashcards
The flashcard collection contains documents that detail each of the default flashcards available to the user.

Each document within the **flashcard** collection contains: 
| Field                 | Data Type | Explanation |
|-----------------------|-----------|-------------|
| ```back```            | String    | Contains the flashcard's answer |
| ```front```           | String    | Contains the flashcard's question |
| ```owner```           | String    |  |
| ```subtopic```        | String    | For fine tuning the specific segment of the flashcard's topic |
| ```topic```           | String    | The related flashcard topic |

### 📑 Markscheme
The marksheme collection contain a vast array of question documents which are queried from the app when the user is interacting with the markscheme system.

Each document within the **markscheme** collection contains: 
| Field                 | Data Type       | Explanation |
|-----------------------|-----------------|-------------|
| ```action``` | String    | Contains the action performed in the context of the situation |
| ```answer``` | String    | Contains the correct answer to the question |
| ```bool``` | String    | States whether the question is official or not |
| ```explanation```     | String    | Provides a rationale for the correct answer |
| ```indicator```         | String    | Contains the question number |
| ```question```        | String    | Contains the question number |
| ```Situation```  | String    | The text that provides context to the scenario |
| ```type```            | String    | Details whether the question is of type `rating`, `ranking` or `multiple choice` for easier filtering |

### 📝 Mocks
The mock collections follow the same principle as the markscheme collection, however whilst the markscheme and mock documents are similar, they do contain different fields. The mock documents are queried whenever the user is interacting with their related mock exam.

Each document within the **mock** collections contains:
| Field                 | Data Type | Explanation |
|-----------------------|-----------|-------------|
| ```correct_answers``` | Array&lt;String&gt;    | Contains the correct answers to the question |
| ```explanation```     | String    | Provides a rationale for the correct answers |
| ```options```         | Array&lt;String&gt;    | Contains the options from which the user will select their answer from |
| ```question```        | String    | The question text |
| ```questionNumber```  | Number    | Allows for correct question ordering |
| ```type```            | String    | Details whether the question is of type `ranking` or `multiple choice` for easier filtering |

> [!NOTE]
>The markscheme collection was created by our ancestors whilst the mock collections were created by the MedicRecall2 2024 team hence the difference in document structure.

### 📖 Topics
The topics collection is referenced in flashcards as each document of topics contains a topic used to group flashcards.

Each document within the **topics** collection contains: 
| Field                 | Data Type | Explanation |
|-----------------------|-----------|-------------|
| ```color``` | String    | For design purposes |
| ```emoji```     | String    | For design purposes |
| ```numberOfCards```         | Number    | Total number of flashcards associated with that topic |
| ```subtopicLength```        | Array&lt;Number&gt;    | How many flashcards are associated to each subtopic |
| ```subtopics```  | Array&lt;String&gt;    | The subtopics of the topic |
| ```topic```            | String    | The name of the topic itself |

### 🗿 Users
The users collection contains documents associated to each user on the platform.

Each document within the **users** collection contains:
| Field                 | Data Type | Explanation |
|-----------------------|-----------|-------------|
| ```events``` | Collection    | Contains all major events scheduled for the user |
| ```examAnswers``` | Collection    | Contains all answers the user has entered in the mock exams |
| ```flashcardsSeen``` | Collection    | Contains all individual flashcards the user has revised and their choices |
| ```TestDay``` | Timestamp    | The timestamp for the user's test day, used for exam scheduling |
| ```email```     | String    | The user's email |
| ```excludedDays```         | Array&lt;String&gt;    | The days that the user doesn't want to revise on |
| ```fullSizedMockRepetitions```        | Number    | Number of times the user wants to schedule the full mock exam |
| ```name```  | String    | The user's username |
| ```notify```            | Boolean    | Whether the user wants to be notified or not |
| ```officialMSRARepetitions```            | Number    | Number of times the user wants to schedule the MSRA |
| ```selectedResources```            | Array&lt;String&gt;    | The chosen revision resources |
| ```topicCount```            | Array&lt;Number&gt;    | Number of times the user has seen a topic |
| ```topicLastSeen```            | Array&lt;Timestamp&gt;    | Last time the user revised a topic |
| ```topicScore```            | Array&lt;Number&gt;    | The score for each revised topic |
| ```topicsSeen```            | Array&lt;String&gt;    | The revised topics |
| ```userID```            | String    | The user's auth ID (different to their document ID) |

<p align="right">(<a href="#contents">back to top</a>)</p>

## ☁️ Cloud Functions
[Cloud Functions](https://firebase.google.com/docs/functions) are serverless functions that allow you to run code in response to [events](https://cloud.google.com/functions/docs/calling) without managing the underlying infrastructure.
The current functions consist of:
- `sendEmail` - A HTTP triggered function used to notify users of their revision schedule, and
- `update_exam_score` - An event triggered function that updated the global average score of a mock exam whenever a user's associated exam's score field is updated.

### 📨 Deploying Cloud Functions with Firebase
#### Prerequisites
1. **Firebase Account:** Ensure you have an account connected to the firebase with the role 'Cloud Functions Admin'.

2. **Node.js and npm:** Install Node.js (npm comes bundled with it).

3. **Firebase CLI:** Install the Firebase CLI globally:
    ```bash
    npm install -g firebase-tools
    ```
4. Python: Ensure Python 3.7+ is installed on your system.

#### Step 1: Set Up the Environment
1. Log into firebase from the CLI:
    ```bash
    firebase login
    ```

2. Navigate to the functions directory:

    ```bash
    cd functions
    ```
  
3. Create a virtual environment for Python:

    ```bash
    python3 -m venv venv
    ```

4. Activate the virtual environment:

    - On macOS/Linux:
      ```bash
      source venv/bin/activate
      ```

    - On Windows

      ```bash
      venv\Scripts\activate
      ```

5. Install required Python packages:

    ```bash
    pip install -r requirements.txt
    ```
> [!NOTE]
> Cloud Functions can also be written using Node.js however this project uses Python.

#### Step 2: Write / Edit the Function
1. Open the ```main.py``` file in the functions directory.
2. Write your Python function [(Guide)](https://firebase.google.com/docs/functions/get-started?gen=2nd)

#### Step 3: Test the Function
1. Run the Firebase Emulator Suite:
    ```bash
    firebase emulators:start
    ```
2. The emulator will display a URL like: 
    ```bash
    http://localhost:5001
    ```
3. Trigger your emulated function, whether that be by sending it a HTTP request or updating a field in an emulated firestore database.
#### Step 4: Deploy to Production
1. Once you've tested your function locally and confirmed it works as expected, deploy it to Firebase:
    ```bash
    firebase deploy --only functions
    ```

<p align="right">(<a href="#contents">back to top</a>)</p>