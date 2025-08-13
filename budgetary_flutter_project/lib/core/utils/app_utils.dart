import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class AppUtils {
  // Validation methods
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount <= 0) {
      return 'Amount must be greater than zero';
    }

    return null;
  }

  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  // Formatting methods
  static String formatCurrency(double amount, {String? currencySymbol}) {
    final formatter = NumberFormat.currency(
      symbol: currencySymbol ?? '\$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatNumber(double number) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(number);
  }

  static String formatCompactNumber(double number) {
    final formatter = NumberFormat.compact();
    return formatter.format(number);
  }

  static String formatDate(DateTime date, [String? pattern]) {
    final formatter = DateFormat(pattern ?? 'MMM d, yyyy');
    return formatter.format(date);
  }

  static String formatDateTime(DateTime dateTime, [String? pattern]) {
    final formatter = DateFormat(pattern ?? 'MMM d, yyyy h:mm a');
    return formatter.format(dateTime);
  }

  static String formatTime(DateTime time, [String? pattern]) {
    final formatter = DateFormat(pattern ?? 'h:mm a');
    return formatter.format(time);
  }

  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }

  // Category utilities
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'dining':
      case 'restaurant':
        return Icons.restaurant;
      case 'transportation':
      case 'transport':
      case 'gas':
      case 'fuel':
        return Icons.directions_car;
      case 'shopping':
      case 'retail':
        return Icons.shopping_bag;
      case 'entertainment':
      case 'movies':
      case 'games':
        return Icons.movie;
      case 'health':
      case 'healthcare':
      case 'medical':
        return Icons.local_hospital;
      case 'education':
      case 'learning':
        return Icons.school;
      case 'utilities':
      case 'bills':
        return Icons.receipt;
      case 'travel':
      case 'vacation':
        return Icons.flight;
      case 'groceries':
      case 'grocery':
        return Icons.local_grocery_store;
      case 'fitness':
      case 'gym':
      case 'sports':
        return Icons.fitness_center;
      case 'beauty':
      case 'personal care':
        return Icons.face;
      case 'home':
      case 'house':
      case 'rent':
        return Icons.home;
      case 'insurance':
        return Icons.security;
      case 'gifts':
      case 'donations':
        return Icons.card_giftcard;
      case 'other':
      default:
        return Icons.category;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'dining':
      case 'restaurant':
        return Colors.orange;
      case 'transportation':
      case 'transport':
      case 'gas':
      case 'fuel':
        return Colors.blue;
      case 'shopping':
      case 'retail':
        return Colors.purple;
      case 'entertainment':
      case 'movies':
      case 'games':
        return Colors.pink;
      case 'health':
      case 'healthcare':
      case 'medical':
        return Colors.red;
      case 'education':
      case 'learning':
        return Colors.indigo;
      case 'utilities':
      case 'bills':
        return Colors.brown;
      case 'travel':
      case 'vacation':
        return Colors.teal;
      case 'groceries':
      case 'grocery':
        return Colors.green;
      case 'fitness':
      case 'gym':
      case 'sports':
        return Colors.deepOrange;
      case 'beauty':
      case 'personal care':
        return Colors.pinkAccent;
      case 'home':
      case 'house':
      case 'rent':
        return Colors.blueGrey;
      case 'insurance':
        return Colors.cyan;
      case 'gifts':
      case 'donations':
        return Colors.amber;
      case 'other':
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  static List<String> getExpenseCategories() {
    return [
      'Food & Dining',
      'Transportation',
      'Shopping',
      'Entertainment',
      'Health & Medical',
      'Education',
      'Utilities & Bills',
      'Travel',
      'Groceries',
      'Fitness & Sports',
      'Beauty & Personal Care',
      'Home & Garden',
      'Insurance',
      'Gifts & Donations',
      'Other',
    ];
  }

  static List<String> getIncomeCategories() {
    return [
      'Salary',
      'Freelance',
      'Business',
      'Investment',
      'Rental',
      'Interest',
      'Dividend',
      'Gift',
      'Bonus',
      'Other',
    ];
  }

  // String utilities
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map(capitalizeFirst).join(' ');
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Color utilities
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  // Device utilities
  static bool isTablet(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.shortestSide >= 600;
  }

  static bool isDesktop(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.width >= 1200;
  }

  // Navigation utilities
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration? duration,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: action,
      ),
    );
  }

  static Future<bool> showConfirmDialog(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Math utilities
  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  static double calculatePercentageChange(double oldValue, double newValue) {
    if (oldValue == 0) return 0;
    return ((newValue - oldValue) / oldValue) * 100;
  }

  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Formats a DateTime to a short date format like "MMM dd, yyyy"
  static String formatDateShort(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Formats a numeric amount to a compact currency string with currency symbol.
  /// Example: 1500 -> $1.5K
  static String formatCurrencyCompact(double amount, {String symbol = '\$'}) {
    // Use intl package's compact format
    final format =
        NumberFormat.compactCurrency(symbol: symbol, decimalDigits: 1);
    return format.format(amount);
  }
}
