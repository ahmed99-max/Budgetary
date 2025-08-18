import 'package:flutter/material.dart';

/// Wrap any widget to have an animated fade from 0→[opacity].
class FadeWrapper extends StatelessWidget {
  const FadeWrapper({
    super.key,
    required this.child,
    this.opacity = 1.0,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
  });

  final Widget child;
  final double opacity;
  final Duration duration;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: opacity),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (_, value, child) => Opacity(opacity: value, child: child),
      child: child,
    );
  }
}
