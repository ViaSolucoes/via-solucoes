import 'package:flutter/material.dart';
import '../../domain/assistant_message.dart';

class MessageBubble extends StatefulWidget {
  final AssistantMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    // Controlador de animação
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Opacidade suave
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Slide de leve para cima
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Iniciar animação ao entrar na tela
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.isUser;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Align(
          alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: isUser
                ? _buildUserBubble(context)
                : _buildAssistantAnimatedBubble(context),
          ),
        ),
      ),
    );
  }

  // ===========================================================
  //  BALÃO DO USUÁRIO
  // ===========================================================
  Widget _buildUserBubble(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        widget.message.text,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
    );
  }

  // ===========================================================
  //  BALÃO DO ASSISTENTE COM BORDA ANIMADA
  // ===========================================================
  Widget _buildAssistantAnimatedBubble(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade300.withOpacity(0.6),
            Colors.blue.shade100.withOpacity(0.3),
            Colors.purple.shade200.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          widget.message.text,
          style: const TextStyle(
            fontSize: 15,
            height: 1.35,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
