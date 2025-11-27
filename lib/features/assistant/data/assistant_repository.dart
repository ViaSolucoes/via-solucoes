import 'assistant_knowledge_base.dart';

class AssistantRepository {
  /// Carrega a base de conhecimento estática do app
  Future<String> loadKnowledgeBase() async {
    // Se no futuro quiser buscar do Supabase ou remoto, é aqui que muda.
    return assistantKnowledgeBase;
  }

  /// (Opcional futuro) salvar histórico da conversa no Supabase
  Future<void> saveConversationMessage({
    required String sender,
    required String text,
  }) async {
    // Implementar futuramente se quiser persistir no banco
  }
}
