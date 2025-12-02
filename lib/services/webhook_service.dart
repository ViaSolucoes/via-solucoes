import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:viasolucoes/env/env.dart';

class WebhookService {
  final String endpoint = AppEnv.webhookUrl;

  Future<void> send(Map<String, dynamic> payload) async {
    if (endpoint.isEmpty) {
      print("⚠️ Nenhum WEBHOOK_URL configurado");
      return;
    }

    try {
      await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );
      print("📤 Webhook enviado: ${payload['event']}");
    } catch (e) {
      print("❌ Erro ao enviar webhook: $e");
    }
  }
}
