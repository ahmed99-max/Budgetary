import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../shared/widgets/liquid_card.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../widgets/profile_info_widget.dart';
import '../widgets/settings_section_widget.dart';
import '../widgets/edit_profile_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserProvider, AuthProvider, ThemeProvider>(
      builder: (context, userProvider, authProvider, themeProvider, _) {
        if (!userProvider.hasUser) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = userProvider.user!;

        return LoadingOverlay(
          isLoading: userProvider.isLoading,
          message: 'Updating profile...',
          child: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.liquidBackground,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      // Header
                      Text(
                        'Profile & Settings ⚙️',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .slideY(begin: -0.3, end: 0),

                      SizedBox(height: 30.h),

                      // Profile Photo & Info
                      LiquidCard(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.25),
                            Colors.white.withOpacity(0.15),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Profile Image
                            Stack(
                              children: [
                                Container(
                                  width: 100.w,
                                  height: 100.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Colors.white.withOpacity(0.8),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: user.profileImageUrl != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50.r),
                                          child: Image.network(
                                            user.profileImageUrl!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(
                                          Icons.person,
                                          size: 50.sp,
                                          color: AppTheme.primaryPurple,
                                        ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _showImagePicker,
                                    child: Container(
                                      width: 32.w,
                                      height: 32.w,
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.liquidBackground,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.white,
                                        size: 16.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                                .animate()
                                .scale(begin: const Offset(0.8, 0.8))
                                .then()
                                .shimmer(
                                    duration: 2000.ms,
                                    color: Colors.white.withOpacity(0.3)),

                            SizedBox(height: 20.h),

                            // User Info
                            ProfileInfoWidget(user: user)
                                .animate()
                                .fadeIn(delay: 200.ms, duration: 800.ms)
                                .slideY(begin: 0.3, end: 0),

                            SizedBox(height: 20.h),

                            // Edit Profile Button
                            LiquidButton(
                              text: 'Edit Profile',
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.9),
                                  Colors.white.withOpacity(0.7),
                                ],
                              ),
                              onPressed: _showEditProfileDialog,
                              icon: Icons.edit_rounded,
                            )
                                .animate()
                                .fadeIn(delay: 400.ms, duration: 600.ms)
                                .slideY(begin: 0.3, end: 0),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0),

                      SizedBox(height: 24.h),

                      // Settings Sections
                      SettingsSectionWidget(
                        title: 'Preferences',
                        items: [
                          SettingItem(
                            icon: themeProvider.isDarkMode
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            title: 'Theme',
                            subtitle: themeProvider.isDarkMode
                                ? 'Dark Mode'
                                : 'Light Mode',
                            trailing: Switch(
                              value: themeProvider.isDarkMode,
                              onChanged: (value) => themeProvider.toggleTheme(),
                              activeColor: Colors.white,
                            ),
                          ),
                          SettingItem(
                            icon: Icons.notifications_rounded,
                            title: 'Notifications',
                            subtitle: 'Manage notification preferences',
                            onTap: () => _showNotificationSettings(),
                          ),
                          SettingItem(
                            icon: Icons.language_rounded,
                            title: 'Language',
                            subtitle: 'English (US)',
                            onTap: () => _showLanguageSettings(),
                          ),
                          SettingItem(
                            icon: Icons.security_rounded,
                            title: 'Security',
                            subtitle: 'Password and security settings',
                            onTap: () => _showSecuritySettings(),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(delay: 600.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0),

                      SizedBox(height: 24.h),

                      SettingsSectionWidget(
                        title: 'Support & Info',
                        items: [
                          SettingItem(
                            icon: Icons.help_rounded,
                            title: 'Help & Support',
                            subtitle: 'FAQs and contact support',
                            onTap: () => _showHelp(),
                          ),
                          SettingItem(
                            icon: Icons.info_rounded,
                            title: 'About',
                            subtitle: 'Version 1.0.0',
                            onTap: () => _showAbout(),
                          ),
                          SettingItem(
                            icon: Icons.privacy_tip_rounded,
                            title: 'Privacy Policy',
                            subtitle: 'Read our privacy policy',
                            onTap: () => _showPrivacyPolicy(),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0),

                      SizedBox(height: 24.h),

                      // Logout Button
                      LiquidButton(
                        text: 'Sign Out',
                        isOutlined: true,
                        color: Colors.transparent,
                        onPressed: _showLogoutConfirmation,
                        icon: Icons.logout_rounded,
                      )
                          .animate()
                          .fadeIn(delay: 1000.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),

                      SizedBox(height: 100.h), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppTheme.primaryPurple),
                title: Text('Take Photo'),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              ListTile(
                leading:
                    Icon(Icons.photo_library, color: AppTheme.primaryPurple),
                title: Text('Choose from Gallery'),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              ListTile(
                leading: Icon(Icons.cancel, color: Colors.red),
                title: Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.uploadProfileImage(pickedFile);
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(),
    );
  }

  void _showNotificationSettings() {
    // Implementation for notification settings
  }

  void _showLanguageSettings() {
    // Implementation for language settings
  }

  void _showSecuritySettings() {
    // Implementation for security settings
  }

  void _showHelp() {
    // Implementation for help & support
  }

  void _showAbout() {
    // Implementation for about dialog
  }

  void _showPrivacyPolicy() {
    // Implementation for privacy policy
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
