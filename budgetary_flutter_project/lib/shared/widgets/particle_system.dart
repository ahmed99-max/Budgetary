import 'package:flutter/material.dart';
import 'dart:math' as math;

class ParticleSystem extends StatefulWidget {
  final AnimationController controller;
  final int particleCount;

  const ParticleSystem({
    super.key,
    required this.controller,
    this.particleCount = 50,
  });

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<ParticleSystem> {
  late List<Particle> particles;

  @override
  void initState() {
    super.initState();
    particles = List.generate(
      widget.particleCount,
      (index) => Particle(
        x: math.Random().nextDouble(),
        y: math.Random().nextDouble(),
        size: 2 + math.Random().nextDouble() * 4,
        speed: 0.2 + math.Random().nextDouble() * 0.5,
        opacity: 0.2 + math.Random().nextDouble() * 0.3,
        color: _getRandomParticleColor(),
        direction: math.Random().nextDouble() * 2 * math.pi,
      ),
    );
  }

  Color _getRandomParticleColor() {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF4F46E5),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF3B82F6),
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
          painter: ParticlePainter(
            particles: particles,
            animation: widget.controller.value,
          ),
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;
  final Color color;
  final double direction;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
    required this.direction,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;

  ParticlePainter({
    required this.particles,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Update particle position
      particle.x += math.cos(particle.direction) * particle.speed * 0.01;
      particle.y += math.sin(particle.direction) * particle.speed * 0.01;

      // Wrap around screen
      if (particle.x > 1.1) particle.x = -0.1;
      if (particle.x < -0.1) particle.x = 1.1;
      if (particle.y > 1.1) particle.y = -0.1;
      if (particle.y < -0.1) particle.y = 1.1;

      // Add floating motion
      final floatX = particle.x * size.width + 
          math.sin(animation * 2 * math.pi + particle.x * 10) * 20;
      final floatY = particle.y * size.height + 
          math.cos(animation * 2 * math.pi + particle.y * 10) * 15;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      // Draw particle with glow effect
      canvas.drawCircle(
        Offset(floatX, floatY),
        particle.size,
        paint,
      );

      // Draw glow
      final glowPaint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(
        Offset(floatX, floatY),
        particle.size * 2,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
