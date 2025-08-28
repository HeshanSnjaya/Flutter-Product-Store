# Thrive360 Store – Flutter Mobile Application

A production-ready Flutter application demonstrating Clean Architecture, modern UI/UX, and robust API integration for the Thrive360 Mobile Developer assignment.

---

## Project Overview

This Flutter app consumes the Thrive360 Store Service API to display and filter store items with a professional, responsive interface.

---

## 🏗️ Architecture

### Clean Architecture + MVVM + Riverpod

**Why this architecture?**
- **Maintainability:** Clear separation of concerns across presentation, domain, and data layers.
- **Scalability:** Easy feature addition and modification.
- **Testability:** Each layer can be independently tested.
- **Team Collaboration:** Standard organization for multi-developer teams.
- **Business Logic Isolation:** Domain layer holds all pure business logic.

**Layer Structure:**

lib/
├── core/ # Shared utilities/configurations
├── features/items/ # Items feature module
│ ├── data/ # API integration, models, repositories
│ ├── domain/ # Entities, use cases, repository contracts
│ └── presentation/ # UI, widgets, state managers
└── shared/ # Reusable UI components


**State Management:** Riverpod  
- Compile-time safety, optimal rebuilds, and great DX.

---

## UI/UX Design Choices

- **Material Design 3:** Latest guidelines for a modern look and consistent theming.
- **Responsive Design:** Adapts seamlessly to mobile, tablet, and desktop.
- **Animations:** Smooth transitions and micro-interactions using `flutter_animate`.
- **Loading States:** Shimmer effect with `shimmer` for professional loading feedback.
- **Error Handling:** Informative UI and retry flows for all major error types.
- **Premium Details:** Category badges, icons, Google Fonts, and visual polish.

---

## Features

- **Item List:** Shows all items from `/items` endpoint (name, brand, category).
- **Filter:** Category and subCategory filtering with `/items/filter`.
- **Error Handling:** Network/API errors handled at the UI level.
- **Health Check:** API warm-up status banner.
- **Responsive UI:** Adaptable grid/list layout.
- **Animations & Feedback:** Enhanced cards, buttons, shimmer loading, and interactions.
- **State Management:** All state handled with Riverpod.

---

## Setup & Usage

### Prerequisites
- Flutter 3.10.0+ & Dart 3.0.0+
- Android SDK or iOS setup

### Local Installation

- git clone https://github.com/YOUR_USERNAME/thrive360-store-app.git
- cd thrive360-store-app
- flutter pub get
- flutter pub run build_runner build --delete-conflicting-outputs
- flutter run

### Build Release APK (Android)

flutter build apk --release

Result: `build/app/outputs/flutter-apk/app-release.apk`

---

## Submission Requirements Fulfilled

- **Item List View:** /items endpoint with name/brand/category
- **Filtering Functionality:** /items/filter endpoint (category & subCategory)
- **Error Handling:** Professional screens for network & API errors
- **UI/UX:** Material 3, responsive UI, animations, and micro-interactions
- **State Management:** Riverpod with modular architecture

---

## Known Issues

- **API Quota:** The demo API may periodically return "RESOURCE_EXHAUSTED" or 500 errors due to rate limits (not an app bug).
- **Cold Start:** The API can take 15–30s to "warm up" if idle (normal for scale-to-zero).
- **Offline:** App does not support offline mode (future enhancement).
- **Minor:** Some further visual polish is possible, but all major features and flows are implemented.

---

## AI Tool Declaration

- **Perplexity AI:** Used for architecture research, error handling improvements, modern UI/UX suggestions, and documentation structure.
- **Other tools:** None, except standard IDE auto-completion.

---

## Further Notes

- **Documentation:** Architectural reasoning, UI/UX choices, known issues, and tooling are all described above as per assignment instructions.
- **Improvement Areas:** Offline caching and deeper test coverage could be future improvements.
- **Contact:** [ridmikasankalpanee@gmail.com]

---

**Architecture:** Clean Architecture + MVVM + Riverpod  
**Status:** Production Ready ✔️

---

