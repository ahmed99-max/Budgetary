import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingBubbles extends StatefulWidget {
  final AnimationController controller;
  final int bubbleCount;

  const FloatingBubbles({
    super.key,
    required this.controller,
    this.bubbleCount = 6,
  });

  @override
  State<FloatingBubbles> createState() => _FloatingBubblesState();
}

class _FloatingBubblesState extends State<FloatingBubbles> {
  late List<Bubble> bubbles;

  @override
  void initState() {
    super.initState();
    bubbles = List.generate(
      widget.bubbleCount,
      (index) => Bubble(
        size: 20 + math.Random().nextDouble() * 60,
        initialX: math.Random().nextDouble(),
        initialY: math.Random().nextDouble(),
        speed: 0.5 + math.Random().nextDouble() * 1.5,
        color: _getRandomBubbleColor(),
      ),
    );
  }

  Color _getRandomBubbleColor() {
    final colors = [
      Colors.blue.withOpacity(0.1),
      Colors.purple.withOpacity(0.1),
      Colors.pink.withOpacity(0.1),
      Colors.teal.withOpacity(0.1),
      Colors.indigo.withOpacity(0.1),
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: BubblePainter(
            bubbles: bubbles,
            animation: widget.controller.value,
          ),
        );
      },
    );
  }
}

class Bubble {
  final double size;
  final double initialX;
  final double initialY;
  final double speed;
  final Color color;

  Bubble({
    required this.size,
    required this.initialX,
    required this.initialY,
    required this.speed,
    required this.color,
  });
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final double animation;

  BubblePainter({
    required this.bubbles,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (var bubble in bubbles) {
      final x = bubble.initialX * size.width +
          math.sin(animation * 2 * math.pi * bubble.speed) * 50;
      final y = bubble.initialY * size.height +
          math.cos(animation * 2 * math.pi * bubble.speed) * 100;

      paint.color = bubble.color;
      canvas.drawCircle(
        Offset(x, y),
        bubble.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
