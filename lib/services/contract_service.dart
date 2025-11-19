import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:viasolucoes/models/contract.dart';

class ContractService {
  static const String _fileName = 'contracts.json';
  final _uuid = const Uuid();

  /// Obtém o arquivo físico onde será salvo o JSON
  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// Carrega todos os contratos
  Future<List<Contract>> getAll() async {
    try {
      final file = await _getLocalFile();

      if (!await file.exists()) return [];

      final content = await file.readAsString();

      if (content.trim().isEmpty) return [];

      final decoded = jsonDecode(content);

      if (decoded is! List) return [];

      return decoded
          .map<Contract>((json) => Contract.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Erro ao carregar contratos: $e');
      return [];
    }
  }

  /// Salva toda a lista no arquivo
  Future<void> _saveAll(List<Contract> contracts) async {
    final file = await _getLocalFile();
    final jsonContent =
    jsonEncode(contracts.map((c) => c.toJson()).toList());
    await file.writeAsString(jsonContent);
  }

  /// Adiciona um novo contrato
  Future<void> add(Contract contract) async {
    final all = await getAll();
    all.add(contract);
    await _saveAll(all);
  }

  /// Busca contrato por ID
  Future<Contract?> getById(String id) async {
    final all = await getAll();
    return all.where((c) => c.id == id).cast<Contract?>().firstOrNull;
  }

  /// Busca contratos por cliente
  Future<List<Contract>> getByClient(String clientId) async {
    final all = await getAll();
    return all.where((c) => c.clientId == clientId).toList();
  }

  /// Atualiza contrato preservando fileUrl/fileName/hasFile
  Future<void> update(Contract updated) async {
    final all = await getAll();
    final index = all.indexWhere((c) => c.id == updated.id);

    if (index != -1) {
      all[index] = updated.copyWith(updatedAt: DateTime.now());
      await _saveAll(all);
    } else {
      print("⚠ Tentativa de atualizar contrato inexistente: ${updated.id}");
    }
  }

  /// Retorna quantidade de contratos por status
  Future<Map<String, int>> getStats() async {
    final all = await getAll();

    return {
      'active': all.where((c) => c.status == 'active').length,
      'overdue': all.where((c) => c.status == 'overdue').length,
      'completed': all.where((c) => c.status == 'completed').length,
    };
  }

  /// Remove um contrato
  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((c) => c.id == id);
    await _saveAll(all);
  }

  /// Inicializa dados de exemplo se não existir arquivo
  Future<void> initializeSampleData() async {
    final file = await _getLocalFile();
    if (await file.exists()) return;

    final now = DateTime.now();

    final sample = Contract(
      id: _uuid.v4(),
      clientId: '1',
      clientName: 'Cliente Exemplo',
      description: 'Contrato de exemplo um',
      status: 'active',
      assignedUserId: 'user1',
      startDate: now.subtract(const Duration(days: 10)),
      endDate: now.add(const Duration(days: 30)),
      progressPercentage: 0,
      createdAt: now,
      updatedAt: now,
      fileUrl: null,
      fileName: null,
      hasFile: false,
    );

    await add(sample);
  }
}

extension FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}