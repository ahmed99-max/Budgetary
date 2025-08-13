import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../shared/widgets/responsive_builder.dart';
import '../../../shared/widgets/neumorphic_container.dart';

class BudgetOverviewCard extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;
  final double budgetProgress;

  const BudgetOverviewCard({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
    required this.budgetProgress,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final formatter = NumberFormat.currency(symbol: '\$');
    final remaining = totalBudget - totalSpent;
    final progressPercent = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

    Color getProgressColor() {
      if (progressPercent < 0.7) return const Color(0xFF27AE60);
      if (progressPercent < 0.9) return const Color(0xFFF39C12);
      return const Color(0xFFE74C3C);
    }

    return Container(
      margin: EdgeInsets.all(20.rr),
      child: NeumorphicContainer(
        padding: EdgeInsets.all(24.rr),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Budget',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                        fontWeight: FontWeight.w500,
                        color: themeProvider.isDarkMode
                            ? const Color(0xFFBDC3C7)
                            : const Color(0xFF7F8C8D),
                      ),
                    ),
                    SizedBox(height: 4.rh),
                    Text(
                      formatter.format(totalBudget),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
                        fontWeight: FontWeight.w700,
                        color: themeProvider.isDarkMode
                            ? const Color(0xFFECF0F1)
                            : const Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
                NeumorphicContainer(
                  padding: EdgeInsets.all(12.rr),
                  style: context.convexStyle.copyWith(
                    color: getProgressColor().withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: getProgressColor(),
                    size: 24.rr,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.rh),

            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Spent',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                        fontWeight: FontWeight.w500,
                        color: themeProvider.isDarkMode
                            ? const Color(0xFFBDC3C7)
                            : const Color(0xFF7F8C8D),
                      ),
                    ),
                    Text(
                      '${(progressPercent * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                        fontWeight: FontWeight.w600,
                        color: getProgressColor(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.rh),
                NeumorphicContainer(
                  height: 8.rh,
                  style: context.concaveStyle.copyWith(depth: -2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.rr),
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(getProgressColor()),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.rh),

            // Stats Row
            ResponsiveBuilder(
              builder: (context, deviceType) {
                return deviceType == DeviceType.mobile
                    ? Column(children: _buildStatItems(context, themeProvider, formatter, totalSpent, remaining))
                    : Row(
                        children: _buildStatItems(context, themeProvider, formatter, totalSpent, remaining)
                            .map((item) => Expanded(child: item))
                            .toList(),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStatItems(BuildContext context, ThemeProvider themeProvider, 
      NumberFormat formatter, double spent, double remaining) {
    return [
      _StatItem(
        label: 'Spent',
        value: formatter.format(spent),
        color: const Color(0xFFE74C3C),
        icon: Icons.trending_down,
      ),
      SizedBox(height: 12.rh, width: 12.rw),
      _StatItem(
        label: 'Remaining',
        value: formatter.format(remaining),
        color: const Color(0xFF27AE60),
        icon: Icons.savings,
      ),
    ];
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return NeumorphicContainer(
      padding: EdgeInsets.all(16.rr),
      margin: EdgeInsets.symmetric(vertical: 4.rh),
      style: context.flatStyle.copyWith(depth: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20.rr,
          ),
          SizedBox(width: 12.rw),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                  fontWeight: FontWeight.w500,
                  color: themeProvider.isDarkMode
                      ? const Color(0xFFBDC3C7)
                      : const Color(0xFF7F8C8D),
                ),
              ),
              SizedBox(height: 2.rh),
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
