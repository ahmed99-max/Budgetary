import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/animated_button.dart';
import '../../../shared/widgets/wallet_savings_animation.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _walletController;

  @override
  void initState() {
    super.initState();
    debugPrint('[LandingScreen] initState started');

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    debugPrint('[LandingScreen] Main AnimationController created');

    _walletController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    debugPrint('[LandingScreen] Wallet AnimationController created');

    _mainController.forward();
    debugPrint('[LandingScreen] Main animation started');

    _walletController.repeat();
    debugPrint('[LandingScreen] Wallet animation started');

    debugPrint('[LandingScreen] initState complete');
  }

  @override
  void dispose() {
    debugPrint('[LandingScreen] dispose called');
    _mainController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[LandingScreen] build() called');

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.05),
              AppColors.background,
              AppColors.primaryDark.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.largeSpacing),
            child: Column(
              children: [
                const Spacer(),

                /// Wallet Animation
                _logWidget('[LandingScreen] Building WalletSavingsAnimation'),
                SizedBox(
                  height: 250,
                  child: WalletSavingsAnimation(controller: _walletController),
                )
                    .animate(controller: _mainController)
                    .scale(
                        begin: const Offset(0.5, 0.5), curve: Curves.elasticOut)
                    .fadeIn(),

                const SizedBox(height: AppConstants.extraLargeSpacing),

                /// Title
                _logWidget('[LandingScreen] Building Title Text'),
                Text(
                  'Budgetary',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                )
                    .animate(controller: _mainController)
                    .slideX(begin: -1.5, delay: 300.ms)
                    .fadeIn(delay: 300.ms),

                const SizedBox(height: AppConstants.mediumSpacing),

                /// Subtitle
                _logWidget('[LandingScreen] Building Subtitle Text'),
                Text(
                  'Smart Money Management Made Simple',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                )
                    .animate(controller: _mainController)
                    .slideY(begin: 1.0, delay: 500.ms)
                    .fadeIn(delay: 500.ms),

                const Spacer(flex: 2),

                /// Start Saving Button
                _logWidget('[LandingScreen] Building Start Saving Button'),
                AnimatedButton(
                  onPressed: () {
                    debugPrint('[LandingScreen] Start Saving button pressed');
                    context.push('/signup');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.rocket_launch, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          'Start Saving Today',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(controller: _mainController)
                    .slideY(begin: 1.5, delay: 700.ms)
                    .fadeIn(delay: 700.ms),

                const SizedBox(height: AppConstants.mediumSpacing),

                /// Login Button
                _logWidget('[LandingScreen] Building Login Button'),
                AnimatedButton(
                  onPressed: () {
                    debugPrint('[LandingScreen] Login button pressed');
                    context.push('/login');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          'I Already Have Account',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(controller: _mainController)
                    .slideY(begin: 1.5, delay: 900.ms)
                    .fadeIn(delay: 900.ms),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Utility to log when building sections
  Widget _logWidget(String message) {
    debugPrint(message);
    return const SizedBox.shrink();
  }
}
