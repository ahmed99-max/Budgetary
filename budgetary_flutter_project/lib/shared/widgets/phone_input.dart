import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/neumorphic_container.dart';

class PhoneInput extends StatefulWidget {
  final TextEditingController controller;
  final String selectedCountryCode;
  final String selectedCountry;
  final Function(String country, String code) onCountryChanged;

  const PhoneInput({
    super.key,
    required this.controller,
    required this.selectedCountryCode,
    required this.selectedCountry,
    required this.onCountryChanged,
  });

  @override
  State<PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends State<PhoneInput> {
  final List<Map<String, dynamic>> countries = [
    {'name': 'India', 'code': '+91', 'flag': '🇮🇳', 'maxLength': 10},
    {'name': 'United States', 'code': '+1', 'flag': '🇺🇸', 'maxLength': 10},
    {'name': 'United Kingdom', 'code': '+44', 'flag': '🇬🇧', 'maxLength': 11},
    {'name': 'Canada', 'code': '+1', 'flag': '🇨🇦', 'maxLength': 10},
    {'name': 'Australia', 'code': '+61', 'flag': '🇦🇺', 'maxLength': 9},
    {'name': 'Germany', 'code': '+49', 'flag': '🇩🇪', 'maxLength': 12},
    {'name': 'France', 'code': '+33', 'flag': '🇫🇷', 'maxLength': 10},
    {'name': 'Japan', 'code': '+81', 'flag': '🇯🇵', 'maxLength': 11},
    {'name': 'Singapore', 'code': '+65', 'flag': '🇸🇬', 'maxLength': 8},
    {'name': 'UAE', 'code': '+971', 'flag': '🇦🇪', 'maxLength': 9},
  ];

  int get maxLength {
    final country = countries.firstWhere((c) => c['name'] == widget.selectedCountry, orElse: () => countries[0]);
    return country['maxLength'];
  }

  String get flag {
    final country = countries.firstWhere((c) => c['name'] == widget.selectedCountry, orElse: () => countries[0]);
    return country['flag'];
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phone Number', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: _showCountryPicker,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(flag, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(widget.selectedCountryCode, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, color: AppColors.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(maxLength),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    prefixIcon: Icon(Icons.phone, color: AppColors.onSurfaceVariant),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Phone required';
                    if (value.length != maxLength) return 'Invalid phone number';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Phone should be $maxLength digits for ${widget.selectedCountry}', 
               style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: AppColors.onSurfaceVariant.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            Text('Select Country', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: countries.length,
                itemBuilder: (context, index) {
                  final country = countries[index];
                  return ListTile(
                    leading: Text(country['flag'], style: const TextStyle(fontSize: 24)),
                    title: Text(country['name']),
                    subtitle: Text('${country['code']} • Max ${country['maxLength']} digits'),
                    trailing: widget.selectedCountry == country['name'] ? Icon(Icons.check, color: AppColors.primary) : null,
                    onTap: () {
                      widget.onCountryChanged(country['name'], country['code']);
                      widget.controller.clear();
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
}
