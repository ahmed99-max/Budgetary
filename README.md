# Budgetary - Complete Finance Tracking App

A comprehensive personal finance tracking application built with Flutter, featuring beautiful neumorphic design, real-time analytics, and intelligent budgeting.

## 🚀 Features

### ✨ Beautiful UI & UX
- **Neumorphic Design**: Soft, modern design language throughout the app
- **Material 3**: Latest Material Design with custom neumorphic styling
- **Responsive**: Adapts perfectly to all screen sizes and orientations
- **Smooth Animations**: Micro-interactions and delightful transitions
- **Dark/Light Mode**: Complete theme switching support

### 💰 Core Functionality
- **Expense Tracking**: Add, edit, delete, and categorize expenses with ease
- **Budget Management**: Set monthly budgets with visual progress tracking
- **Category Management**: Customize expense categories with icons and colors
- **Analytics & Reports**: Interactive charts and detailed spending insights
- **Search & Filter**: Advanced expense filtering and search capabilities

### 🔐 Authentication & Security
- **Firebase Auth**: Email/password and Google Sign-in
- **Secure Storage**: Local data encryption with Hive
- **Biometric Auth**: Fingerprint and Face ID support
- **Data Backup**: Cloud synchronization with Firebase

### 📊 Advanced Features
- **Smart Insights**: AI-powered spending pattern analysis
- **Goal Tracking**: Set and monitor financial goals
- **Export Data**: PDF reports and CSV exports
- **Notifications**: Smart budget alerts and spending reminders
- **Multi-Currency**: Support for international currencies

## 🛠 Technical Stack

### Core Framework
- **Flutter**: 3.19+ with Dart 3.0+
- **Architecture**: Provider pattern with clean architecture
- **Navigation**: go_router 16.0+ with nested routing
- **Responsive**: flutter_screenutil for adaptive layouts

### UI & Animations
- **flutter_neumorphic**: 3.2.0+ for neumorphic design
- **flutter_animate**: 4.5.0+ for smooth animations
- **google_fonts**: 6.1.0+ for Inter typography
- **shimmer**: 3.0.0+ for loading states

### Backend & Storage
- **Firebase**: Complete suite (Auth, Firestore, Storage, Analytics)
- **Hive**: Local storage with encryption
- **SharedPreferences**: App settings persistence

### Charts & Visualization
- **fl_chart**: 1.0.0+ for interactive charts
- **syncfusion_flutter_charts**: 30.2.4+ for advanced analytics
- **pie_chart**: 5.4.0+ for category breakdowns

### Additional Features
- **image_picker**: Receipt photo capture
- **local_auth**: Biometric authentication
- **awesome_notifications**: Smart notification system
- **permission_handler**: Runtime permissions
- **connectivity_plus**: Network status monitoring

## 📁 Project Structure

```
lib/
├── app/                          # App configuration
├── core/                         # Core business logic
│   ├── constants/               # App constants
│   ├── providers/               # State management
│   ├── routing/                 # Navigation setup
│   ├── services/                # External services
│   ├── theme/                   # Theme configuration
│   └── utils/                   # Helper utilities
├── features/                    # Feature modules
│   ├── auth/                    # Authentication
│   ├── dashboard/               # Main dashboard
│   ├── expenses/                # Expense management
│   ├── budget/                  # Budget tracking
│   ├── reports/                 # Analytics & reports
│   ├── profile/                 # User profile
│   ├── settings/                # App settings
│   └── categories/              # Category management
├── models/                      # Data models
├── shared/                      # Reusable components
│   ├── widgets/                 # Custom widgets
│   ├── layouts/                 # Layout templates
│   └── animations/              # Animation components
└── main.dart                    # App entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter 3.19+
- Dart 3.0+
- Android Studio / VS Code
- Firebase project (optional)

### Installation

1. **Clone & Setup**
   ```bash
   # Extract the project
   cd budgetary_complete_latest

   # Get dependencies
   flutter pub get

   # Generate code (if needed)
   flutter packages pub run build_runner build
   ```

2. **Firebase Setup** (Optional)
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools

   # Login to Firebase
   firebase login

   # Initialize project
   flutterfire configure
   ```

3. **Run the App**
   ```bash
   # Run on connected device
   flutter run

   # Run with hot reload
   flutter run --hot
   ```

## 📱 Screenshots & Demo

The app includes:
- **Onboarding Flow**: Beautiful introduction screens
- **Authentication**: Login, signup, forgot password
- **Dashboard**: Overview of finances with interactive charts
- **Expense Management**: Full CRUD operations with categories
- **Budget Tracking**: Visual progress bars and alerts
- **Reports**: Detailed analytics and export functionality
- **Profile & Settings**: User management and preferences

## 🎨 Design System

### Color Palette
- **Primary**: #6C7CE7 (Indigo)
- **Background Light**: #E0E5EC (Neumorphic gray)
- **Background Dark**: #2C3E50 (Dark blue-gray)
- **Success**: #27AE60 (Green)
- **Warning**: #F39C12 (Orange)
- **Error**: #E74C3C (Red)

### Typography
- **Primary Font**: Inter (Google Fonts)
- **Weights**: 300, 400, 500, 600, 700
- **Responsive**: Scales with screen size

### Neumorphic Effects
- **Elevation**: Soft shadows for depth
- **Inset/Outset**: Toggle states for buttons
- **Subtle Gradients**: Enhanced visual hierarchy

## 🔧 Development Notes

### Code Quality
- **Linting**: flutter_lints with strict rules
- **Testing**: Comprehensive unit and widget tests
- **Documentation**: Inline documentation for all public APIs
- **Architecture**: Clean, scalable, and maintainable

### Performance
- **Optimized Rendering**: Efficient widget rebuilds
- **Image Caching**: Smart image loading and caching
- **Data Persistence**: Local-first with cloud sync
- **Animations**: Hardware-accelerated smooth transitions

### Accessibility
- **Screen Readers**: Full VoiceOver/TalkBack support
- **High Contrast**: Accessible color combinations
- **Font Scaling**: Respects system font preferences
- **Navigation**: Keyboard and gesture navigation

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please read the contributing guidelines and code of conduct before submitting PRs.

## 📞 Support

For support, email support@budgetary.com or create an issue on GitHub.
