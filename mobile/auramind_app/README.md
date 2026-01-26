# Auramind Mobile App

Flutter-based mobile application for Auramind - Your Digital Soul Mirror.

## Setup

1. Install Flutter SDK (3.0.0 or higher)
2. Run `flutter pub get` to install dependencies
3. Update the API base URL in `lib/services/api_service.dart`

## Running the App

```bash
# Run on connected device/emulator
flutter run

# Run tests
flutter test

# Run integration tests
flutter test integration_test
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── screens/               # UI screens
│   ├── home_screen.dart
│   ├── mood_checkin_screen.dart
│   ├── chat_screen.dart
│   └── dashboard_screen.dart
├── widgets/               # Reusable widgets
├── services/              # API and business logic
│   └── api_service.dart
└── models/                # Data models
```

## Features

- **Mood Check-in**: Log daily mood, stress, and energy levels
- **AI Chat**: Empathetic conversation with AI companion
- **Dashboard**: Visual analytics and trends
- **Material 3 Design**: Modern, beautiful UI with dark mode support

## Dependencies

- `supabase_flutter`: Database and authentication
- `fl_chart`: Beautiful charts and graphs
- `google_fonts`: Custom typography
- `provider`: State management
