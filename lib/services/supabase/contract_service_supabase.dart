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

  Future<List<Contract>> getByClientId(String clientId) => getByClient(clientId);

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
  // CRIAR CONTRATO  ✅ AGORA SALVA O ARQUIVO
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

      // 🔵 CAMPOS QUE FALTAVAM
      'possuiArquivo': contract.hasFile,
      'nomeArquivo': contract.fileName,
      'urlArquivo': contract.fileUrl,
    });
  }


  // ============================================================
  // ATUALIZAR CONTRATO  ✅ TAMBÉM ATUALIZA ARQUIVO
  // ============================================================
  Future<void> update(Contract contract) async {
    await supabase
        .from('tbdContrato')
        .update({
      'idEmpresa': contract.clientId,
      'descricaoContrato': contract.description,
      'statusContrato': contract.status,
      'idUsuarioResponsavel': contract.assignedUserId,
      'dataInicioContrato': contract.startDate.toIso8601String(),
      'dataFimContrato': contract.endDate.toIso8601String(),
      'progressoPercentual': contract.progressPercentage,
      'atualizadoEm': DateTime.now().toIso8601String(),

      // 🔵 CAMPOS NOVOS
      'possuiArquivo': contract.hasFile,
      'nomeArquivo': contract.fileName,
      'urlArquivo': contract.fileUrl,
    })
        .eq('idContrato', contract.id);
  }


  // ============================================================
  // DELETAR
  // ============================================================
  Future<void> delete(String id) async {
    await supabase.from('tbdContrato').delete().eq('idContrato', id);
  }

  // ============================================================
  // 🔄 MAPEAR DADOS DO SUPABASE → MODEL
  // ============================================================
  Map<String, dynamic> _fromSupabase(Map<String, dynamic> row) {
    return {
      'id': row['idContrato'],
      'clientId': row['idEmpresa'],
      'clientName': row['tbdEmpresa']?['nomeEmpresa'] ?? '',
      'description': row['descricaoContrato'],
      'status': row['statusContrato'],
      'assignedUserId': row['idUsuarioResponsavel'],
      'startDate': row['dataInicioContrato'],
      'endDate': row['dataFimContrato'],
      'progressPercentage': row['progressoPercentual'] ?? 0,
      'createdAt': row['criadoEm'],
      'updatedAt': row['atualizadoEm'],

      // 🟦 CAMPOS DO ARQUIVO
      'hasFile': row['possuiArquivo'] ?? false,
      'fileName': row['nomeArquivo'],
      'fileUrl': row['urlArquivo'],
    };
  }

  // ============================================================
// 🔵 STATS PARA O DASHBOARD
// ============================================================
  Future<Map<String, int>> getStats() async {
    final response = await supabase
        .from('tbdContrato')
        .select('statusContrato');

    int active = 0;
    int overdue = 0;
    int completed = 0;

    for (final row in (response as List)) {
      final status = (row['statusContrato'] ?? '').toString();
      switch (status) {
        case 'active':
          active++;
          break;
        case 'overdue':
          overdue++;
          break;
        case 'completed':
          completed++;
          break;
      }
    }

    return {
      'active': active,
      'overdue': overdue,
      'completed': completed,
    };
  }

}


