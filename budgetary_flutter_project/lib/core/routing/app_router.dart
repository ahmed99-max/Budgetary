import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// Auth Screens
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/profile_setup_screen.dart';

// Dashboard
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/dashboard/profile_tab.dart';

// Landing screen — create your own widget in features/landing/screens/landing_screen.dart
import '../../features/auth/screens/landing_screen.dart';

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isLoggedIn = authProvider.isAuthenticated;

        // Routes where authentication is NOT required
        final publicRoutes = ['/', '/login', '/signup', '/forgot-password'];
        final isPublicRoute = publicRoutes.contains(state.matchedLocation);

        // If NOT logged in and trying to access a protected page → go to landing
        if (!isLoggedIn && !isPublicRoute) {
          return '/';
        }

        // If logged in and user is on a public route → send to dashboard
        if (isLoggedIn && isPublicRoute) {
          return '/dashboard';
        }

        // Otherwise, allow navigation
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LandingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/profile-setup',
          builder: (context, state) => const ProfileSetupScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) =>
              const ProfileScreen(), // Optional standalone route
        ),
      ],
    );
  }
}
