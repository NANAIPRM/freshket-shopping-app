# App Name

[![Flutter Version](https://img.shields.io/badge/Flutter-3.24.5-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.3.0-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A short description of your application. Explain what your app does in 1-2 sentences.

![App Screenshot](screenshots/app_screenshot.png)

## Features

- Feature 1: Brief description
- Feature 2: Brief description
- Feature 3: Brief description

## Getting Started

### Prerequisites

- [FVM (Flutter Version Management)](https://fvm.app/)
- Flutter SDK 3.24.5 (managed by FVM)
- Dart SDK (compatible with Flutter 3.24.5)
- Android Studio / VS Code / IntelliJ IDEA
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/NANAIPRM/freshket-shopping-app.git
   ```

2. Navigate to the development branch
   ```bash
   git checkout develop
   ```

3. Setup FVM with the correct Flutter version
   ```bash
   fvm install 3.24.5
   fvm use 3.24.5
   ```

4. Install dependencies
   ```bash
   fvm flutter pub get
   ```

5. Run the app
   ```bash
   fvm flutter run
   ```

## FVM Configuration

This project uses Flutter Version Management (FVM) to ensure all developers use the same Flutter version (3.24.5). The configuration is in `.fvm/fvm_config.json`.

```json
{
  "flutterSdkVersion": "3.24.5",
  "flavors": {}
}
```

For IDE integration:
- **VS Code**: FVM extension is recommended
- **Android Studio/IntelliJ**: Configure to use the FVM Flutter SDK path

## Project Structure

```
```
lib/
├── config/                      # Configuration Layer
│   └── app_config.dart
├── data/                        # Data Layer
│   ├── models/                  # Data Models
│   │   ├── cart_item.dart
│   │   └── product.dart
│   └── services/                # API Services
│       └── api_service.dart
├── logic/                       # Business Logic Layer
│   └── blocs/                   # BLoC State Management
│       ├── cart/                # Cart Feature
│       │   ├── cart_bloc.dart
│       │   ├── cart_event.dart
│       │   └── cart_state.dart
│       ├── latest_product/      # Latest Product Feature
│       │   ├── latest_product_bloc.dart
│       │   ├── latest_product_event.dart
│       │   └── latest_product_state.dart
│       └── recommend_product/   # Recommend Product Feature
│           ├── recommended_product_bloc.dart
│           ├── recommended_product_event.dart
│           └── recommended_product_state.dart
├── ui/                          # Presentation Layer
│   ├── pages/                   # App Screens/Pages
│   │   ├── cart_page.dart
│   │   ├── checkout_success_page.dart
│   │   └── home_page.dart
│   └── widget/                  # UI Components
│       └── common/              # Shared Widgets
│           ├── bottom_loading_indicator.dart
│           ├── custom_bottom_navigation_bar.dart
│           ├── product_list_item.dart
│           └── product_shimmer_item.dart
└── main.dart                    # App Entry Point
```
```

## Architecture

This app follows the Feature-First Architecture architecture pattern. 
- Team Collaboration: Different developers or teams can work on separate features simultaneously with minimal code conflicts
- Scalability: Adding new features doesn't disrupt existing code structure
- Feature Reusability: Makes it easier to reuse or extract features for other projects

## State Management

This project uses Bloc for state management. 

- Separation of Logic and UI: BLoC separates business logic from UI, making the code easier to maintain and test.
- Efficient State Management: It uses Streams to manage state changes efficiently without refreshing the entire UI.
- Reactive Programming: BLoC is ideal for real-time updates, such as loading data from APIs or databases.
- Testability: Business logic can be tested independently of the UI, improving test coverage.
- Clean and Standardized Code: BLoC promotes clean, maintainable, and standardized code, making collaboration easier in the long term.

## Dependencies

- `provider`: ^6.0.5 - For state management
- `http`: ^1.1.0 - For API requests
- `shared_preferences`: ^2.2.0 - For local storage
- `flutter_bloc`: ^8.1.3 - For BLoC pattern implementation

## Testing

```bash
# Run unit tests
fvm flutter test

# Run widget tests
fvm flutter test test/widget_test.dart

# Run integration tests
fvm flutter test integration_test
```

## Deployment

### Android

1. Generate an upload keystore
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Create `key.properties` file

3. Build the APK
   ```bash
   fvm flutter build apk --release
   ```

### iOS

1. Open the Xcode workspace
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Configure signing in Xcode

3. Build the app
   ```bash
   fvm flutter build ios --release
   ```

## Contact

Developer Name - Porramat Chairattanah - porramat.cha@gmail.com
