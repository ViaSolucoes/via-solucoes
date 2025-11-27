import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class GlassBackground extends StatefulWidget {
  final Widget child;

  const GlassBackground({super.key, required this.child});

  @override
  State<GlassBackground> createState() => _GlassBackgroundState();
}

class _GlassBackgroundState extends State<GlassBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final Random _random = Random();

  final int particleCount = 18;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _randomOffset(Size size, double seed) {
    final dx = (sin(seed + _controller.value * 2 * pi) + 1) / 2;
    final dy = (cos(seed + _controller.value * 2 * pi) + 1) / 2;
    return Offset(dx * size.width, dy * size.height * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: Stack(
        children: [
          // Glass blur effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              color: Colors.white.withOpacity(0.25),
            ),
          ),

          // Particles
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: List.generate(particleCount, (i) {
                      final seed = i * 0.6;
                      final pos = _randomOffset(constraints.biggest, seed);

                      return Positioned(
                        left: pos.dx,
                        top: pos.dy,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                  );
                },
              );
            },
          ),

          // Content
          widget.child,
        ],
      ),
    );
  }
}
