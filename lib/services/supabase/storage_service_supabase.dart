import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageServiceSupabase {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Nome do bucket no Supabase Storage
  /// 👉 Crie esse bucket no painel do Supabase: "contract-files"
  static const String _bucketName = 'contract-files';

  // ============================================================
  // 🔵 UPLOAD DE ARQUIVO DE CONTRATO (PDF / DOC / DOCX)
  // ============================================================
  ///
  /// [contractId] = id do contrato (idContrato)
  /// [file]       = arquivo físico selecionado no app (File)
  ///
  /// Retorna a URL pública do arquivo (para exibir/abrir no app).
  ///
  Future<String?> uploadContractFile({
    required String contractId,
    required File file,
  }) async {
    try {
      // Nome original do arquivo
      final originalName = file.path.split('/').last;

      // Caminho interno no bucket: ex: contracts/<idContrato>/timestamp_nome.pdf
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final objectPath = 'contracts/$contractId/${timestamp}_$originalName';

      // Faz upload para o Storage
      await supabase.storage.from(_bucketName).upload(objectPath, file);

      // Gera URL pública
      final publicUrl =
      supabase.storage.from(_bucketName).getPublicUrl(objectPath);

      // Atualiza o registro do contrato na tabela tbdContrato
      await supabase
          .from('tbdContrato')
          .update({
        'possuiArquivo': true,
        'nomeArquivo': originalName,
        'urlArquivo': publicUrl,
        'atualizadoEm': DateTime.now().toIso8601String(),
      })
          .eq('idContrato', contractId);

      return publicUrl;
    } on StorageException catch (e) {
      print('❌ Erro de Storage Supabase ao fazer upload: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Erro inesperado ao fazer upload de arquivo: $e');
      rethrow;
    }
  }

  // ============================================================
  // 🔵 REMOVER METADADOS DO ARQUIVO NO CONTRATO
  // (opcionalmente tenta remover também do Storage)
  // ============================================================
  ///
  /// Limpa as informações de arquivo da tabela tbdContrato:
  ///  - possuiArquivo = false
  ///  - nomeArquivo   = null
  ///  - urlArquivo    = null
  ///
  /// Tenta também remover o arquivo do Storage com base na URL.
  ///
  Future<void> removeContractFile(String contractId, {String? currentFileUrl}) async {
    try {
      // Primeiro tentamos remover do Storage (se tivermos a URL)
      if (currentFileUrl != null && currentFileUrl.isNotEmpty) {
        final storagePath = _extractPathFromPublicUrl(currentFileUrl);
        if (storagePath != null) {
          await supabase.storage.from(_bucketName).remove([storagePath]);
        }
      }

      // Depois limpamos os campos na tbdContrato
      await supabase
          .from('tbdContrato')
          .update({
        'possuiArquivo': false,
        'nomeArquivo': null,
        'urlArquivo': null,
        'atualizadoEm': DateTime.now().toIso8601String(),
      })
          .eq('idContrato', contractId);
    } on StorageException catch (e) {
      print('⚠️ Erro de Storage ao remover arquivo: ${e.message}');
      // Mesmo que dê erro para remover do Storage,
      // a parte de limpar o contrato no banco já foi feita.
    } catch (e) {
      print('⚠️ Erro inesperado ao remover arquivo: $e');
    }
  }

  // ============================================================
  // 🧠 Função auxiliar: extrai o path interno do Storage a partir da URL pública
  // ============================================================
  ///
  /// A URL pública padrão do Supabase tem esse formato:
  ///  https://<project>.supabase.co/storage/v1/object/public/<bucket>/<path>
  ///
  /// Exemplo:
  ///  https://xyz.supabase.co/storage/v1/object/public/contract-files/contracts/123/arquivo.pdf
  ///
  /// Queremos extrair apenas:
  ///  contracts/123/arquivo.pdf
  ///
  String? _extractPathFromPublicUrl(String url) {
    try {
      final uri = Uri.parse(url);
      const marker = '/object/public/';
      final index = uri.path.indexOf(marker);
      if (index == -1) return null;

      final after = uri.path.substring(index + marker.length); // "<bucket>/<path>"
      final parts = after.split('/');
      if (parts.length < 2) return null;

      // parts[0] = bucket ("contract-files")
      // o restante é o path real do objeto
      final objectPath = parts.sublist(1).join('/');
      return objectPath;
    } catch (e) {
      print('⚠️ Falha ao extrair path da URL pública: $e');
      return null;
    }
  }
}
