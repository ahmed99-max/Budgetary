import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/landing_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/profile_setup/screens/profile_setup_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/expenses/screen/expenses_screen.dart';
import '../../features/budget/screens/budget_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/providers/auth_provider.dart';
import '../services/firebase_service.dart';

/// ✅ Wrapper to make FirebaseAuth listenable
class FirebaseAuthNotifier extends ChangeNotifier {
  FirebaseAuthNotifier() {
    FirebaseService.auth.authStateChanges().listen((_) {
      notifyListeners(); // 🔥 notify GoRouter when auth state changes
    });
  }
}

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    refreshListenable: FirebaseAuthNotifier(), // ✅ FIXED
    redirect: _redirect,
    routes: [
      // Splash & Onboarding
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/landing',
        name: 'landing',
        builder: (context, state) => const LandingScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // Main App Routes with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/expenses',
            name: 'expenses',
            builder: (context, state) => const ExpensesScreen(),
          ),
          GoRoute(
            path: '/budget',
            name: 'budget',
            builder: (context, state) => const BudgetScreen(),
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );

  /// 🔥 Merged redirect logic from new + old
  static String? _redirect(BuildContext context, GoRouterState state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = FirebaseService.isLoggedIn; // ✅ Firebase check
    final needsProfile =
        (FirebaseService.currentUser?.displayName?.isEmpty ?? true);

    final location = state.uri.path;

    // Public routes that don't require auth
    final publicRoutes = ['/splash', '/landing', '/login', '/signup'];

    // If on splash, let it handle its own navigation
    if (location == '/splash') return null;

    // If not logged in → send to login (not landing)
    if (!isLoggedIn) {
      return location == '/login' ? null : '/login';
    }

    // Logged-in → check profile setup
    if (needsProfile && location != '/profile-setup') {
      return '/profile-setup';
    }

    // Once profile exists, force dashboard when trying to access login/signup/landing
    if (!needsProfile && publicRoutes.contains(location)) {
      return '/dashboard';
    }

    return null;
  }

  // Navigation Helper Methods
  static void goToLogin() => router.goNamed('login');
  static void goToSignup() => router.goNamed('signup');
  static void goToDashboard() => router.goNamed('dashboard');
  static void goToProfileSetup() => router.goNamed('profile-setup');
  static void goToLanding() => router.goNamed('landing');

  static void pop() {
    if (router.canPop()) {
      router.pop();
    }
  }

  static BuildContext get context => navigatorKey.currentContext!;
}
