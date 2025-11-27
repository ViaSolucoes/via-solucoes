import 'package:flutter/material.dart';
import 'assistant_chat_screen.dart';

void showAssistantModal(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Fechar assistente", // ✅ OBRIGATÓRIO
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) => const SizedBox(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);

      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
          child: const _AssistantModalCard(),
        ),
      );
    },
  );
}


class _AssistantModalCard extends StatelessWidget {
  const _AssistantModalCard();

  @override
  Widget build(BuildContext context) {
    final controller = ScrollController();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.94),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                // 🔹 Tela do Assistente
                AssistantChatScreen(
                  scrollController: controller,
                ),

                // 🔹 Botão de Fechar (Novo!)
                Positioned(
                  right: 12,
                  top: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 12,
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 22,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
