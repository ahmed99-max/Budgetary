import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/providers/expense_provider.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/widgets/liquid_card.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../expenses/widgets/add_expense_dialog.dart';
import '../../expenses/widgets/expense_card.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        Provider.of<ExpenseProvider>(context, listen: false).loadExpenses(uid);
      }
    });
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddExpenseDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseProvider, UserProvider>(
      builder: (context, expenseProvider, userProvider, _) {
        return LoadingOverlay(
          isLoading: expenseProvider.isLoading,
          message: 'Loading expenses...',
          child: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppTheme.liquidBackground,
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Expenses',
                                style: TextStyle(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.2),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: IconButton(
                                  onPressed: _showAddExpenseDialog,
                                  icon: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 24.sp,
                                  ),
                                ),
                              ),
                            ],
                          )
                              .animate()
                              .fadeIn(duration: 800.ms)
                              .slideY(begin: -0.3, end: 0),

                          SizedBox(height: 20.h),

                          // Monthly Summary Card
                          LiquidCard(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.15),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'This Month',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                    Text(
                                      DateFormat('MMMM yyyy')
                                          .format(DateTime.now()),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                Row(
                                  children: [
                                    Text(
                                      '${userProvider.currency} ',
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    Text(
                                      NumberFormat('#,##0.00').format(
                                          expenseProvider
                                              .getTotalExpensesForMonth(
                                                  DateTime.now())),
                                      style: TextStyle(
                                        fontSize: 28.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 800.ms)
                              .slideX(begin: -0.3, end: 0),
                        ],
                      ),
                    ),

                    // Expenses List
                    Expanded(
                      child: expenseProvider.expenses.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 80.sp,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'No expenses yet',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Tap the + button to add your first expense',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                  LiquidButton(
                                    text: 'Add Expense',
                                    onPressed: _showAddExpenseDialog,
                                    icon: Icons.add,
                                  ),
                                ],
                              )
                                  .animate()
                                  .fadeIn(delay: 400.ms, duration: 800.ms)
                                  .scale(
                                      begin: const Offset(0.8, 0.8),
                                      end: const Offset(1, 1)),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              itemCount: expenseProvider.expenses.length,
                              itemBuilder: (context, index) {
                                final expense = expenseProvider.expenses[index];
                                return ExpenseCard(
                                  expense: expense,
                                  currency: userProvider.currency,
                                )
                                    .animate()
                                    .fadeIn(
                                        delay: (100 * index).ms,
                                        duration: 600.ms)
                                    .slideX(begin: 0.3, end: 0);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
