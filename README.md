# Budgetary - Flutter Expense Tracking App

## Overview
Complete Flutter expense tracking application with Firebase integration, smooth animations, and neumorphic UI design.

## Features
- 🔐 Authentication (Email/Password + Google Sign-in)
- 📊 Dashboard with budget overview
- 💰 Expense management with categories
- 📈 Reports and analytics
- 🎨 Beautiful neumorphic UI with smooth animations
- 🌓 Dark/Light theme support
- 📱 Responsive design

## Setup Instructions

### 1. Prerequisites
- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.0.0 or higher)
- Firebase project setup
- Android Studio / VS Code

### 2. Installation
```bash
# Extract the zip file
# Navigate to the project directory
cd budgetary

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### 3. Firebase Configuration
1. Create a Firebase project at https://console.firebase.google.com
2. Enable Authentication (Email/Password and Google)
3. Set up Cloud Firestore
4. Add your `google-services.json` to `android/app/`
5. Update `firebase_options.dart` with your configuration

### 4. Project Structure
- `lib/app/` - Main app configuration
- `lib/core/` - Core functionality (providers, services, theme, routing)
- `lib/features/` - Feature-based screens and widgets
- `lib/models/` - Data models
- `lib/shared/` - Shared widgets and utilities

### 5. Key Dependencies
- firebase_core, firebase_auth, cloud_firestore
- provider (state management)
- go_router (navigation)
- flutter_animate (animations)
- fl_chart, syncfusion_flutter_charts (data visualization)
- google_fonts (typography)

## Architecture
- **MVVM Pattern**: Clear separation of UI and business logic
- **Provider State Management**: Reactive state updates
- **Clean Architecture**: Layered approach with services and repositories
- **Feature-based Structure**: Organized by app features

## Screens Included
1. **Landing Screen** - Animated welcome screen
2. **Authentication** - Login/Signup with animations  
3. **Profile Setup** - Complete user profile after signup
4. **Dashboard** - Budget overview and quick actions
5. **Expense Management** - Add, edit, delete expenses
6. **Reports** - Data visualization and analytics
7. **Profile** - User settings and preferences

## Development Notes
- All screens use neumorphic design principles
- Smooth animations throughout the app
- Comprehensive error handling
- Form validation on all inputs
- Responsive design for different screen sizes
- Production-ready code with proper documentation

## License
This project is provided for educational and development purposes.

---
Built with ❤️ using Flutter and Firebase
