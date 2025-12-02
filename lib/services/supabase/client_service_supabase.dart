import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viasolucoes/models/client.dart';

class ClientServiceSupabase {
  final supabase = Supabase.instance.client;

  // =====================================================
  // 🔵 LISTAR TODOS OS CLIENTES
  // =====================================================
  Future<List<Client>> getAll() async {
    final response = await supabase
        .from('tbdEmpresa')
        .select('*, tbdResponsavelEmpresa(*)')
        .order('nomeEmpresa', ascending: true);

    return (response as List).map((row) {
      return Client.fromJson(_fromSupabase(row));
    }).toList();
  }

  // =====================================================
  // 🔵 BUSCAR CLIENTE POR ID
  // =====================================================
  Future<Client?> getById(String id) async {
    final response = await supabase
        .from('tbdEmpresa')
        .select('*, tbdResponsavelEmpresa(*)')
        .eq('idEmpresa', id)
        .maybeSingle();

    if (response == null) return null;

    return Client.fromJson(_fromSupabase(response));
  }

  // =====================================================
  // 🔵 ADICIONAR CLIENTE
  // =====================================================
  Future<void> add(Client client) async {
    // 1️⃣ Criar empresa
    await supabase.from('tbdEmpresa').insert({
      'idEmpresa': client.id,
      'nomeEmpresa': client.companyName,
      'rodoviaEmpresa': client.highway,
      'cnpjEmpresa': client.cnpj,
      'enderecoEmpresa': client.address,
      'setorEmpresa': client.department,
      'observacoesEmpresa': client.notes,
      'ativoEmpresa': client.isActive, 
      'criadoEm': client.createdAt.toIso8601String(),
      'atualizadoEm': client.updatedAt.toIso8601String(),
    });

    // 2️⃣ Criar responsável
    await supabase.from('tbdResponsavelEmpresa').insert({
      'idEmpresa': client.id,
      'nomeResponsavel': client.contactPerson,
      'cargoResponsavel': client.contactRole,
      'emailResponsavel': client.email,
      'telefoneResponsavel': client.phone,
      'criadoEm': client.createdAt.toIso8601String(),
      'atualizadoEm': client.updatedAt.toIso8601String(),
    });
  }

  // =====================================================
  // 🔵 ATUALIZAR CLIENTE
  // =====================================================
  Future<void> update(Client client) async {
    // 1️⃣ Atualizar empresa
    await supabase
        .from('tbdEmpresa')
        .update({
          'nomeEmpresa': client.companyName,
          'rodoviaEmpresa': client.highway,
          'cnpjEmpresa': client.cnpj,
          'enderecoEmpresa': client.address,
          'setorEmpresa': client.department,
          'observacoesEmpresa': client.notes,
          'ativoEmpresa': client.isActive, 
          'atualizadoEm': DateTime.now().toIso8601String(),
        })
        .eq('idEmpresa', client.id);

    // 2️⃣ Atualizar responsável
    await supabase
        .from('tbdResponsavelEmpresa')
        .update({
          'nomeResponsavel': client.contactPerson,
          'cargoResponsavel': client.contactRole,
          'emailResponsavel': client.email,
          'telefoneResponsavel': client.phone,
          'atualizadoEm': DateTime.now().toIso8601String(),
        })
        .eq('idEmpresa', client.id);
  }

  // =====================================================
  // 🔵 ALTERAR APENAS STATUS (ATIVO / DESATIVADO)
  // =====================================================
  Future<void> updateClientStatus(String clientId, bool isActive) async {
    await supabase
        .from('tbdEmpresa')
        .update({
          'ativoEmpresa': isActive,
          'atualizadoEm': DateTime.now().toIso8601String(),
        })
        .eq('idEmpresa', clientId);
  }

  // =====================================================
  // 🔵 DELETAR CLIENTE
  // =====================================================
  Future<void> delete(String id) async {
    try {
      await supabase.from("tbdEmpresa").delete().eq("idEmpresa", id);
    } catch (e) {
      final errorMessage = e.toString();

      if (errorMessage.contains("fk_contrato_empresa")) {
        throw Exception(
            "Não é possível excluir este cliente, pois existem contratos vinculados a ele.");
      }

      throw Exception("Erro ao excluir cliente: $e");
    }
  }

  // =====================================================
  // 🧠 MAPEAR SUPABASE → Client.fromJson()
  // =====================================================
  Map<String, dynamic> _fromSupabase(Map<String, dynamic> row) {
    final resp = (row['tbdResponsavelEmpresa'] as List?)?.first;

    return {
      'id': row['idEmpresa'],
      'companyName': row['nomeEmpresa'],
      'highway': row['rodoviaEmpresa'],
      'cnpj': row['cnpjEmpresa'],
      'address': row['enderecoEmpresa'],
      'department': row['setorEmpresa'],
      'notes': row['observacoesEmpresa'],
      'createdAt': row['criadoEm'],
      'updatedAt': row['atualizadoEm'],
      'isActive': row['ativoEmpresa'], 
      'contactPerson': resp?['nomeResponsavel'],
      'contactRole': resp?['cargoResponsavel'],
      'email': resp?['emailResponsavel'],
      'phone': resp?['telefoneResponsavel'],
    };
  }
}
