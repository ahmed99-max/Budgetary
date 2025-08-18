import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../../../shared/widgets/liquid_text_field.dart';
import '../../../shared/widgets/liquid_card.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;
  late TextEditingController _incomeController;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user!;

    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phoneNumber ?? '');
    _countryController = TextEditingController(text: user.country);
    _cityController = TextEditingController(text: user.city);
    _incomeController =
        TextEditingController(text: user.monthlyIncome.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final success = await userProvider.updateProfile(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        country: _countryController.text.trim(),
        city: _cityController.text.trim(),
        monthlyIncome: double.parse(_incomeController.text),
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppTheme.primaryPurple,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxHeight: 600.h),
        child: LiquidCard(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.3, end: 0),
                SizedBox(height: 20.h),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      LiquidTextField(
                        labelText: 'Full Name',
                        hintText: 'Enter your full name',
                        controller: _nameController,
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 600.ms)
                          .slideX(begin: -0.3, end: 0),

                      SizedBox(height: 16.h),

                      LiquidTextField(
                        labelText: 'Phone Number',
                        hintText: 'Enter your phone number',
                        controller: _phoneController,
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 600.ms)
                          .slideX(begin: -0.3, end: 0),

                      SizedBox(height: 16.h),

                      Row(
                        children: [
                          Expanded(
                            child: LiquidTextField(
                              labelText: 'Country',
                              hintText: 'Enter your country',
                              controller: _countryController,
                              prefixIcon: Icons.flag_outlined,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter your country';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: LiquidTextField(
                              labelText: 'City',
                              hintText: 'Enter your city',
                              controller: _cityController,
                              prefixIcon: Icons.location_city_outlined,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter your city';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 600.ms)
                          .slideX(begin: -0.3, end: 0),

                      SizedBox(height: 16.h),

                      LiquidTextField(
                        labelText: 'Monthly Income',
                        hintText: 'Enter your monthly income',
                        controller: _incomeController,
                        prefixIcon: Icons.attach_money_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your income';
                          }
                          final income = double.tryParse(value!);
                          if (income == null || income <= 0) {
                            return 'Please enter a valid income';
                          }
                          return null;
                        },
                      )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 600.ms)
                          .slideX(begin: -0.3, end: 0),

                      SizedBox(height: 30.h),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: LiquidButton(
                              text: 'Cancel',
                              isOutlined: true,
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: LiquidButton(
                              text: 'Save Changes',
                              gradient: AppTheme.liquidBackground,
                              onPressed: _saveProfile,
                              icon: Icons.save_rounded,
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.8, 0.8))
          .then()
          .shimmer(
              duration: 1500.ms,
              color: AppTheme.primaryPurple.withOpacity(0.1)),
    );
  }
}
