import 'dart:ui';
import 'package:flutter/material.dart';

class AssistantAvatar extends StatefulWidget {
  const AssistantAvatar({super.key});

  @override
  State<AssistantAvatar> createState() => _AssistantAvatarState();
}

class _AssistantAvatarState extends State<AssistantAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 85,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;

          return Stack(
            alignment: Alignment.center,
            children: [
              // 🔵 Blur Glow principal
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.blueAccent.withOpacity(0.55),
                      Colors.blueAccent.withOpacity(0.10),
                      Colors.transparent,
                    ],
                    stops: const [0.2, 0.6, 1],
                  ),
                ),
              ),

              // 🔵 Anéis pulsantes
              Transform.scale(
                scale: 1 + (t * 0.15),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blueAccent.withOpacity(0.25),
                      width: 2,
                    ),
                  ),
                ),
              ),

              // 🔷 Orb central flutuante
              Transform.translate(
                offset: Offset(
                  4 * (t * 2 - 1),
                  3 * (1 - t * 2),
                ),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB6D9FF), Color(0xFF5C9BFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.55),
                        blurRadius: 18,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                ),
              ),

              // ✨ Reflexo suave
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.02),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
