import 'dart:convert';
import 'package:http/http.dart' as http;
import 'assistant_repository.dart';
import 'package:viasolucoes/env/env.dart';

class AssistantService {
  final AssistantRepository _repository;

  AssistantService(this._repository);

  static const _openAIUrl = "https://api.openai.com/v1/chat/completions";

  /// Gera resposta real usando OpenAI já formatada para o chat
  Future<String> generateReply(String userMessage) async {
    final knowledgeBase = await _repository.loadKnowledgeBase();

    final body = {
      "model": "gpt-4.1-mini",
      "temperature": 0.35,
      "messages": [
        {
          "role": "system",
          "content": """
Você é o Assistente Oficial do sistema Via Soluções.

⚠️ IMPORTANTE — FORMATO DAS RESPOSTAS:
- Nunca use markdown bruto (*, **, ###, ---).
- Nunca use textos gigantes ou parágrafos longos demais.
- Use frases curtas, claras e diretas.
- Quebre o texto em parágrafos curtos.
- Use listas com o bullet '•' (ex.: • item da lista).
- Pode usar emojis com moderação (💡📌⚠️✨) quando ajudarem na clareza.
- Responda sempre de forma profissional, moderna e organizada.
- Nunca invente telas ou recursos que não existem.
- Sempre leve em consideração o CONTEXTO completo abaixo:

===== CONTEXTO DO SISTEMA =====
$knowledgeBase
===== FIM DO CONTEXTO =====
"""
        },
        {
          "role": "user",
          "content": userMessage
        }
      ]
    };

    final response = await http.post(
      Uri.parse(_openAIUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${AppEnv.openAIKey}"
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      print("❌ ERRO OPENAI: ${response.body}");
      return "Houve um erro ao processar sua solicitação. Tente novamente.";
    }

    final data = jsonDecode(response.body);

    return data["choices"][0]["message"]["content"].toString();
  }
}
