# Thrive360 Store - Flutter Mobile Application

A production-ready Flutter application demonstrating Clean Architecture, modern UI/UX, and robust API integration.

## Architecture

**Clean Architecture + MVVM + Riverpod**

Chosen for:
- **Maintainability**: Clear separation of concerns
- **Scalability**: Easy to add features and modify existing ones
- **Testability**: Each layer can be tested independently
- **Team Collaboration**: Standardized structure for multiple developers

### Layer Structure:
- **Presentation**: UI components, state management, user interactions
- **Domain**: Business logic, entities, use cases
- **Data**: API integration, data models, repositories

## UI/UX Design Choices

- **Material Design 3**: Modern, accessible interface
- **Responsive Design**: Adapts to phones, tablets, and desktop
- **Animations**: Smooth transitions and micro-interactions
- **Error States**: User-friendly error handling with retry options

## Known Issues

- API service occasionally hits quota limits (server-side limitation)
- Cold start delays for Choreo-hosted service (up to 30 seconds first request)
- Shimmer loading requires additional dependencies

## AI Tool Declaration

- **Perplexity AI**: Used for architectural guidance, code generation, best practices research, and documentation assistance

## Setup Instructions

1. Clone repository
2. Run `flutter pub get`
3. Run `flutter pub run build_runner build`
4. Run `flutter run`

## Dependencies

See `pubspec.yaml` for complete list including Riverpod, Dio, Google Fonts, Flutter Animate, and Shimmer.
