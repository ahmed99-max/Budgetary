// lib/services/payment_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  late Razorpay _razorpay;
  bool _initialized = false;

  // Your actual Razorpay keys
  static const String _testKeyId = 'rzp_test_RAHe2a2gpOfZSc';
  static const String _testKeySecret = 'cjdQt9bb39HSkUMcFg0pSlVp';
  static const String _liveKeyId = 'rzp_live_YOUR_LIVE_KEY'; // Replace when going live
  static const String _liveKeySecret = 'YOUR_LIVE_KEY_SECRET'; // Replace when going live
  static const bool _isTestMode = true; // Set to false for production

  String get keyId => _isTestMode ? _testKeyId : _liveKeyId;
  String get keySecret => _isTestMode ? _testKeySecret : _liveKeySecret;

  void initialize() {
    if (_initialized) return;
    
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    
    _initialized = true;
  }

  void dispose() {
    if (_initialized) {
      _razorpay.clear();
    }
  }

  // Payment callbacks
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(ExternalWalletResponse)? onExternalWallet;

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Payment Success: ${response.paymentId}');
    onPaymentSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.code} - ${response.message}');
    onPaymentError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
    onExternalWallet?.call(response);
  }

  Future<bool> makePayment({
    required double amount,
    required String description,
    required String orderId,
    String? userEmail,
    String? userPhone,
    String? userName,
  }) async {
    try {
      var options = {
        'key': keyId,
        'amount': (amount * 100).toInt(), // Amount in paise
        'name': 'Budgetary',
        'order_id': orderId,
        'description': description,
        'timeout': 300, // 5 minutes
        'prefill': {
          'contact': userPhone ?? '',
          'email': userEmail ?? '',
          'name': userName ?? '',
        },
        'theme': {
          'color': '#4169E1'
        },
        'method': {
          'upi': true,
          'card': true,
          'netbanking': true,
          'wallet': true,
        }
      };

      _razorpay.open(options);
      return true;
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
      return false;
    }
  }

  // UPI Payment with QR Code
  Future<String> generateUPIUrl({
    required String receiverUPI,
    required double amount,
    required String transactionNote,
    String? merchantCode,
  }) async {
    // Format: upi://pay?pa=receiver@upi&am=amount&tn=note&mc=merchantcode
    String url = 'upi://pay?'
        'pa=$receiverUPI&'
        'am=${amount.toStringAsFixed(2)}&'
        'tn=${Uri.encodeComponent(transactionNote)}';
    
    if (merchantCode != null) {
      url += '&mc=$merchantCode';
    }
    
    return url;
  }

  // Store payment history locally
  Future<void> savePaymentRecord({
    required String paymentId,
    required double amount,
    required String description,
    required String status,
    required String method,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingPayments = prefs.getStringList('payment_history') ?? [];
      
      final paymentRecord = {
        'id': paymentId,
        'amount': amount,
        'description': description,
        'status': status,
        'method': method,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      existingPayments.add(jsonEncode(paymentRecord));
      await prefs.setStringList('payment_history', existingPayments);
    } catch (e) {
      debugPrint('Error saving payment record: $e');
    }
  }

  // Get payment history
  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paymentStrings = prefs.getStringList('payment_history') ?? [];
      
      return paymentStrings
          .map((str) => jsonDecode(str) as Map<String, dynamic>)
          .toList()
          .reversed
          .toList();
    } catch (e) {
      debugPrint('Error getting payment history: $e');
      return [];
    }
  }

  // Create Razorpay order (for better security)
  Future<String?> createOrder({
    required double amount,
    required String description,
  }) async {
    try {
      final orderUrl = 'https://api.razorpay.com/v1/orders';
      final credentials = base64Encode(utf8.encode('$keyId:$keySecret'));
      
      final response = await http.post(
        Uri.parse(orderUrl),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': (amount * 100).toInt(),
          'currency': 'INR',
          'receipt': 'order_${DateTime.now().millisecondsSinceEpoch}',
          'notes': {'description': description},
        }),
      );

      if (response.statusCode == 200) {
        final orderData = jsonDecode(response.body);
        return orderData['id'];
      }
    } catch (e) {
      debugPrint('Error creating order: $e');
    }
    return null;
  }
}

// Payment Models
class PaymentTransaction {
  final String id;
  final double amount;
  final String description;
  final String status;
  final String method;
  final DateTime timestamp;
  final String? category;
  final bool isExternal;

  PaymentTransaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.status,
    required this.method,
    required this.timestamp,
    this.category,
    this.isExternal = false,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      method: json['method'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      category: json['category'],
      isExternal: json['isExternal'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'status': status,
      'method': method,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'isExternal': isExternal,
    };
  }
}