import '../services/log_service.dart';

class LogHelper {
  final LogService _logService = LogService();

  Future<void> registerAction({
    required String contractId,
    required String action,
    required String description,
  }) async {
    try {
      await _logService.add(
        contractId: contractId,
        action: action,
        description: description,
      );
    } catch (e) {
      print('⚠️ Erro ao registrar log: $e');
    }
  }
}
