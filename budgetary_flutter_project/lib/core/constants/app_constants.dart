class AppConstants {
  static const String appName = 'Budgetary';
  static const String appTagline = 'Smart Money Management Made Simple';

  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  // Radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  static const List<Map<String, String>> categories = [
    {'id': 'food', 'name': 'Food', 'icon': 'restaurant', 'color': '#F87171'},
    {
      'id': 'transport',
      'name': 'Transport',
      'icon': 'directions_car',
      'color': '#34D399'
    },
    {
      'id': 'shopping',
      'name': 'Shopping',
      'icon': 'shopping_bag',
      'color': '#60A5FA'
    },
    {
      'id': 'entertainment',
      'name': 'Entertainment',
      'icon': 'movie',
      'color': '#FBBF24'
    },
    {'id': 'bills', 'name': 'Bills', 'icon': 'receipt', 'color': '#A78BFA'},
    {
      'id': 'health',
      'name': 'Health',
      'icon': 'local_hospital',
      'color': '#F472B6'
    },
    {
      'id': 'education',
      'name': 'Education',
      'icon': 'school',
      'color': '#F59E0B'
    },
  ];

  static const List<Map<String, String>> paymentMethods = [
    {
      'id': 'cash',
      'name': 'Cash',
      'icon': 'money',
    },
    {
      'id': 'credit_card',
      'name': 'Credit Card',
      'icon': 'credit_card',
    },
    {
      'id': 'debit_card',
      'name': 'Debit Card',
      'icon': 'credit_card',
    },
    {
      'id': 'upi',
      'name': 'UPI',
      'icon': 'qr_code',
    },
    {
      'id': 'net_banking',
      'name': 'Net Banking',
      'icon': 'account_balance',
    },
    {
      'id': 'wallet',
      'name': 'Wallet',
      'icon': 'account_wallet',
    },
    // Add additional payment methods as needed...
  ];
}
