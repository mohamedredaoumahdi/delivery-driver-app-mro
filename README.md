# Delivery Driver App

A cross-platform mobile application for delivery drivers built with Flutter and Firebase. This app allows drivers to log in, view assigned deliveries, track customer locations, and confirm deliveries using a QR code scanner.

## Features

- **Authentication**: Secure login with email and password
- **Order Management**: View pending, in-progress, and completed deliveries
- **Location Tracking**: Track driver location and navigate to customer addresses
- **QR Code Scanning**: Confirm pickup and delivery using QR codes
- **Push Notifications**: Receive alerts for new deliveries and updates
- **Offline Support**: Basic functionality works without internet connection

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Data classes representing entities like orders and drivers
- **Views**: UI components including screens and widgets
- **ViewModels**: Business logic that connects models to views

## Project Structure

```
lib/
  ├── config/           # Configuration settings
  ├── models/           # Data models
  ├── services/         # Services for Firebase, location, etc.
  ├── viewmodels/       # Business logic
  ├── views/            # UI components
  │   ├── screens/      # Full app screens
  │   └── widgets/      # Reusable UI widgets
  └── main.dart         # App entry point
```

## Setup Instructions

### Prerequisites

- Flutter SDK (version 3.7.0 or higher)
- Dart SDK (version 3.0.0 or higher)
- Firebase account

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/delivery_driver_app.git
   cd delivery_driver_app
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Configure Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download the configuration files (google-services.json and GoogleService-Info.plist)
   - Place the configuration files in the appropriate directories

4. Create a MyKeysConfig.dart file:
   ```dart
   // lib/config/MyKeysConfig.dart
   class MyKeysConfig {
     static const String firebaseApiKey = "YOUR_FIREBASE_API_KEY";
     static const String firebaseAuthDomain = "YOUR_FIREBASE_AUTH_DOMAIN";
     static const String firebaseProjectId = "YOUR_FIREBASE_PROJECT_ID";
     static const String firebaseStorageBucket = "YOUR_FIREBASE_STORAGE_BUCKET";
     static const String firebaseMessagingSenderId = "YOUR_FIREBASE_MESSAGING_SENDER_ID";
     static const String firebaseAppId = "YOUR_FIREBASE_APP_ID";
     static const String googleMapsApiKey = "YOUR_GOOGLE_MAPS_API_KEY";
     static const bool useMockServices = false; // Set to true for development
   }
   ```

5. Run the app:
   ```
   flutter run
   ```

## Development Guide

### Using Mock Services

During development, you can use mock services instead of connecting to Firebase:

1. Set `useMockServices = true` in the MyKeysConfig.dart file
2. The app will use mock data from MockFirebaseService instead of real Firebase data

### Adding New Features

1. Create or modify models in the models/ directory
2. Add business logic in the viewmodels/ directory
3. Create UI components in the views/ directory
4. Update services as needed for backend integration

## Testing

Run tests using the following command:

```
flutter test
```

## Deployment

### Android

1. Update the version in pubspec.yaml
2. Build the APK:
   ```
   flutter build apk --release
   ```
3. Deploy to Google Play Store

### iOS

1. Update the version in pubspec.yaml
2. Build the iOS app:
   ```
   flutter build ios --release
   ```
3. Deploy to Apple App Store using Xcode

## License

This project is licensed under the MIT License - see the LICENSE file for details.