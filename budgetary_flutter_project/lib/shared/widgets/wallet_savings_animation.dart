import 'package:flutter/material.dart';
import 'dart:math' as math;

class WalletSavingsAnimation extends StatelessWidget {
  final AnimationController controller;

  const WalletSavingsAnimation({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: WalletPainter(controller.value),
          child: Container(),
        );
      },
    );
  }
}

class WalletPainter extends CustomPainter {
  final double animation;

  WalletPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw person
    _drawPerson(canvas, center - const Offset(60, 0));

    // Draw wallet
    _drawWallet(canvas, center + const Offset(60, 0));

    // Draw money animation
    _drawMoney(canvas, center);
  }

  void _drawPerson(Canvas canvas, Offset position) {
    final paint = Paint()..color = const Color(0xFF4F46E5);

    // Head
    canvas.drawCircle(position + const Offset(0, -40), 15, paint);

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: position, width: 20, height: 40),
        const Radius.circular(10),
      ),
      paint,
    );

    // Arms (animated)
    final armOffset = math.sin(animation * 2 * math.pi) * 5;
    canvas.drawLine(
      position + Offset(-10, -10 + armOffset),
      position + Offset(20, -5 + armOffset),
      Paint()..color = paint.color..strokeWidth = 6..strokeCap = StrokeCap.round,
    );
  }

  void _drawWallet(Canvas canvas, Offset position) {
    final paint = Paint()..color = const Color(0xFF7C3AED);

    // Wallet body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: position, width: 50, height: 35),
        const Radius.circular(6),
      ),
      paint,
    );

    // Wallet line
    canvas.drawLine(
      position + const Offset(-23, -5),
      position + const Offset(23, -5),
      Paint()..color = const Color(0xFF5B21B6)..strokeWidth = 2,
    );
  }

  void _drawMoney(Canvas canvas, Offset center) {
    // Animated money coins
    for (int i = 0; i < 3; i++) {
      final progress = (animation + i * 0.3) % 1.0;
      final coinPos = Offset(
        center.dx - 30 + (progress * 60),
        center.dy - 20 - math.sin(progress * math.pi) * 30,
      );

      // Coin
      canvas.drawCircle(
        coinPos,
        8,
        Paint()..shader = const RadialGradient(
          colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
        ).createShader(Rect.fromCircle(center: coinPos, radius: 8)),
      );

      // Rupee symbol
      final textPainter = TextPainter(
        text: const TextSpan(
          text: '₹',
          style: TextStyle(color: Color(0xFF8B4513), fontSize: 8, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, coinPos - Offset(textPainter.width / 2, textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
