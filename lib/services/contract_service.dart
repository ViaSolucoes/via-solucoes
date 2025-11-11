import 'package:viasolucoes/models/contract.dart';
import 'package:viasolucoes/services/storage_service.dart';

class ContractService {
  final StorageService _storage = StorageService();

  Future<void> initializeSampleData() async {
    final contracts = await getAll();
    if (contracts.isEmpty) {
      final now = DateTime.now();
      final sampleContracts = [
        Contract(
          id: 'contract-1',
          clientName: 'Concessionária ViaOeste',
          description: 'Manutenção BR-101 Trecho Sul',
          status: 'active',
          assignedUserId: 'user-1',
          startDate: now.subtract(const Duration(days: 60)),
          endDate: now.add(const Duration(days: 30)),
          progressPercentage: 65.0,
          createdAt: now.subtract(const Duration(days: 60)),
          updatedAt: now,
        ),
        Contract(
          id: 'contract-2',
          clientName: 'Rodovias SP',
          description: 'Sinalização Viária - Rodovia Anhanguera',
          status: 'active',
          assignedUserId: 'user-2',
          startDate: now.subtract(const Duration(days: 45)),
          endDate: now.add(const Duration(days: 2)),
          progressPercentage: 88.0,
          createdAt: now.subtract(const Duration(days: 45)),
          updatedAt: now,
        ),
        Contract(
          id: 'contract-3',
          clientName: 'CCR RodoAnel',
          description: 'Pavimentação e Recapeamento',
          status: 'overdue',
          assignedUserId: 'user-1',
          startDate: now.subtract(const Duration(days: 90)),
          endDate: now.subtract(const Duration(days: 5)),
          progressPercentage: 92.0,
          createdAt: now.subtract(const Duration(days: 90)),
          updatedAt: now.subtract(const Duration(days: 3)),
        ),
        Contract(
          id: 'contract-4',
          clientName: 'AutoBan',
          description: 'Instalação de Passarelas - Via Dutra',
          status: 'completed',
          assignedUserId: 'user-3',
          startDate: now.subtract(const Duration(days: 120)),
          endDate: now.subtract(const Duration(days: 15)),
          progressPercentage: 100.0,
          createdAt: now.subtract(const Duration(days: 120)),
          updatedAt: now.subtract(const Duration(days: 15)),
        ),
        Contract(
          id: 'contract-5',
          clientName: 'EcoRodovias',
          description: 'Drenagem e Contenção de Encostas',
          status: 'active',
          assignedUserId: 'user-2',
          startDate: now.subtract(const Duration(days: 20)),
          endDate: now.add(const Duration(days: 70)),
          progressPercentage: 25.0,
          createdAt: now.subtract(const Duration(days: 20)),
          updatedAt: now,
        ),
      ];
      await _storage.saveData(
        _storage.contractsKey,
        sampleContracts.map((c) => c.toJson()).toList(),
      );
    }
  }

  Future<List<Contract>> getAll() async {
    final data = await _storage.loadData(_storage.contractsKey);
    return data.map((json) => Contract.fromJson(json)).toList();
  }

  Future<Contract?> getById(String id) async {
    final contracts = await getAll();
    return contracts.cast<Contract?>().firstWhere(
      (c) => c?.id == id,
      orElse: () => null,
    );
  }

  Future<List<Contract>> getByStatus(String status) async {
    final contracts = await getAll();
    return contracts.where((c) => c.status == status).toList();
  }

  Future<List<Contract>> getByUserId(String userId) async {
    final contracts = await getAll();
    return contracts.where((c) => c.assignedUserId == userId).toList();
  }

  Future<void> add(Contract contract) async {
    final contracts = await getAll();
    contracts.add(contract);
    await _storage.saveData(
      _storage.contractsKey,
      contracts.map((c) => c.toJson()).toList(),
    );
  }

  Future<void> createContract(Contract contract) async {
    await add(contract);
  }

  Future<void> update(Contract contract) async {
    final contracts = await getAll();
    final index = contracts.indexWhere((c) => c.id == contract.id);
    if (index != -1) {
      contracts[index] = contract;
      await _storage.saveData(
        _storage.contractsKey,
        contracts.map((c) => c.toJson()).toList(),
      );
    }
  }

  Future<void> delete(String id) async {
    final contracts = await getAll();
    contracts.removeWhere((c) => c.id == id);
    await _storage.saveData(
      _storage.contractsKey,
      contracts.map((c) => c.toJson()).toList(),
    );
  }

  Future<Map<String, int>> getStats() async {
    final contracts = await getAll();
    return {
      'total': contracts.length,
      'active': contracts.where((c) => c.status == 'active').length,
      'overdue': contracts.where((c) => c.status == 'overdue').length,
      'completed': contracts.where((c) => c.status == 'completed').length,
    };
  }
}
