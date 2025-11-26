import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viasolucoes/models/task.dart';

class TaskServiceSupabase {
  final supabase = Supabase.instance.client;

  // ============================================================
  // 🔵 LISTAR TODAS AS TAREFAS (para o Dashboard)
  // ============================================================
  Future<List<Task>> getAll() async {
    final response = await supabase
        .from('tbdTarefaContrato')
        .select('*')
        .order('criadoEm', ascending: true);

    return (response as List)
        .map((row) => Task.fromJson(_fromSupabase(row)))
        .toList();
  }

  // ============================================================
  // 🔵 LISTAR TODAS AS TAREFAS DE UM CONTRATO
  // ============================================================
  Future<List<Task>> getByContract(String contractId) async {
    final response = await supabase
        .from('tbdTarefaContrato')
        .select('*')
        .eq('idContrato', contractId)
        .order('criadoEm', ascending: true);

    return (response as List)
        .map((row) => Task.fromJson(_fromSupabase(row)))
        .toList();
  }

  // ============================================================
  // 🔵 BUSCAR TAREFA POR ID
  // ============================================================
  Future<Task?> getById(String id) async {
    final row = await supabase
        .from('tbdTarefaContrato')
        .select('*')
        .eq('idTarefaContrato', id)
        .maybeSingle();

    if (row == null) return null;

    return Task.fromJson(_fromSupabase(row));
  }

  // ============================================================
  // 🔵 CRIAR NOVA TAREFA
  // ============================================================
  Future<void> add(Task task) async {
    await supabase.from('tbdTarefaContrato').insert({
      'idTarefaContrato': task.id,
      'idContrato': task.contractId,
      'tituloTarefa': task.title,
      'descricaoTarefa': task.description,
      'concluida': task.isCompleted,
      'criadoEm': task.createdAt.toIso8601String(),
      'atualizadoEm': task.updatedAt.toIso8601String(),
    });

    await _updateContractProgress(task.contractId);
  }

  // ============================================================
  // 🔵 ATUALIZAR TAREFA
  // ============================================================
  Future<void> update(Task task) async {
    await supabase
        .from('tbdTarefaContrato')
        .update({
      'tituloTarefa': task.title,
      'descricaoTarefa': task.description,
      'concluida': task.isCompleted,
      'atualizadoEm': task.updatedAt.toIso8601String(),
    })
        .eq('idTarefaContrato', task.id);

    await _updateContractProgress(task.contractId);
  }

  // ============================================================
  // 🔵 DELETAR TAREFA
  // ============================================================
  Future<void> delete(String id, String contractId) async {
    await supabase
        .from('tbdTarefaContrato')
        .delete()
        .eq('idTarefaContrato', id);

    await _updateContractProgress(contractId);
  }

  // ============================================================
  // 🔁 ALTERNAR CONCLUIDA (true/false)
  // ============================================================
  Future<void> toggleCompleted(Task task) async {
    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now(),
    );

    await update(updated);
  }

  // ============================================================
  // 🔥 ATUALIZAR PROGRESSO DO CONTRATO
  // ============================================================
  Future<void> _updateContractProgress(String contractId) async {
    final tasks = await getByContract(contractId);

    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;

    final progress = total == 0 ? 0 : (completed / total) * 100;

    await supabase
        .from('tbdContrato')
        .update({
      'progressoPercentual': progress,
      'atualizadoEm': DateTime.now().toIso8601String(),
    })
        .eq('idContrato', contractId);
  }

  // ============================================================
  // 🧠 MAPEAR SUPABASE → Task.fromJson()
  // ============================================================
  Map<String, dynamic> _fromSupabase(Map<String, dynamic> row) {
    return {
      'id': row['idTarefaContrato'],
      'contractId': row['idContrato'],
      'title': row['tituloTarefa'],
      'description': row['descricaoTarefa'],
      'isCompleted': row['concluida'],
      'createdAt': row['criadoEm'],
      'updatedAt': row['atualizadoEm'],
    };
  }
}
