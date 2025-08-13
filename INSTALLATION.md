# Installation & Setup Guide

## Quick Start (Recommended)

1. **Extract the project**
   ```bash
   cd budgetary_complete_latest
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

That's it! The app will run with demo data and all features working.

## Complete Setup with Firebase (Optional)

If you want to enable cloud sync and authentication:

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create new project
   - Enable Authentication, Firestore, Storage

2. **Configure Firebase**
   ```bash
   npm install -g firebase-tools
   firebase login
   flutterfire configure
   ```

3. **Update firebase_options.dart**
   - Replace the demo configuration with your project's config

## Troubleshooting

### Common Issues

**Problem**: "Target of URI doesn't exist" errors
**Solution**: Run `flutter pub get` and restart your IDE

**Problem**: "No Firebase App" error
**Solution**: The app works without Firebase. The error is harmless.

**Problem**: Charts not displaying
**Solution**: Ensure you're testing on a device, not just the IDE preview

**Problem**: Animations choppy
**Solution**: Test on physical device for best performance

### Development Tips

1. **Hot Reload**: Use `r` in terminal or IDE hot reload
2. **Debug Mode**: Run with `flutter run --debug`
3. **Performance**: Use `flutter run --profile` for performance testing
4. **Build**: Use `flutter build apk` or `flutter build ios`

### IDE Setup

**VS Code Extensions:**
- Flutter
- Dart
- Flutter Widget Snippets
- Awesome Flutter Snippets

**Android Studio Plugins:**
- Flutter
- Dart
- Flutter Enhancement Suite

## Project Structure Explained

```
budgetary_complete_latest/
├── android/                     # Android platform files
├── ios/                         # iOS platform files  
├── lib/                         # Dart source code
│   ├── app/                     # App configuration & initialization
│   ├── core/                    # Core business logic
│   │   ├── constants/          # App constants (colors, strings, etc.)
│   │   ├── providers/          # State management (Provider pattern)
│   │   ├── routing/            # Navigation setup (go_router)
│   │   ├── services/           # External services (Firebase, APIs)
│   │   ├── theme/              # App theming (neumorphic, Material 3)
│   │   └── utils/              # Helper utilities & extensions
│   ├── features/               # Feature-based modules
│   │   ├── auth/               # Authentication screens & logic
│   │   ├── dashboard/          # Main dashboard with overview
│   │   ├── expenses/           # Expense CRUD operations
│   │   ├── budget/             # Budget management
│   │   ├── reports/            # Analytics & reporting
│   │   ├── profile/            # User profile management
│   │   ├── settings/           # App settings & preferences
│   │   └── categories/         # Expense category management
│   ├── models/                 # Data models & entities
│   ├── shared/                 # Reusable UI components
│   │   ├── widgets/            # Custom reusable widgets
│   │   ├── layouts/            # Layout templates
│   │   └── animations/         # Animation components
│   └── main.dart               # App entry point
├── assets/                     # Static assets
│   ├── images/                 # App images & illustrations
│   ├── icons/                  # Custom icons
│   ├── animations/             # Lottie animations
│   └── fonts/                  # Custom fonts (Inter)
├── test/                       # Test files
├── pubspec.yaml               # Dependencies & configuration
└── README.md                  # Project documentation
```

## Key Files Explained

### Core Files
- `main.dart` - App initialization with providers
- `app/app.dart` - MaterialApp configuration with themes
- `core/routing/app_router.dart` - Navigation setup with go_router
- `firebase_options.dart` - Firebase configuration

### Providers (State Management)
- `auth_provider.dart` - Authentication state
- `theme_provider.dart` - Theme switching
- `expense_provider.dart` - Expense management
- `budget_provider.dart` - Budget tracking
- `category_provider.dart` - Category management

### Key Screens
- `onboarding_screen.dart` - App introduction
- `dashboard_screen.dart` - Main overview screen
- `expense_list_screen.dart` - Expense management
- `budget_screen.dart` - Budget tracking
- `reports_screen.dart` - Analytics dashboard

## Features Documentation

### 1. Expense Management
- **Add Expenses**: Form with categories, amounts, descriptions
- **Edit Expenses**: Tap any expense to modify
- **Delete Expenses**: Swipe to delete with confirmation
- **Categories**: Color-coded organization
- **Search**: Find expenses by title, amount, or category
- **Filters**: Date range, category, amount filters

### 2. Budget Tracking
- **Set Budgets**: Monthly limits per category
- **Progress Tracking**: Visual progress bars
- **Alerts**: Notifications when approaching limits
- **History**: Track budget performance over time

### 3. Analytics & Reports
- **Spending Charts**: Interactive pie and bar charts
- **Trends**: Monthly and yearly spending trends
- **Category Breakdown**: Detailed category analysis
- **Export**: PDF reports and CSV data export

### 4. Customization
- **Themes**: Light and dark mode
- **Categories**: Add custom categories with icons
- **Currency**: Support for multiple currencies
- **Notifications**: Customizable alert preferences

## Performance Optimization

The app is optimized for:
- **Smooth 60fps animations**
- **Minimal memory usage**
- **Fast startup time**
- **Efficient data loading**
- **Battery optimization**

## Security Features

- **Local encryption** for sensitive data
- **Secure storage** for credentials
- **Biometric authentication** support
- **Firebase security rules** for cloud data
- **Input validation** and sanitization

This app is production-ready and includes industry best practices for Flutter development.
