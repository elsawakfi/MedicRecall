<p align="center">
<img src="flashcard/assets/newlogo.png" height="150">
<h1 id="title" align="center">2024-MedicRecall2</h1>

## Contents

<details>
  <summary>2024-MedicRecall2</summary>
  <ol>
    <li><a href="#project-requirements">Documentation</a></li>
    <li>
      <a href="#project-description">About The Project</a>
      <ul>
        <li><a href="#tech-stack">Built With (Tech Stacks)</a></li>
        <li><a href="#architecture-diagram">Architecture Diagram</a></li>
      </ul>
    </li>
    <li><a href="#project-requirements">Project Roadmap</a></li>
    <li><a href="#additional-features">Documentation</a></li>
    <li>
      <a href="#developer-guide">Getting Started (Developer Guide)</a>
      <ul>
        <li><a href="#requirements">Prerequisites</a></li>
        <li><a href="#build">Installation</a></li>
      </ul>
    </li>
    <li><a href="#user-guide">Usage (User Guide)</a></li>
    <li><a href="#stakeholders">Stakeholders</a></li>
    <li><a href="#user-stories">User Stories</a></li>
    <li><a href="#team-members">Team Members</a></li>
  </ol>
</details>

## Documentation
- [Kanban Board](https://github.com/orgs/spe-uob/projects/159/views/1)
- [Milestones](https://github.com/spe-uob/2024-MedicRecall2/milestones)
- [Issues](https://github.com/spe-uob/2024-MedicRecall2/issues)
- [Pull Requests](https://github.com/spe-uob/2024-MedicRecall2/pulls)
- [Contributors](https://github.com/spe-uob/2024-MedicRecall2/graphs/contributors)

<p align="right">(<a href="#title">back to top</a>)</p>
  
## About MedicRecall

This is the third iteration of the study support tool for medical students undergoing the MSRA exams. In this particular iteration, based on previous years’ work, we aim to:

- Implement a quarterly mock system with additional miniature mocks
- Release a working mobile app on both Android and iOS
- Update the UI to meet industry standards
- Develop a virtual study coach
- Improve the overall functionality of the website
- Include a generative AI model to familiarize learners with GMC standards

<p align="right">(<a href="#title">back to top</a>)</p>

### Built With (Tech Stacks)

- **Language**: [![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
- **Front-End**: [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white])](https://flutter.dev/)
- **Back-End**: [![Firebase](https://img.shields.io/badge/firebase-ffca28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
- **Database**: [![Cloud Firestore](https://img.shields.io/badge/Cloud%20Firestore-orange?style=for-the-badge&logo=internet)](https://firebase.google.com/docs/firestore)
- **Targeted Platforms**: ![web browser](https://img.shields.io/badge/web%20browser-blue?style=for-the-badge&logo=internet) ![Andriod](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white) ![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white) 

<details>
  <summary>Previous Firebase Structure</summary>
    <p align="left">
      <img width="470" alt="image" src="https://user-images.githubusercontent.com/98459342/215339659-6753675e-f5d8-4566-ab32-5f4cdd8817e5.png" style="box-shadow: 5px 5px 10px rgba(0,0,0,0.5)">
    </p>     
</details>

<p align="right">(<a href="#title">back to top</a>)</p>

### Architecture Diagram
<p align="left">
  <img width="470" alt="architecture image" src="docs/2024/Architecture/Architecture.png" style="box-shadow: 5px 5px 10px rgba(0,0,0,0.5)";>
</p>

<p align="right">(<a href="#title">back to top</a>)</p>

## Project Requirements

- **Learning Progress Tracking**<br>
  _MVP Release_
  - [x] Implement revision reminders
  - [x] Develop quarterly Mini Mocks
<br>

- **Quarterly Mini Mocks**<br>
  _MVP Release_
  - [x] Implemented mini-mock landing page with locked feature
  - [x] Implemented mini-mock rules page
  - [x] Implemented answer feedback page
  - [x] Implemented MCQ and ranking questions

  _BETA Release_
  - [x] Improved UI for mini-mock pages
  - [x] Implemented review page
  - [x] Implemented scoring page which takes in individual and average score
  
  _Final Release_
  - [x] Update the mini-mock colour scheme for light mode compatibility
  - [x] Implement a new ranking UI system, as proposed by the client 
  - [x] Update the mock related screens to be mobile compatible
  <br>

- **Countdown Button/ Scheduling-Calendar Feature**<br>
  _MVP Release_
  - [x] Complete exam countdown button that comes with a pop-up that prompts for study scheduling
  - [x] Mini mock and exam date events reflecting on calendar
  - [x] Automated pop-up notifications to prompt users who have not yet set their exam date and study schedule

  _BETA Release_
  - [x] Improved UI for button popups and calendar
  - [x] Complete implementing scheduling feature for four types of resources
  - [x] Complete calendar redesign with revision reminders and event labels

  _Final Release_
  - [x] Complete calendar redesign with single event edit/ delete feature and links to the respective page
  - [x] Scheduling feature which has exclusion of certain day(s) for studying
  - [x] Update the design to be mobile compatible 

### Additional Features

If time and resources permit we plan to include:
- **Virtual Study Coach**  
  - Implement a virtual coach similar to Duolingo’s 'Duo' character  
  - **Purpose:** Guide users through their exam preparation period

- **AI-Assisted Learning**  
  - Develop a generative AI model  
  - **Purpose:** Help users learn from GMC professionalism guidelines

- **Interactive Scenarios**  
  - Integrate video-simulated scenario questions  
  - **Purpose:** Enhance practical learning and decision-making skills

<p align="right">(<a href="#title">back to top</a>)</p>

## User Guide

The app is being hosted on Google Firebase [here](https://flashcard-6edc2.web.app/#landing)

<p align="right">(<a href="#title">back to top</a>)</p>

## Developer Guide

### Requirements

To build MedicRecall yourself, you will need the following tools:
- Android Studio ([Available here](https://developer.android.com/studio/install))
- An emulator capable of running either:
  - Android 6.0 or above, or
  - iOS 11.0 or above
- Flutter SDK version 3.24.3 ([Available here](https://docs.flutter.dev/release/archive))
  - (Running Dart version 3.5.3)
- A clone of the repository via: 
  ```sh
  git clone https://github.com/spe-uob/2024-MedicRecall2.git
  ``` 
  or 
  ```sh
  git clone git@github.com:spe-uob/2024-MedicRecall2.git
  ```

<p align="right">(<a href="#title">back to top</a>)</p>

### Build

1. Navigate to [flashcard](./flashcard) using
    ```sh
    cd flashcard/
    ```
2. To install the required dependencies, run
    ```sh
    flutter pub get
    ``` 
3. To build the app in:
   - Android: 
   ```sh
   flutter build apk
   ```
   - iOS: 
   ```sh
   flutter build ios --release --no-codesign
   ```
   - macOS:
   ```sh
   flutter create --platforms=macos
   flutter build macos
   ``` 
   - Web browser:  
   ```sh
   flutter build web
   ```
4. To start the app on a device or web browser run:
    ```sh
    flutter run
    ``` 

<p align="right">(<a href="#title">back to top</a>)</p>

## Stakeholders

**NHS (National Health Service)**
- **Role:** Public sector entity overseeing healthcare in the UK  
- **Aim:** To ensure well-prepared and competent doctors enter higher training roles  

**Trainee Doctors / Junior Doctors**  
- **Role:** Primary users of the platform  
- **Aim:** To prepare effectively for the Multi-Specialty Recruitment Assessment (MSRA) and improve their chances of securing higher training roles in preferred locations  

**Teachers**  
- **Role:** Supporters in the learning process  
- **Aim:** Ensure students are consistently tested and prepared  

<p align="right">(<a href="#title">back to top</a>)</p>

## User Stories

- **As a Trainee/Junior Doctor**, I want to access a variety of revision resources related to my course and retain the information effectively. I would require an accurate feedback system so that I can understand where I was wrong and how I could improve on my areas of weakness.

- **As a Doctor**, I want to quickly brush up on my knowledge so that I do not forget important concepts. I would prefer brief summaries of information so that I can study on the move or during breaks.

- **As a Teacher**, I want the program to have a scheduled examination system so that my students are constantly tested on their knowledge, ensuring they are learning. I would prefer the questions to differ from the revision assets to prevent complacency in learning.

<p align="right">(<a href="#title">back to top</a>)</p>

## Team Members

| Member                       | Email                                                 | Connect With Us! |
| ---------------------------- | ----------------------------------------------------- | ----------------- |
| Clarissa Ch'ng               | [fr22378@bristol.ac.uk](mailto:fr22378@bristol.ac.uk) | [![clarissa-linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/clarissa-chng/)
| Elsa Wakfi                   | [xp23980@bristol.ac.uk](mailto:xp23980@bristol.ac.uk) |[![elsa-linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/elsa-wakfi-9925fklg/)
| Tinaye Samuel Chibanda       | [ua20351@bristol.ac.uk](mailto:ua20351@bristol.ac.uk) | [![sam-linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/tinaye-samuel-chibanda-825280257/)
| Rowan Watcham                | [no23481@bristol.ac.uk](mailto:no23481@bristol.ac.uk) | [![rowan-linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/rowan-watcham/)
| Dennis Han                   | [jf23616@bristol.ac.uk](mailto:jf23616@bristol.ac.uk) | [![dennis-linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/dennis-han-660614333/)
| Saud Binlebdah               | [hr22169@bristol.ac.uk](mailto:hr22169@bristol.ac.uk) | [![saud-linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/saud-binlebdah/)

