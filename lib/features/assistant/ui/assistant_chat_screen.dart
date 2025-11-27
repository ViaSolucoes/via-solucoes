import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/assistant_avatar.dart';

// Providers e estados
import '../domain/assistant_provider.dart';
import '../domain/assistant_message.dart';

// UI widgets
import 'widgets/message_bubble.dart';
import 'widgets/typing_indicator.dart';
import 'widgets/glass_background.dart';

class AssistantChatScreen extends ConsumerWidget {
  final ScrollController scrollController;

  const AssistantChatScreen({
    super.key,
    required this.scrollController,
  });

  // -----------------------------
  // AUTO SCROLL
  // -----------------------------
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assistantProvider);
    final controller = ref.read(assistantProvider.notifier);

    // Scroll automático sempre que mensagens mudarem
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return GlassBackground(
      child: Column(
        children: [
          // -----------------------------
          // CABEÇALHO
          // -----------------------------
          const SizedBox(height: 8),
          const AssistantAvatar(),
          const SizedBox(height: 6),
          const Text(
            "Assistente Via Soluções",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Divider(height: 1),

          Divider(height: 1, thickness: 0.8, color: Colors.black12),

          // -----------------------------
          // LISTA DE MENSAGENS
          // -----------------------------
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              itemCount: state.messages.length + (state.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < state.messages.length) {
                  final msg = state.messages[index];
                  return MessageBubble(message: msg);
                } else {
                  return const AssistantTypingIndicator();
                }
              },
            ),
          ),

          // -----------------------------
          // INPUT DE MENSAGEM
          // -----------------------------
          _buildInputField(context, controller),
        ],
      ),
    );
  }

  // ===========================================================
  // INPUT FIELD — Moderno + Glass Effect
  // ===========================================================
  Widget _buildInputField(BuildContext context, controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.45),
        border: const Border(
          top: BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.textController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: "Digite sua pergunta...",
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.white.withOpacity(0.7),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (text) {
                controller.sendMessage(text);
              },
            ),
          ),
          const SizedBox(width: 8),
          // Botão de enviar
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(18),
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: () {
                final text = controller.textController.text.trim();
                if (text.isNotEmpty) controller.sendMessage(text);
              },
            ),
          ),
        ],
      ),
    );
  }
}
