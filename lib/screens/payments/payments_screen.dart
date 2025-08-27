import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:budgetary/core/services/payment_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PaymentService _paymentService = PaymentService();
  List<PaymentTransaction> _paymentHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _paymentService.initialize();
    _setupPaymentCallbacks();
    _loadPaymentHistory();
  }

  void _setupPaymentCallbacks() {
    _paymentService.onPaymentSuccess = (response) {
      _showPaymentResult(
        success: true,
        title: 'Payment Successful!',
        message: 'Payment ID: ${response.paymentId}',
        paymentId: response.paymentId!,
      );
    };

    _paymentService.onPaymentError = (response) {
      _showPaymentResult(
        success: false,
        title: 'Payment Failed',
        message: '${response.message}',
      );
    };

    _paymentService.onExternalWallet = (response) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Redirected to ${response.walletName}'),
          backgroundColor: Colors.blue,
        ),
      );
    };
  }

  Future<void> _loadPaymentHistory() async {
    setState(() => _isLoading = true);
    final history = await _paymentService.getPaymentHistory();
    setState(() {
      _paymentHistory =
          history.map((h) => PaymentTransaction.fromJson(h)).toList();
      _isLoading = false;
    });
  }

  void _showPaymentResult({
    required bool success,
    required String title,
    required String message,
    String? paymentId,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
              size: 30,
            ),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (success) {
                _loadPaymentHistory(); // Refresh history
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (success && paymentId != null) {
      // Save payment record
      _paymentService.savePaymentRecord(
        paymentId: paymentId,
        amount: 0, // You can pass the actual amount
        description: 'Payment',
        status: 'success',
        method: 'razorpay',
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _paymentService.dispose();
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
          'Payments',
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
            Tab(text: 'Pay'),
            Tab(text: 'Scan'),
            Tab(text: 'History'),
            Tab(text: 'External'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPayTab(),
          _buildScanTab(),
          _buildHistoryTab(),
          _buildExternalTab(),
        ],
      ),
    );
  }

  Widget _buildPayTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _buildQuickPayOptions(),
          SizedBox(height: 30.h),
          _buildCustomPaymentForm(),
          SizedBox(height: 30.h),
          _buildRecentPayees(),
        ],
      ),
    );
  }

  Widget _buildQuickPayOptions() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4169E1), Color(0xFF61A5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4169E1).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Pay',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickPayButton(
                icon: Icons.restaurant,
                label: 'Food',
                amount: 500,
              ),
              _buildQuickPayButton(
                icon: Icons.local_gas_station,
                label: 'Fuel',
                amount: 2000,
              ),
              _buildQuickPayButton(
                icon: Icons.shopping_cart,
                label: 'Grocery',
                amount: 1500,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPayButton({
    required IconData icon,
    required String label,
    required double amount,
  }) {
    return GestureDetector(
      onTap: () => _initiateQuickPayment(label, amount),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 30.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '₹$amount',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomPaymentForm() {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Payment',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),
          TextFormField(
            controller: amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
            decoration: InputDecoration(
              labelText: 'Amount',
              labelStyle: TextStyle(color: Colors.white70),
              prefixText: '₹ ',
              prefixStyle: TextStyle(color: Colors.white, fontSize: 16.sp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: Colors.white30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: Color(0xFF4169E1)),
              ),
            ),
          ),
          SizedBox(height: 15.h),
          TextFormField(
            controller: descriptionController,
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: Colors.white30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: Color(0xFF4169E1)),
              ),
            ),
          ),
          SizedBox(height: 25.h),
          SizedBox(
            width: double.infinity,
            height: 55.h,
            child: ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  _initiateCustomPayment(
                    amount,
                    descriptionController.text.isEmpty
                        ? 'Payment'
                        : descriptionController.text,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid amount'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4169E1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                elevation: 5,
              ),
              child: Text(
                'Pay Now',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPayees() {
    // Mock recent payees
    final recentPayees = [
      {'name': 'Swiggy', 'upi': 'swiggy@paytm', 'icon': Icons.restaurant},
      {'name': 'Uber', 'upi': 'uber@axisb', 'icon': Icons.directions_car},
      {'name': 'Amazon', 'upi': 'amazon@icici', 'icon': Icons.shopping_bag},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Payees',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 15.h),
        ...recentPayees.map((payee) => _buildPayeeCard(payee)).toList(),
      ],
    );
  }

  Widget _buildPayeeCard(Map<String, dynamic> payee) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Color(0xFF4169E1).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              payee['icon'],
              color: Color(0xFF4169E1),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payee['name'],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  payee['upi'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _payToRecentPayee(payee),
            icon: Icon(
              Icons.arrow_forward_ios,
              color: Colors.white60,
              size: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initiateQuickPayment(String category, double amount) async {
    final orderId = await _paymentService.createOrder(
      amount: amount,
      description: '$category Payment',
    );

    if (orderId != null) {
      await _paymentService.makePayment(
        amount: amount,
        description: '$category Payment',
        orderId: orderId,
        userName: 'User', // Get from user preferences
        userEmail: 'user@example.com', // Get from user preferences
        userPhone: '9999999999', // Get from user preferences
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create payment order'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _initiateCustomPayment(double amount, String description) async {
    final orderId = await _paymentService.createOrder(
      amount: amount,
      description: description,
    );

    if (orderId != null) {
      await _paymentService.makePayment(
        amount: amount,
        description: description,
        orderId: orderId,
        userName: 'User', // Get from user preferences
        userEmail: 'user@example.com', // Get from user preferences
        userPhone: '9999999999', // Get from user preferences
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create payment order'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _payToRecentPayee(Map<String, dynamic> payee) {
    // Show amount input dialog for recent payee
    showDialog(
      context: context,
      builder: (context) => _buildPayeeAmountDialog(payee),
    );
  }

  Widget _buildPayeeAmountDialog(Map<String, dynamic> payee) {
    final amountController = TextEditingController();

    return AlertDialog(
      backgroundColor: Color(0xFF2A2A3E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Text(
        'Pay ${payee['name']}',
        style: TextStyle(color: Colors.white, fontSize: 18.sp),
      ),
      content: TextFormField(
        controller: amountController,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Amount',
          labelStyle: TextStyle(color: Colors.white70),
          prefixText: '₹ ',
          prefixStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.white30),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.white60)),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(amountController.text);
            if (amount != null && amount > 0) {
              Navigator.pop(context);
              _initiateCustomPayment(amount, 'Payment to ${payee['name']}');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please enter a valid amount'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4169E1)),
          child: Text('Pay', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildScanTab() {
    return QRScannerWidget();
  }

  Widget _buildHistoryTab() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Color(0xFF4169E1)),
      );
    }

    if (_paymentHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80.sp,
              color: Colors.white30,
            ),
            SizedBox(height: 20.h),
            Text(
              'No payment history found',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: _paymentHistory.length,
      itemBuilder: (context, index) {
        final payment = _paymentHistory[index];
        return _buildHistoryCard(payment);
      },
    );
  }

  Widget _buildHistoryCard(PaymentTransaction payment) {
    final isSuccess = payment.status.toLowerCase() == 'success';

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: isSuccess
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: (isSuccess ? Colors.green : Colors.red).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.description,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a')
                      .format(payment.timestamp),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${NumberFormat('#,##0.00').format(payment.amount)}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExternalTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mark External Payments',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Record payments made outside the app',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white60,
            ),
          ),
          SizedBox(height: 30.h),
          _buildExternalPaymentForm(),
        ],
      ),
    );
  }

  Widget _buildExternalPaymentForm() {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final merchantController = TextEditingController();

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Amount',
              labelStyle: TextStyle(color: Colors.white70),
              prefixText: '₹ ',
              prefixStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: Colors.white30),
              ),
            ),
          ),
          SizedBox(height: 15.h),
          TextFormField(
            controller: merchantController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Merchant/Payee',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: Colors.white30),
              ),
            ),
          ),
          SizedBox(height: 15.h),
          TextFormField(
            controller: descriptionController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: Colors.white30),
              ),
            ),
          ),
          SizedBox(height: 25.h),
          SizedBox(
            width: double.infinity,
            height: 55.h,
            child: ElevatedButton.icon(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount != null &&
                    amount > 0 &&
                    merchantController.text.isNotEmpty) {
                  _recordExternalPayment(
                    amount,
                    merchantController.text,
                    descriptionController.text,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: Icon(Icons.add_circle_outline, color: Colors.white),
              label: Text(
                'Record Payment',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _recordExternalPayment(
      double amount, String merchant, String description) {
    final externalPayment = PaymentTransaction(
      id: 'ext_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      description: description.isEmpty ? 'Payment to $merchant' : description,
      status: 'success',
      method: 'external',
      timestamp: DateTime.now(),
      isExternal: true,
    );

    // Save to local storage
    _paymentService.savePaymentRecord(
      paymentId: externalPayment.id,
      amount: externalPayment.amount,
      description: externalPayment.description,
      status: externalPayment.status,
      method: externalPayment.method,
    );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External payment recorded successfully'),
        backgroundColor: Colors.green,
      ),
    );

    // Refresh history
    _loadPaymentHistory();
  }
}

// QR Scanner Widget
class QRScannerWidget extends StatefulWidget {
  @override
  _QRScannerWidgetState createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isFlashOn = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            margin: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Color(0xFF4169E1),
                  borderRadius: 20,
                  borderLength: 30,
                  borderWidth: 5,
                  cutOutSize: 250.w,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Text(
                'Scan UPI QR Code',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Point your camera at a UPI QR code to pay',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white60,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _toggleFlash,
                    icon: Icon(_isFlashOn ? Icons.flash_off : Icons.flash_on),
                    label: Text(_isFlashOn ? 'Flash Off' : 'Flash On'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4169E1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => controller?.flipCamera(),
                    icon: Icon(Icons.flip_camera_android),
                    label: Text('Flip'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4169E1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        _handleScannedData(scanData.code!);
      }
    });
  }

  void _handleScannedData(String data) {
    controller?.pauseCamera();

    // Parse UPI URL
    if (data.startsWith('upi://pay')) {
      final uri = Uri.parse(data);
      final pa = uri.queryParameters['pa']; // Payee address
      final pn = uri.queryParameters['pn']; // Payee name
      final am = uri.queryParameters['am']; // Amount
      final tn = uri.queryParameters['tn']; // Transaction note

      _showPaymentConfirmationDialog(
        payeeAddress: pa ?? '',
        payeeName: pn ?? 'Unknown',
        amount: am != null ? double.tryParse(am) : null,
        note: tn ?? '',
      );
    } else {
      // Show generic QR data
      _showQRDataDialog(data);
    }
  }

  void _showPaymentConfirmationDialog({
    required String payeeAddress,
    required String payeeName,
    double? amount,
    required String note,
  }) {
    final amountController = TextEditingController(
      text: amount?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2A2A3E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'Confirm Payment',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Payee', style: TextStyle(color: Colors.white70)),
              subtitle: Text(payeeName, style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              title: Text('UPI ID', style: TextStyle(color: Colors.white70)),
              subtitle:
                  Text(payeeAddress, style: TextStyle(color: Colors.white)),
            ),
            if (note.isNotEmpty)
              ListTile(
                title: Text('Note', style: TextStyle(color: Colors.white70)),
                subtitle: Text(note, style: TextStyle(color: Colors.white)),
              ),
            SizedBox(height: 10.h),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: Colors.white70),
                prefixText: '₹ ',
                prefixStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.white30),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller?.resumeCamera();
            },
            child: Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              final payAmount = double.tryParse(amountController.text);
              if (payAmount != null && payAmount > 0) {
                Navigator.pop(context);
                _processUPIPayment(payAmount, payeeName);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid amount'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4169E1)),
            child: Text('Pay Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showQRDataDialog(String data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2A2A3E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('QR Code Scanned', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Scanned Data:',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                data,
                style: TextStyle(color: Colors.white, fontSize: 12.sp),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller?.resumeCamera();
            },
            child: Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _processUPIPayment(double amount, String payeeName) async {
    final paymentService = PaymentService();

    final orderId = await paymentService.createOrder(
      amount: amount,
      description: 'Payment to $payeeName',
    );

    if (orderId != null) {
      await paymentService.makePayment(
        amount: amount,
        description: 'Payment to $payeeName',
        orderId: orderId,
      );
    }

    controller?.resumeCamera();
  }

  void _toggleFlash() {
    controller?.toggleFlash();
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
