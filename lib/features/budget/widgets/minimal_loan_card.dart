import 'package:budgetary/features/loan/models/loan_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class MinimalLoanCard extends StatelessWidget {
  final LoanModel loan;
  final String currency;
  final VoidCallback? onViewDetails;

  const MinimalLoanCard({
    super.key,
    required this.loan,
    required this.currency,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final progress = loan.progress.clamp(0.0, 1.0);
    final percentText = '${(progress * 100).toStringAsFixed(1)}% paid';

    return Card(
      color: Colors.white.withOpacity(0.07),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loan Name
            Text(
              loan.name,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10.h),
            // Percentage Label Above Bar
            Text(
              percentText,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 6.h),
            // Progress Bar With Remaining
            Container(
              height: 12.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: (progress * 1000).toInt(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF00BFFF),
                            Color(0xFF39C4FF),
                          ],
                        ),
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(6.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: (1000 - (progress * 1000).toInt()),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(6.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            // Remaining Amount
            Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    size: 18.sp, color: Colors.amber),
                SizedBox(width: 6.w),
                Text(
                  'Remaining: $currency ${NumberFormat('#,##0').format(loan.remainingAmount)}',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            // View Details Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  _showLoanDetailsDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  backgroundColor: Colors.white.withOpacity(0.11),
                  foregroundColor: Colors.white,
                  minimumSize: Size(0, 33.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('View Details',
                    style: TextStyle(
                        fontSize: 12.sp, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Details dialog with close button support
  void _showLoanDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(20),
        backgroundColor: Colors.transparent,
        child: Center(
          child: Container(
            width: 350,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
              maxWidth: MediaQuery.of(context).size.width * 0.95,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4169E1), Color(0xFF61A5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 22,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: name + actions + close
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        loan.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    // Close button
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    // 3 dots menu
                    PopupMenuButton<String>(
                      icon:
                          Icon(Icons.more_vert, color: Colors.white, size: 24),
                      color: Colors.white,
                      itemBuilder: (_) => [
                        PopupMenuItem(
                            value: 'pay',
                            child: Row(children: [
                              Icon(Icons.payment,
                                  color: Colors.green, size: 18),
                              SizedBox(width: 6),
                              Text('Make Payment')
                            ])),
                        PopupMenuItem(
                            value: 'edit',
                            child: Row(children: [
                              Icon(Icons.edit, color: Colors.blue, size: 18),
                              SizedBox(width: 6),
                              Text('Edit')
                            ])),
                        PopupMenuItem(
                            value: 'delete',
                            child: Row(children: [
                              Icon(Icons.delete, color: Colors.red, size: 18),
                              SizedBox(width: 6),
                              Text('Delete')
                            ])),
                      ],
                      onSelected: (value) {
                        if (value == 'pay') _showPaymentDialog(context);
                        if (value == 'edit') _showEditDialog(context);
                        if (value == 'delete') _showDeleteDialog(context);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 7),
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.27),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Text(
                        loan.status,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18),
                // Stat boxes
                Wrap(
                  spacing: 10,
                  runSpacing: 12,
                  children: [
                    _statBox(
                      icon: Icons.account_balance_wallet,
                      label: "Total",
                      value:
                          "INR ${NumberFormat('#,##0').format(loan.totalAmount)}",
                    ),
                    _statBox(
                      icon: Icons.payment,
                      label: "EMI",
                      value:
                          "INR ${NumberFormat('#,##0').format(loan.emiAmount)}",
                    ),
                    _statBox(
                      icon: Icons.trending_up,
                      label: "Paid",
                      value:
                          "INR ${NumberFormat('#,##0').format(loan.paidAmount)}",
                    ),
                    _statBox(
                      icon: Icons.pending_actions,
                      label: "Remaining",
                      value:
                          "INR ${NumberFormat('#,##0').format(loan.remainingAmount)}",
                      valueColor: Colors.yellowAccent.shade700,
                    ),
                    _statBox(
                      icon: Icons.calendar_today,
                      label: "Start",
                      value: DateFormat('MMM yyyy').format(loan.startDate),
                    ),
                    _statBox(
                      icon: Icons.schedule,
                      label: "Tenure",
                      value: "${loan.tenureMonths} months",
                    ),
                  ],
                ),
                SizedBox(height: 28),
                // ACTION BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showPaymentDialog(context),
                        icon: Icon(Icons.payment),
                        label: Text('Pay',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showEditDialog(context),
                        icon: Icon(Icons.edit, color: Colors.white),
                        label: Text('Edit',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white70),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Make Payment'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // Simulate payment success
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("Payment recorded!"),
                    backgroundColor: Colors.green),
              );
            },
            child: Text('Pay'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final titleController = TextEditingController(text: loan.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Loan'),
        content: TextField(
          controller: titleController,
          decoration: InputDecoration(labelText: 'Loan Title'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("Loan updated!"),
                    backgroundColor: Colors.blue),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Loan?'),
        content: Text('Are you sure you want to permanently delete this loan?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("Loan deleted!"),
                    backgroundColor: Colors.red),
              );
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _statBox({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      width: 144,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
