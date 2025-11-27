import 'package:flutter/material.dart';

class AssistantFAB extends StatelessWidget {
  final VoidCallback onTap;

  const AssistantFAB({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4FACFE), // azul neon
              Color(0xFF00F2FE), // ciano neon
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            // glow neon
            BoxShadow(
              color: const Color(0xFF00E5FF).withOpacity(0.7),
              blurRadius: 25,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(0xFF4FACFE).withOpacity(0.4),
              blurRadius: 35,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Center(
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.25),
            ),
            child: const Icon(
              Icons.forum_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
