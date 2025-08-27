// lib/screens/loans/loans_screen.dart

import 'package:budgetary/core/services/cibil_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CibilService _cibilService = CibilService();

  CibilScore? _cibilScore;
  List<LoanOffer> _preApprovedLoans = [];
  List<LoanOffer> _availableLoans = [];
  bool _isLoadingScore = false;
  bool _isLoadingLoans = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSavedCibilScore();
  }

  Future<void> _loadSavedCibilScore() async {
    final savedScore = await _cibilService.getSavedCibilScore();
    if (savedScore != null) {
      setState(() {
        _cibilScore = savedScore;
      });
      _loadPreApprovedLoans();
    }
    _loadAvailableLoans();
  }

  Future<void> _fetchCibilScore() async {
    setState(() => _isLoadingScore = true);

    // Show input dialog for user details
    final userDetails = await _showCibilInputDialog();
    if (userDetails != null) {
      final score = await _cibilService.getCibilScore(
        pan: userDetails['pan']!,
        name: userDetails['name']!,
        dateOfBirth: userDetails['dob']!,
        mobile: userDetails['mobile']!,
      );

      if (score != null) {
        await _cibilService.saveCibilScore(score);
        setState(() {
          _cibilScore = score;
        });
        _loadPreApprovedLoans();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CIBIL score fetched successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch CIBIL score. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoadingScore = false);
  }

  Future<Map<String, String>?> _showCibilInputDialog() async {
    final _panController = TextEditingController();
    final _nameController = TextEditingController();
    final _dobController = TextEditingController();
    final _mobileController = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2A2A3E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'Enter Your Details',
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'We need these details to fetch your CIBIL score',
                style: TextStyle(color: Colors.white70, fontSize: 12.sp),
              ),
              SizedBox(height: 20.h),
              _buildInputField(_nameController, 'Full Name', Icons.person),
              SizedBox(height: 15.h),
              _buildInputField(_panController, 'PAN Number', Icons.credit_card),
              SizedBox(height: 15.h),
              _buildInputField(_dobController, 'Date of Birth (YYYY-MM-DD)',
                  Icons.calendar_today),
              SizedBox(height: 15.h),
              _buildInputField(_mobileController, 'Mobile Number', Icons.phone),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_panController.text.isNotEmpty &&
                  _nameController.text.isNotEmpty &&
                  _dobController.text.isNotEmpty &&
                  _mobileController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'pan': _panController.text.toUpperCase(),
                  'name': _nameController.text,
                  'dob': _dobController.text,
                  'mobile': _mobileController.text,
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4169E1)),
            child: Text('Fetch Score', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.white30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Color(0xFF4169E1)),
        ),
      ),
    );
  }

  Future<void> _loadPreApprovedLoans() async {
    if (_cibilScore == null) return;

    setState(() => _isLoadingLoans = true);
    final loans = await _cibilService.getPreApprovedLoans(_cibilScore!);
    setState(() {
      _preApprovedLoans = loans;
      _isLoadingLoans = false;
    });
  }

  Future<void> _loadAvailableLoans() async {
    setState(() => _isLoadingLoans = true);
    final loans = await _cibilService.getAllAvailableLoans();
    setState(() {
      _availableLoans = loans;
      _isLoadingLoans = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: Text(
          'Loans & Credit',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4169E1),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'CIBIL Score'),
            Tab(text: 'Pre-Approved'),
            Tab(text: 'All Loans'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCibilTab(),
          _buildPreApprovedTab(),
          _buildAllLoansTab(),
        ],
      ),
    );
  }

  Widget _buildCibilTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_cibilScore == null) _buildFetchScoreCard(),
          if (_cibilScore != null) ...[
            _buildScoreCard(),
            SizedBox(height: 30.h),
            _buildScoreBreakdown(),
            SizedBox(height: 30.h),
            _buildCreditHealthTips(),
          ],
        ],
      ),
    );
  }

  Widget _buildFetchScoreCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4169E1), Color(0xFF61A5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4169E1).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.credit_score,
            size: 80.sp,
            color: Colors.white,
          ),
          SizedBox(height: 20.h),
          Text(
            'Check Your CIBIL Score',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15.h),
          Text(
            'Get your free CIBIL score and unlock personalized loan offers',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 25.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: _isLoadingScore ? null : _fetchCibilScore,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF4169E1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                elevation: 5,
              ),
              child: _isLoadingScore
                  ? CircularProgressIndicator(color: Color(0xFF4169E1))
                  : Text(
                      'Get Free Score',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    final score = _cibilScore!.score;
    final category = _cibilService.getCreditScoreCategory(score);
    final color = _cibilService.getCreditScoreColor(score);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(25.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your CIBIL Score',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'Updated ${DateFormat('MMM dd').format(_cibilScore!.reportDate)}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Circular Progress Indicator for Score
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 120.w,
                width: 120.w,
                child: CircularProgressIndicator(
                  value: score / 900,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Column(
                children: [
                  Text(
                    score.toString(),
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '/ 900',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _fetchCibilScore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text('Refresh Score'),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showDetailedReport(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text('View Report'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown() {
    final score = _cibilScore!;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Score Breakdown',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),
          _buildBreakdownItem(
            'Payment History',
            '${score.paymentHistory.toInt()}%',
            score.paymentHistory / 100,
            Colors.green,
          ),
          _buildBreakdownItem(
            'Credit Utilization',
            '${score.creditUtilization.toInt()}%',
            score.creditUtilization / 100,
            score.creditUtilization > 30 ? Colors.orange : Colors.green,
          ),
          _buildBreakdownItem(
            'Credit Age',
            '${(score.creditAge / 12).toInt()} years',
            (score.creditAge / 120).clamp(0, 1),
            Colors.blue,
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    'Credit Accounts', score.creditAccounts.toString()),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: _buildStatCard(
                    'Recent Inquiries', score.recentInquiries.toString()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(
      String title, String value, double progress, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white70,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        SizedBox(height: 15.h),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white60,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCreditHealthTips() {
    final tips = [
      'Pay your bills on time to maintain a good payment history',
      'Keep your credit utilization below 30%',
      'Don\'t close old credit accounts',
      'Limit hard inquiries on your credit report',
    ];

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.yellow, size: 24.sp),
              SizedBox(width: 10.w),
              Text(
                'Credit Health Tips',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          ...tips.map((tip) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPreApprovedTab() {
    if (_cibilScore == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_score,
              size: 80.sp,
              color: Colors.white30,
            ),
            SizedBox(height: 20.h),
            Text(
              'Check your CIBIL score first',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.white60,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Pre-approved loans are based on your credit score',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(0),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4169E1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
              ),
              child: Text(
                'Check CIBIL Score',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoadingLoans) {
      return Center(
        child: CircularProgressIndicator(color: Color(0xFF4169E1)),
      );
    }

    if (_preApprovedLoans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied,
              size: 80.sp,
              color: Colors.white30,
            ),
            SizedBox(height: 20.h),
            Text(
              'No pre-approved loans available',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.white60,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Improve your credit score to get better offers',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: _preApprovedLoans.length,
      itemBuilder: (context, index) {
        final loan = _preApprovedLoans[index];
        return _buildLoanCard(loan, isPreApproved: true);
      },
    );
  }

  Widget _buildAllLoansTab() {
    if (_isLoadingLoans) {
      return Center(
        child: CircularProgressIndicator(color: Color(0xFF4169E1)),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: _availableLoans.length,
      itemBuilder: (context, index) {
        final loan = _availableLoans[index];
        return _buildLoanCard(loan, isPreApproved: false);
      },
    );
  }

  Widget _buildLoanCard(LoanOffer loan, {required bool isPreApproved}) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isPreApproved
              ? Colors.green.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPreApproved
                    ? [
                        Colors.green.withOpacity(0.2),
                        Colors.green.withOpacity(0.1)
                      ]
                    : [
                        Color(0xFF4169E1).withOpacity(0.2),
                        Color(0xFF4169E1).withOpacity(0.1)
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan.bankName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        loan.loanType,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPreApproved)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      'PRE-APPROVED',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildLoanDetailItem(
                        'Max Amount',
                        '₹${NumberFormat('#,##0').format(loan.maxAmount)}',
                        Icons.account_balance_wallet,
                      ),
                    ),
                    Expanded(
                      child: _buildLoanDetailItem(
                        'Interest Rate',
                        '${loan.interestRate}% p.a.',
                        Icons.percent,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildLoanDetailItem(
                        'Tenure',
                        '${loan.tenure} months',
                        Icons.schedule,
                      ),
                    ),
                    Expanded(
                      child: _buildLoanDetailItem(
                        'Processing Fee',
                        '${loan.processingFee}%',
                        Icons.receipt,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // EMI Calculator
                Container(
                  padding: EdgeInsets.all(15.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calculate,
                          color: Color(0xFF4169E1), size: 20.sp),
                      SizedBox(width: 10.w),
                      Text(
                        'EMI for max amount: ',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 12.sp),
                      ),
                      Text(
                        '₹${NumberFormat('#,##0').format(loan.calculateEMI(loan.maxAmount))}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showEMICalculator(loan),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Calculate EMI',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _applyForLoan(loan),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isPreApproved ? Colors.green : Color(0xFF4169E1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Apply Now',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanDetailItem(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF4169E1), size: 16.sp),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white60,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDetailedReport() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Color(0xFF2A2A3E),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Credit Report Details',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  'Credit Mix:',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10.h),
                ..._cibilScore!.creditMix.map((mix) => Padding(
                      padding: EdgeInsets.only(bottom: 5.h),
                      child: Text('• $mix',
                          style: TextStyle(color: Colors.white70)),
                    )),
                SizedBox(height: 20.h),
                Text(
                  'Total Credit Limit: ₹${NumberFormat('#,##0').format(_cibilScore!.totalCreditLimit)}',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Report Generated: ${DateFormat('MMM dd, yyyy').format(_cibilScore!.reportDate)}',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEMICalculator(LoanOffer loan) {
    final _loanAmountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          double loanAmount = double.tryParse(_loanAmountController.text) ?? 0;
          double emi = loanAmount > 0 ? loan.calculateEMI(loanAmount) : 0;

          return AlertDialog(
            backgroundColor: Color(0xFF2A2A3E),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r)),
            title: Text(
              'EMI Calculator',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _loanAmountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) => setDialogState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Loan Amount',
                    labelStyle: TextStyle(color: Colors.white70),
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(15.w),
                  decoration: BoxDecoration(
                    color: Color(0xFF4169E1).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Monthly EMI',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 14.sp),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        '₹${NumberFormat('#,##0').format(emi)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text('Interest Rate',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12.sp)),
                          Text('${loan.interestRate}%',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text('Tenure',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12.sp)),
                          Text('${loan.tenure} months',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: TextStyle(color: Colors.white60)),
              ),
              if (loanAmount > 0)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _applyForLoan(loan);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4169E1)),
                  child: Text('Apply for This Amount',
                      style: TextStyle(color: Colors.white)),
                ),
            ],
          );
        },
      ),
    );
  }

  void _applyForLoan(LoanOffer loan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2A2A3E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'Apply for Loan',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You are applying for ${loan.loanType} from ${loan.bankName}',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15.h),
            Container(
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Text(
                    'Max Amount: ₹${NumberFormat('#,##0').format(loan.maxAmount)}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Interest Rate: ${loan.interestRate}% p.a.',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Processing Fee: ${loan.processingFee}%',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15.h),
            Text(
              'This will redirect you to the bank\'s website for application.',
              style: TextStyle(color: Colors.white60, fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Redirecting to ${loan.bankName}...'),
                  backgroundColor: Colors.green,
                ),
              );
              // Here you would implement the actual redirection to bank's loan application
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4169E1)),
            child: Text('Continue', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
