class AssistantMessage {
  final String sender; // "user" ou "assistant"
  final String text;

  AssistantMessage({
    required this.sender,
    required this.text,
  });

  // 🔹 Getter que o chat usa
  bool get isUser => sender == "user";

  // 🔹 Construtor para msg do usuário
  factory AssistantMessage.user(String text) {
    return AssistantMessage(sender: "user", text: text);
  }

  // 🔹 Construtor para msg do assistente
  factory AssistantMessage.assistant(String text) {
    return AssistantMessage(sender: "assistant", text: text);
  }
}
