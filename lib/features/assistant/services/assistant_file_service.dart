import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:viasolucoes/env/env.dart';

class AssistantFileService {
  static const _uploadUrl = "https://api.openai.com/v1/files";
  static const _chatUrl = "https://api.openai.com/v1/chat/completions";

  /// 1) Upload do arquivo → retorna file_id
  Future<String?> uploadFile(File file) async {
    final request = http.MultipartRequest("POST", Uri.parse(_uploadUrl))
      ..headers["Authorization"] = "Bearer ${AppEnv.openAIKey}"
      ..fields["purpose"] = "assistants"
      ..files.add(await http.MultipartFile.fromPath("file", file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      print("❌ ERRO UPLOAD: $body");
      return null;
    }

    final json = jsonDecode(body);
    return json["id"];
  }

  /// 2) Envia file_id para o GPT gerar um resumo profissional
  Future<String> summarize(File file) async {
    final fileId = await uploadFile(file);
    if (fileId == null) return "";

    final body = {
      "model": "gpt-4.1-mini",
      "temperature": 0.2,
      "messages": [
        {
          "role": "system",
          "content":
          "Você é um especialista em análise de contratos. Gere um resumo de até 4 linhas, direto, claro e profissional."
        },
        {
          "role": "user",
          "content": [
            {
              "type": "file",
              "file": {
                "file_id": fileId
              }
            }
          ]
        }
      ]
    };

    final resp = await http.post(
      Uri.parse(_chatUrl),
      headers: {
        "Authorization": "Bearer ${AppEnv.openAIKey}",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200) {
      print("❌ ERRO AO ANALISAR CONTRATO: ${resp.body}");
      return "";
    }

    final json = jsonDecode(resp.body);
    return json["choices"][0]["message"]["content"];
  }
}
