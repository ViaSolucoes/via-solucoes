import 'assistant_message.dart';

class AssistantState {
  final List<AssistantMessage> messages;
  final bool isLoading;

  const AssistantState({
    required this.messages,
    this.isLoading = false,
  });

  factory AssistantState.initial() {
    return const AssistantState(
      messages: [],
      isLoading: false,
    );
  }

  AssistantState copyWith({
    List<AssistantMessage>? messages,
    bool? isLoading,
  }) {
    return AssistantState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
