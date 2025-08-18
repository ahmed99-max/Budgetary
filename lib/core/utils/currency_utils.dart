class CurrencyUtils {
  static const Map<String, String> _symbols = {
    'USD': '\$',
    'EUR': '€',
    'INR': '₹',
    'GBP': '£',
    'JPY': '¥',
    // add more as needed
  };
  static String symbol(String code) => _symbols[code] ?? code;
}
