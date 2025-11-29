import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viasolucoes/models/contract.dart';

class ContractServiceSupabase {
  final supabase = Supabase.instance.client;

  // ============================================================
  // LISTAR TODOS
  // ============================================================
  Future<List<Contract>> getAll() async {
    final response = await supabase
        .from('tbdContrato')
        .select('*, tbdEmpresa(nomeEmpresa)')
        .order('dataFimContrato', ascending: true);

    return (response as List)
        .map((row) => Contract.fromJson(_fromSupabase(row)))
        .toList();
  }

  // ============================================================
  // LISTAR POR CLIENTE
  // ============================================================
  Future<List<Contract>> getByClient(String clientId) async {
    final response = await supabase
        .from('tbdContrato')
        .select('*, tbdEmpresa(nomeEmpresa)')
        .eq('idEmpresa', clientId)
        .order('dataFimContrato', ascending: true);

    return (response as List)
        .map((row) => Contract.fromJson(_fromSupabase(row)))
        .toList();
  }

  Future<List<Contract>> getByClientId(String clientId) =>
      getByClient(clientId);

  // ============================================================
  // BUSCAR POR ID
  // ============================================================
  Future<Contract?> getById(String id) async {
    final row = await supabase
        .from('tbdContrato')
        .select('*, tbdEmpresa(nomeEmpresa)')
        .eq('idContrato', id)
        .maybeSingle();

    if (row == null) return null;
    return Contract.fromJson(_fromSupabase(row));
  }

  // ============================================================
  // CRIAR CONTRATO
  // ============================================================
  Future<void> add(Contract contract) async {
    await supabase.from('tbdContrato').insert({
      'idContrato': contract.id,
      'idEmpresa': contract.clientId,
      'descricaoContrato': contract.description,
      'statusContrato': contract.status,
      'idUsuarioResponsavel': contract.assignedUserId,
      'dataInicioContrato': contract.startDate.toIso8601String(),
      'dataFimContrato': contract.endDate.toIso8601String(),
      'progressoPercentual': contract.progressPercentage,
      'criadoEm': contract.createdAt.toIso8601String(),
      'atualizadoEm': contract.updatedAt.toIso8601String(),

      'possuiArquivo': contract.hasFile,
      'nomeArquivo': contract.fileName,
      'urlArquivo': contract.fileUrl,
    });
  }

  // ============================================================
  // ATUALIZAR CONTRATO
  // ============================================================
  Future<void> update(Contract contract) async {
    await supabase.from('tbdContrato').update({
      'idEmpresa': contract.clientId,
      'descricaoContrato': contract.description,
      'statusContrato': contract.status,
      'idUsuarioResponsavel': contract.assignedUserId,
      'dataInicioContrato': contract.startDate.toIso8601String(),
      'dataFimContrato': contract.endDate.toIso8601String(),
      'progressoPercentual': contract.progressPercentage,
      'atualizadoEm': DateTime.now().toIso8601String(),

      'possuiArquivo': contract.hasFile,
      'nomeArquivo': contract.fileName,
      'urlArquivo': contract.fileUrl,
    }).eq('idContrato', contract.id);
  }

  // ============================================================
  // DELETAR
  // ============================================================
  Future<void> delete(String id) async {
    await supabase.from('tbdContrato').delete().eq('idContrato', id);
  }

  // ============================================================
  // 🔄 MAPEAR DADOS SUPABASE → MODEL
  // ============================================================
  Map<String, dynamic> _fromSupabase(Map<String, dynamic> row) {
    return {
      'id': row['idContrato'],
      'clientId': row['idEmpresa'],
      'clientName': row['tbdEmpresa']?['nomeEmpresa'] ?? '',
      'description': row['descricaoContrato'],
      'status': row['statusContrato'],
      'assignedUserId': row['idUsuarioResponsavel'],

      // Aqui são STRINGS — mas Contract.fromJson aceita DateTime OU String
      'startDate': row['dataInicioContrato'],
      'endDate': row['dataFimContrato'],
      'createdAt': row['criadoEm'],
      'updatedAt': row['atualizadoEm'],

      'progressPercentage': row['progressoPercentual'] ?? 0,

      'hasFile': row['possuiArquivo'] ?? false,
      'fileName': row['nomeArquivo'],
      'fileUrl': row['urlArquivo'],
    };
  }

  // ============================================================
  // STATS PARA DASHBOARD
  // ============================================================
  Future<Map<String, int>> getStats() async {
    final contracts = await getAll();
    final now = DateTime.now();

    int active = 0;
    int overdue = 0;
    int completed = 0;

    for (final c in contracts) {
      final bool isCompleted = c.progressPercentage >= 100;
      final bool isOverdue = now.isAfter(c.endDate) && !isCompleted;

      if (isCompleted) {
        completed++;
      } else if (isOverdue) {
        overdue++;
      } else {
        active++;
      }
    }

    return {
      'active': active,
      'overdue': overdue,
      'completed': completed,
    };
  }
}
