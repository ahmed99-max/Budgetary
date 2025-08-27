// lib/services/cibil_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CibilService {
  static final CibilService _instance = CibilService._internal();
  factory CibilService() => _instance;
  CibilService._internal();

  // Sample API endpoints - Replace with actual CIBIL API provider
  static const String _baseUrl = 'https://api.surepass.io/v1'; // Example
  static const String _apiKey = 'YOUR_CIBIL_API_KEY'; // Replace with actual key

  // Mock CIBIL score for demo (remove when using real API)
  Future<CibilScore?> getCibilScore({
    required String pan,
    required String name,
    required String dateOfBirth,
    required String mobile,
  }) async {
    try {
      // For demo purposes, generating mock data
      // Replace this with actual API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API delay
      
      final random = Random();
      final score = 650 + random.nextInt(250); // Random score between 650-900
      
      return CibilScore(
        score: score,
        reportDate: DateTime.now(),
        creditAccounts: random.nextInt(5) + 1,
        totalCreditLimit: (random.nextDouble() * 1000000) + 50000,
        creditUtilization: random.nextDouble() * 80,
        paymentHistory: random.nextDouble() * 100,
        creditAge: random.nextInt(120) + 12, // months
        creditMix: ['Credit Card', 'Home Loan', 'Personal Loan']
            .take(random.nextInt(3) + 1)
            .toList(),
        recentInquiries: random.nextInt(5),
      );
    } catch (e) {
      debugPrint('Error fetching CIBIL score: $e');
      return null;
    }
  }

  Future<void> saveCibilScore(CibilScore score) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cibil_score', jsonEncode(score.toJson()));
      await prefs.setString('cibil_last_updated', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error saving CIBIL score: $e');
    }
  }

  Future<CibilScore?> getSavedCibilScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scoreJson = prefs.getString('cibil_score');
      if (scoreJson != null) {
        return CibilScore.fromJson(jsonDecode(scoreJson));
      }
    } catch (e) {
      debugPrint('Error getting saved CIBIL score: $e');
    }
    return null;
  }

  Future<List<LoanOffer>> getPreApprovedLoans(CibilScore cibilScore) async {
    try {
      // Mock pre-approved loans based on CIBIL score
      await Future.delayed(const Duration(seconds: 1));
      
      final loans = <LoanOffer>[];
      final random = Random();

      if (cibilScore.score >= 750) {
        loans.addAll([
          LoanOffer(
            id: 'loan_1',
            bankName: 'HDFC Bank',
            loanType: 'Personal Loan',
            maxAmount: 1000000,
            interestRate: 10.5,
            tenure: 60,
            processingFee: 0.5,
            isPreApproved: true,
            logoUrl: '',
          ),
          LoanOffer(
            id: 'loan_2',
            bankName: 'ICICI Bank',
            loanType: 'Home Loan',
            maxAmount: 5000000,
            interestRate: 8.5,
            tenure: 240,
            processingFee: 0.25,
            isPreApproved: true,
            logoUrl: '',
          ),
        ]);
      }

      if (cibilScore.score >= 700) {
        loans.add(LoanOffer(
          id: 'loan_3',
          bankName: 'SBI',
          loanType: 'Personal Loan',
          maxAmount: 500000,
          interestRate: 12.0,
          tenure: 48,
          processingFee: 1.0,
          isPreApproved: true,
          logoUrl: '',
        ));
      }

      return loans;
    } catch (e) {
      debugPrint('Error fetching pre-approved loans: $e');
      return [];
    }
  }

  Future<List<LoanOffer>> getAllAvailableLoans() async {
    try {
      // Mock available loans
      await Future.delayed(const Duration(seconds: 1));
      
      return [
        LoanOffer(
          id: 'loan_4',
          bankName: 'Axis Bank',
          loanType: 'Car Loan',
          maxAmount: 2000000,
          interestRate: 9.5,
          tenure: 84,
          processingFee: 1.0,
          isPreApproved: false,
          logoUrl: '',
        ),
        LoanOffer(
          id: 'loan_5',
          bankName: 'Kotak Bank',
          loanType: 'Business Loan',
          maxAmount: 3000000,
          interestRate: 11.0,
          tenure: 60,
          processingFee: 2.0,
          isPreApproved: false,
          logoUrl: '',
        ),
        LoanOffer(
          id: 'loan_6',
          bankName: 'Yes Bank',
          loanType: 'Gold Loan',
          maxAmount: 1000000,
          interestRate: 10.0,
          tenure: 36,
          processingFee: 0.5,
          isPreApproved: false,
          logoUrl: '',
        ),
      ];
    } catch (e) {
      debugPrint('Error fetching available loans: $e');
      return [];
    }
  }

  String getCreditScoreCategory(int score) {
    if (score >= 800) return 'Excellent';
    if (score >= 750) return 'Very Good';
    if (score >= 700) return 'Good';
    if (score >= 650) return 'Fair';
    return 'Poor';
  }

  Color getCreditScoreColor(int score) {
    if (score >= 800) return Colors.green;
    if (score >= 750) return Colors.lightGreen;
    if (score >= 700) return Colors.yellow.shade700;
    if (score >= 650) return Colors.orange;
    return Colors.red;
  }
}

// CIBIL Score Model
class CibilScore {
  final int score;
  final DateTime reportDate;
  final int creditAccounts;
  final double totalCreditLimit;
  final double creditUtilization;
  final double paymentHistory;
  final int creditAge; // in months
  final List<String> creditMix;
  final int recentInquiries;

  CibilScore({
    required this.score,
    required this.reportDate,
    required this.creditAccounts,
    required this.totalCreditLimit,
    required this.creditUtilization,
    required this.paymentHistory,
    required this.creditAge,
    required this.creditMix,
    required this.recentInquiries,
  });

  factory CibilScore.fromJson(Map<String, dynamic> json) {
    return CibilScore(
      score: json['score'] ?? 0,
      reportDate: DateTime.parse(json['reportDate']),
      creditAccounts: json['creditAccounts'] ?? 0,
      totalCreditLimit: (json['totalCreditLimit'] ?? 0.0).toDouble(),
      creditUtilization: (json['creditUtilization'] ?? 0.0).toDouble(),
      paymentHistory: (json['paymentHistory'] ?? 0.0).toDouble(),
      creditAge: json['creditAge'] ?? 0,
      creditMix: List<String>.from(json['creditMix'] ?? []),
      recentInquiries: json['recentInquiries'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'reportDate': reportDate.toIso8601String(),
      'creditAccounts': creditAccounts,
      'totalCreditLimit': totalCreditLimit,
      'creditUtilization': creditUtilization,
      'paymentHistory': paymentHistory,
      'creditAge': creditAge,
      'creditMix': creditMix,
      'recentInquiries': recentInquiries,
    };
  }
}

// Loan Offer Model
class LoanOffer {
  final String id;
  final String bankName;
  final String loanType;
  final double maxAmount;
  final double interestRate;
  final int tenure; // in months
  final double processingFee; // percentage
  final bool isPreApproved;
  final String logoUrl;

  LoanOffer({
    required this.id,
    required this.bankName,
    required this.loanType,
    required this.maxAmount,
    required this.interestRate,
    required this.tenure,
    required this.processingFee,
    required this.isPreApproved,
    required this.logoUrl,
  });

  factory LoanOffer.fromJson(Map<String, dynamic> json) {
    return LoanOffer(
      id: json['id'] ?? '',
      bankName: json['bankName'] ?? '',
      loanType: json['loanType'] ?? '',
      maxAmount: (json['maxAmount'] ?? 0.0).toDouble(),
      interestRate: (json['interestRate'] ?? 0.0).toDouble(),
      tenure: json['tenure'] ?? 0,
      processingFee: (json['processingFee'] ?? 0.0).toDouble(),
      isPreApproved: json['isPreApproved'] ?? false,
      logoUrl: json['logoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankName': bankName,
      'loanType': loanType,
      'maxAmount': maxAmount,
      'interestRate': interestRate,
      'tenure': tenure,
      'processingFee': processingFee,
      'isPreApproved': isPreApproved,
      'logoUrl': logoUrl,
    };
  }

  double calculateEMI(double loanAmount) {
    final monthlyRate = interestRate / 12 / 100;
    final emi = (loanAmount * monthlyRate * pow(1 + monthlyRate, tenure)) /
        (pow(1 + monthlyRate, tenure) - 1);
    return emi;
  }
}