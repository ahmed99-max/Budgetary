import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// Import all screens
import '../../features/auth/screens/landing_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/profile_setup_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/expenses/screens/expense_list_screen.dart';
import '../../features/expenses/screens/add_expense_screen.dart';
import '../../features/expenses/screens/expense_details_screen.dart';
import '../../features/budget/screens/budget_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../shared/widgets/error_screen.dart';

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      errorBuilder: (context, state) => ErrorScreen(
        error: state.error.toString(),
        onRetry: () => context.go('/'),
      ),
      redirect: (context, state) {
        try {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final isLoggedIn = authProvider.isAuthenticated;
          final isLoading = authProvider.isLoading;

          if (isLoading) return null;

          final publicRoutes = ['/', '/login', '/signup', '/forgot-password'];
          final isPublicRoute = publicRoutes.contains(state.matchedLocation);

          if (!isLoggedIn && !isPublicRoute) {
            return '/';
          }

          if (isLoggedIn && isPublicRoute && state.matchedLocation != '/') {
            return '/dashboard';
          }

          return null;
        } catch (e) {
          debugPrint('Router redirect error: $e');
          return '/';
        }
      },
      routes: [
        GoRoute(
          path: '/',
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
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/profile-setup',
          name: 'profile-setup',
          builder: (context, state) => const ProfileSetupScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/expenses',
          name: 'expenses',
          builder: (context, state) => const ExpenseListScreen(),
          routes: [
            GoRoute(
              path: '/add',
              name: 'add-expense',
              builder: (context, state) => const AddExpenseScreen(),
            ),
            GoRoute(
              path: '/:id',
              name: 'expense-details',
              builder: (context, state) {
                final expenseId = state.pathParameters['id']!;
                return ExpenseDetailsScreen(expenseId: expenseId);
              },
            ),
          ],
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
      ],
    );
  }
}
