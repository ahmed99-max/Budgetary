// lib/shared/utils/dialog_utils.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shows a full-screen dialog with the given content widget.
/// This acts like a new page with an app bar and close button.
void showFullScreenLoanDetail(BuildContext context, Widget loanDetailWidget) {
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true, // Makes it behave like a full-screen dialog
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Loan Details'), // Customize title
          backgroundColor: Colors.transparent, // Matches your app's style
          foregroundColor: Colors.black87,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close), // Close button instead of back arrow
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: Colors
            .transparent, // Transparent to blend with your gradient background
        body: SafeArea(
          child: SingleChildScrollView(
            // Makes content scrollable if too long
            padding: EdgeInsets.all(16.w), // Padding for better spacing
            child: loanDetailWidget, // Your EnhancedLoanCardWidget goes here
          ),
        ),
      ),
    ),
  );
}
