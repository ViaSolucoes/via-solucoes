import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'assistant_state.dart';
import 'assistant_message.dart';
import '../data/assistant_repository.dart';
import '../data/assistant_service.dart';

/// Provider do repositório
final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  return AssistantRepository();
});

/// Provider do serviço de IA
final assistantServiceProvider = Provider<AssistantService>((ref) {
  final repo = ref.read(assistantRepositoryProvider);
  return AssistantService(repo);
});

/// Provider do estado do assistente
final assistantProvider =
StateNotifierProvider<AssistantNotifier, AssistantState>(
      (ref) {
    final service = ref.read(assistantServiceProvider);
    return AssistantNotifier(service);
  },
);

class AssistantNotifier extends StateNotifier<AssistantState> {
  final AssistantService _service;

  /// 🟦 IMPORTANTE → controller gerenciado pelo Provider
  final TextEditingController textController = TextEditingController();

  AssistantNotifier(this._service) : super(AssistantState.initial());

  /// Envia mensagem
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    textController.clear();

    // Mensagem do usuário
    final userMessage = AssistantMessage.user(trimmed);
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    // Gerar resposta
    final reply = await _service.generateReply(trimmed);

    final assistantMsg = AssistantMessage.assistant(reply);
    state = state.copyWith(
      messages: [...state.messages, assistantMsg],
      isLoading: false,
    );
  }

  /// Limpa tudo
  void clear() {
    textController.clear();
    state = AssistantState.initial();
  }
}
