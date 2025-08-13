import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import 'package:flutter/foundation.dart' show debugPrint; // For safe printing

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // Step 1: raw country data
  String? _selectedCountryName;
  String? _selectedCountryCode;
  String? _selectedPhoneCode;
  String? _selectedFlagEmoji;

  // Step 2: income & currency + firstName
  final _firstNameController = TextEditingController(); // Added for firstName
  final _monthlyIncomeController = TextEditingController();
  Currency? _selectedCurrency;
  Currency? _preferredCurrency;

  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _monthlyIncomeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _selectCountry() {
    debugPrint('DEBUG: Opening custom country selector'); // Replaced print
    final countries = [
      {'name': 'United States', 'code': 'US', 'phone': '1', 'flag': '🇺🇸'},
      {'name': 'India', 'code': 'IN', 'phone': '91', 'flag': '🇮🇳'},
      {'name': 'United Kingdom', 'code': 'GB', 'phone': '44', 'flag': '🇬🇧'},
      {'name': 'Canada', 'code': 'CA', 'phone': '1', 'flag': '🇨🇦'},
      {'name': 'Australia', 'code': 'AU', 'phone': '61', 'flag': '🇦🇺'},
      {'name': 'Germany', 'code': 'DE', 'phone': '49', 'flag': '🇩🇪'},
      {'name': 'France', 'code': 'FR', 'phone': '33', 'flag': '🇫🇷'},
      {'name': 'Japan', 'code': 'JP', 'phone': '81', 'flag': '🇯🇵'},
      {'name': 'Brazil', 'code': 'BR', 'phone': '55', 'flag': '🇧🇷'},
      {'name': 'Mexico', 'code': 'MX', 'phone': '52', 'flag': '🇲🇽'},
      {'name': 'Singapore', 'code': 'SG', 'phone': '65', 'flag': '🇸🇬'},
      {'name': 'South Korea', 'code': 'KR', 'phone': '82', 'flag': '🇰🇷'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        height: 500,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Country',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: countries.length,
                itemBuilder: (_, idx) {
                  final c = countries[idx];
                  return ListTile(
                    leading:
                        Text(c['flag']!, style: const TextStyle(fontSize: 28)),
                    title: Text(c['name']!,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text('+${c['phone']!}',
                        style: TextStyle(color: Colors.grey[600])),
                    onTap: () {
                      debugPrint(
                          'DEBUG: Selected ${c['name']}'); // Replaced print
                      setState(() {
                        _selectedCountryName = c['name']!;
                        _selectedCountryCode = c['code']!;
                        _selectedPhoneCode = c['phone']!;
                        _selectedFlagEmoji = c['flag']!;
                        _selectedCurrency = _getCurrencyForCountry(c['code']!);
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Currency _getCurrencyForCountry(String countryCode) {
    debugPrint('DEBUG: Finding currency for $countryCode'); // Replaced print
    const map = {
      'US': 'USD',
      'IN': 'INR',
      'GB': 'GBP',
      'CA': 'CAD',
      'AU': 'AUD',
      'DE': 'EUR',
      'FR': 'EUR',
      'IT': 'EUR',
      'ES': 'EUR',
      'JP': 'JPY',
      'CN': 'CNY',
      'BR': 'BRL',
      'MX': 'MXN',
      'RU': 'RUB',
      'KR': 'KRW',
      'SG': 'SGD',
      'MY': 'MYR',
      'TH': 'THB',
      'ID': 'IDR',
      'PH': 'PHP',
      'VN': 'VND',
    };
    final code = map[countryCode] ?? 'USD';
    debugPrint('DEBUG: Mapped to $code'); // Replaced print
    return CurrencyService.currencyList.firstWhere(
      (x) => x.code == code,
      orElse: () => CurrencyService.currencyList.first,
    );
  }

  void _selectCurrency() {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showSearchField: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      favorite: ['USD', 'EUR', 'GBP', 'INR', 'JPY', 'CAD', 'AUD'],
      onSelect: (c) => setState(() => _selectedCurrency = c),
    );
  }

  void _selectPreferredCurrency() {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showSearchField: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      favorite: ['USD', 'EUR', 'GBP', 'INR', 'JPY', 'CAD', 'AUD'],
      onSelect: (c) => setState(() => _preferredCurrency = c),
    );
  }

  Future<void> _completeSetup() async {
    if (_selectedCountryCode == null || _selectedCurrency == null) {
      _showErrorSnackBar('Please complete all required fields');
      return;
    }

    final monthlyIncome = double.tryParse(_monthlyIncomeController.text);
    if (monthlyIncome == null || monthlyIncome <= 0) {
      _showErrorSnackBar('Please enter a valid monthly income');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Extra safety - ensure all values are strings and not null
      final countryName = _selectedCountryName ?? 'Unknown';
      final countryCode = _selectedCountryCode ?? 'US';
      final phoneCode = _selectedPhoneCode ?? '1';
      final currencyCode = _selectedCurrency?.code ?? 'USD';
      final preferredCurrencyCode = _preferredCurrency?.code ?? currencyCode;

      debugPrint('DEBUG: Updating user profile with:'); // Replaced print
      debugPrint('  Country: $countryName');
      debugPrint('  Country Code: $countryCode');
      debugPrint('  Phone Code: $phoneCode');
      debugPrint('  Monthly Income: $monthlyIncome');
      debugPrint('  Currency: $currencyCode');
      debugPrint('  Preferred Currency: $preferredCurrencyCode');

      final success = await userProvider.updateUserProfile(
        country: countryName,
        countryCode: countryCode,
        phoneCode: phoneCode,
        totalIncome: monthlyIncome, // Changed to totalIncome
        currency: currencyCode,
        preferredCurrency: preferredCurrencyCode,
      );

      if (success && mounted) {
        context.go('/dashboard');
      } else if (mounted) {
        _showErrorSnackBar('Failed to update profile');
      }
    } catch (e) {
      debugPrint('DEBUG: Error in _completeSetup: $e'); // Replaced print
      if (mounted)
        _showErrorSnackBar('Failed to update profile: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back), onPressed: _previousStep)
            : null,
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCountryStep(),
                _buildPersonalDetailsStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largeSpacing),
      child: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / 2,
              backgroundColor: AppColors.outline,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: AppConstants.mediumSpacing),
          Text(
            '${_currentStep + 1} of 2',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryStep() {
    final hasSelected = _selectedCountryName != null;
    return Padding(
      padding: const EdgeInsets.all(AppConstants.largeSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select Your Country',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(
              height: AppConstants.smallSpacing), // Fixed whitespace lint
          Text(
            'This helps us determine your currency and phone number format',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppConstants.extraLargeSpacing),
          GestureDetector(
            onTap: _selectCountry,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.largeSpacing),
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasSelected ? AppColors.primary : AppColors.outline,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(AppConstants.largeRadius),
              ),
              child: Row(
                children: [
                  if (hasSelected) ...[
                    Text(_selectedFlagEmoji!,
                        style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: AppConstants.mediumSpacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedCountryName!,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '+$_selectedPhoneCode', // Fixed string interpolation
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const Icon(Icons.public,
                        size: 32, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: AppConstants.mediumSpacing),
                    Expanded(
                      child: Text(
                        'Tap to select your country',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                  const Icon(Icons.arrow_forward_ios,
                      color: AppColors.onSurfaceVariant),
                ],
              ),
            ),
          ),
          if (hasSelected && _selectedCurrency != null) ...[
            const SizedBox(height: AppConstants.largeSpacing),
            Container(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: AppConstants.smallSpacing),
                  Expanded(
                    child: Text(
                      'Currency auto-selected: ${_selectedCurrency!.name} (${_selectedCurrency!.code})',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          CustomButton(
            text: 'Continue',
            onPressed: hasSelected ? _nextStep : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsStep() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.largeSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Financial Details',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: AppConstants.smallSpacing),
          Text(
            'Help us personalize your budgeting experience',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppConstants.extraLargeSpacing),
          CustomTextField(
            controller: _monthlyIncomeController,
            label: 'Monthly Income',
            hint: 'Enter your monthly income',
            prefixIcon: Icons.attach_money,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: AppUtils.validateAmount,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppConstants.mediumSpacing),
          GestureDetector(
            onTap: _selectCurrency,
            child: _buildCurrencySelector(
              icon: Icons.currency_exchange,
              label: 'Currency',
              value: _selectedCurrency != null
                  ? '${_selectedCurrency!.name} (${_selectedCurrency!.code})'
                  : 'Select currency',
            ),
          ),
          const SizedBox(height: AppConstants.mediumSpacing),
          GestureDetector(
            onTap: _selectPreferredCurrency,
            child: _buildCurrencySelector(
              icon: Icons.favorite_border,
              label: 'Preferred Currency',
              value: _preferredCurrency != null
                  ? '${_preferredCurrency!.name} (${_preferredCurrency!.code})'
                  : _selectedCurrency != null
                      ? '${_selectedCurrency!.name} (${_selectedCurrency!.code}) - Same as currency'
                      : 'Select preferred currency',
            ),
          ),
          const Spacer(),
          CustomButton(
            text: 'Complete Setup',
            onPressed: _isLoading ? null : _completeSetup,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.onSurfaceVariant),
          const SizedBox(width: AppConstants.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                ),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }
}

class CurrencyService {
  static List<Currency> get currencyList => [
        Currency.from(json: {
          'code': 'USD',
          'name': 'US Dollar',
          'symbol': '\$',
          'flag': 'US',
          'decimal_digits': 2,
          'number': 840,
          'name_plural': 'US dollars',
          'thousands_separator': ',',
          'decimal_separator': '.',
          'space_between_amount_and_symbol': false,
          'symbol_on_left': true
        }),
        Currency.from(json: {
          'code': 'EUR',
          'name': 'Euro',
          'symbol': '€',
          'flag': 'EU',
          'decimal_digits': 2,
          'number': 978,
          'name_plural': 'euros',
          'thousands_separator': '.',
          'decimal_separator': ',',
          'space_between_amount_and_symbol': true,
          'symbol_on_left': true
        }),
        Currency.from(json: {
          'code': 'GBP',
          'name': 'British Pound',
          'symbol': '£',
          'flag': 'GB',
          'decimal_digits': 2,
          'number': 826,
          'name_plural': 'British pounds sterling',
          'thousands_separator': ',',
          'decimal_separator': '.',
          'space_between_amount_and_symbol': false,
          'symbol_on_left': true
        }),
        Currency.from(json: {
          'code': 'INR',
          'name': 'Indian Rupee',
          'symbol': '₹',
          'flag': 'IN',
          'decimal_digits': 2,
          'number': 356,
          'name_plural': 'Indian rupees',
          'thousands_separator': ',',
          'decimal_separator': '.',
          'space_between_amount_and_symbol': false,
          'symbol_on_left': true
        }),
        Currency.from(json: {
          'code': 'JPY',
          'name': 'Japanese Yen',
          'symbol': '¥',
          'flag': 'JP',
          'decimal_digits': 0,
          'number': 392,
          'name_plural': 'Japanese yen',
          'thousands_separator': ',',
          'decimal_separator': '.',
          'space_between_amount_and_symbol': false,
          'symbol_on_left': true
        }),
        Currency.from(json: {
          'code': 'CAD',
          'name': 'Canadian Dollar',
          'symbol': 'C\$',
          'flag': 'CA',
          'decimal_digits': 2,
          'number': 124,
          'name_plural': 'Canadian dollars',
          'thousands_separator': ',',
          'decimal_separator': '.',
          'space_between_amount_and_symbol': true,
          'symbol_on_left': true
        }),
        Currency.from(json: {
          'code': 'AUD',
          'name': 'Australian Dollar',
          'symbol': 'A\$',
          'flag': 'AU',
          'decimal_digits': 2,
          'number': 36,
          'name_plural': 'Australian dollars',
          'thousands_separator': ',',
          'decimal_separator': '.',
          'space_between_amount_and_symbol': true,
          'symbol_on_left': true
        }),
      ];
}
