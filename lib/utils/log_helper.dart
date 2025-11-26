import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viasolucoes/services/log_service.dart';
import 'package:viasolucoes/models/log_entry.dart';

class LogHelper {
  final LogService _logService = LogService();

  /// Identifica o usuário autenticado
  String get _currentUserId {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.id ?? "unknown";
  }

  /// Registro genérico de log, compatível com o novo sistema
  Future<void> registerAction({
    required LogModule module,
    required LogAction action,
    required String entityType,
    String? entityId,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _logService.add(
        module: module,
        action: action,
        entityType: entityType,
        entityId: entityId,
        description: description,
        userId: _currentUserId,
        metadata: metadata,
      );
    } catch (e) {
      print("⚠️ Erro ao registrar log: $e");
    }
  }
}
