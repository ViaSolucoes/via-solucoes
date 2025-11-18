import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:viasolucoes/models/contract.dart';

class ContractService {
  static const String _fileName = 'contracts.json';
  final _uuid = const Uuid();

  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<Contract>> getAll() async {
    try {
      final file = await _getLocalFile();

      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];

      final data = jsonDecode(content);
      if (data is! List) return [];

      return data
          .map<Contract>((json) => Contract.fromJson(json))
          .toList();
    } catch (e) {
      // Evita quebrar o app por erro de leitura
      print('Erro ao carregar contratos: $e');
      return [];
    }
  }

  Future<void> _saveAll(List<Contract> contracts) async {
    final file = await _getLocalFile();
    final jsonContent =
    jsonEncode(contracts.map((c) => c.toJson()).toList());
    await file.writeAsString(jsonContent);
  }

  /// Adiciona um novo contrato à lista
  Future<void> add(Contract contract) async {
    final all = await getAll();
    all.add(contract);
    await _saveAll(all);
  }

  Future<Contract?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Contract>> getByClient(String clientId) async {
    final all = await getAll();
    return all.where((c) => c.clientId == clientId).toList();
  }

  Future<void> update(Contract updated) async {
    final all = await getAll();
    final index = all.indexWhere((c) => c.id == updated.id);

    if (index != -1) {
      all[index] = updated.copyWith(updatedAt: DateTime.now());
      await _saveAll(all);
    }
  }

  Future<Map<String, int>> getStats() async {
    final all = await getAll();

    return {
      'active': all.where((c) => c.status == 'active').length,
      'overdue': all.where((c) => c.status == 'overdue').length,
      'completed': all.where((c) => c.status == 'completed').length,
    };
  }

  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((c) => c.id == id);
    await _saveAll(all);
  }

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
