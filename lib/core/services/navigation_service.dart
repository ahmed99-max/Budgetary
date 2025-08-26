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
import 'auth_state_notifier.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    refreshListenable: AuthRouteNotifier.instance,
    redirect: _redirect,
    routes: [
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

  static String? _redirect(BuildContext context, GoRouterState state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isAuthenticated;
    final location = state.uri.path;

    // Public routes
    const publicRoutes = {
      '/splash',
      '/landing',
      '/login',
      '/signup',
      '/forgot-password'
    };

    if (location == '/splash') return null;

    if (!isLoggedIn && !publicRoutes.contains(location)) {
      return '/landing';
    }

    if (isLoggedIn && publicRoutes.contains(location)) {
      return authProvider.hasCompletedProfileSetup
          ? '/dashboard'
          : '/profile-setup';
    }

    // Force profile setup if flag is false after signup/login
    if (isLoggedIn &&
        !authProvider.hasCompletedProfileSetup &&
        location != '/profile-setup') {
      return '/profile-setup';
    }

    return null;
  }

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
