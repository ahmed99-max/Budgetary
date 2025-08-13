import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/expenses/screens/expense_list_screen.dart';
import '../../features/expenses/screens/add_expense_screen.dart';
import '../../features/budget/screens/budget_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/categories/screens/categories_screen.dart';
import '../../shared/layouts/main_layout.dart';

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/onboarding',
      debugLogDiagnostics: true,
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoading = authProvider.isLoading;

        if (isLoading) return null;

        final publicRoutes = ['/onboarding', '/login', '/signup', '/forgot-password'];
        final isPublicRoute = publicRoutes.contains(state.matchedLocation);

        if (!isAuthenticated && !isPublicRoute) {
          return '/onboarding';
        }

        if (isAuthenticated && isPublicRoute) {
          return '/dashboard';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/onboarding', name: 'onboarding', builder: (context, state) => const OnboardingScreen()),
        GoRoute(path: '/login', name: 'login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/signup', name: 'signup', builder: (context, state) => const SignupScreen()),
        GoRoute(path: '/forgot-password', name: 'forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
        ShellRoute(
          builder: (context, state, child) => MainLayout(child: child),
          routes: [
            GoRoute(path: '/dashboard', name: 'dashboard', builder: (context, state) => const DashboardScreen()),
            GoRoute(path: '/expenses', name: 'expenses', builder: (context, state) => const ExpenseListScreen()),
            GoRoute(path: '/add-expense', name: 'add-expense', builder: (context, state) => const AddExpenseScreen()),
            GoRoute(path: '/budget', name: 'budget', builder: (context, state) => const BudgetScreen()),
            GoRoute(path: '/reports', name: 'reports', builder: (context, state) => const ReportsScreen()),
            GoRoute(path: '/profile', name: 'profile', builder: (context, state) => const ProfileScreen()),
            GoRoute(path: '/settings', name: 'settings', builder: (context, state) => const SettingsScreen()),
            GoRoute(path: '/categories', name: 'categories', builder: (context, state) => const CategoriesScreen()),
          ],
        ),
      ],
    );
  }
}