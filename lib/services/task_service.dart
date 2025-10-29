import 'package:viaflow/models/task.dart';
import 'package:viaflow/services/storage_service.dart';

class TaskService {
  final StorageService _storage = StorageService();

  Future<void> initializeSampleData() async {
    final tasks = await getAll();
    if (tasks.isEmpty) {
      final now = DateTime.now();
      final sampleTasks = [
        Task(
          id: 'task-1',
          title: 'Levantamento topográfico',
          description: 'Realizar levantamento completo do trecho km 45-52',
          contractId: 'contract-1',
          assignedUserId: 'user-2',
          priority: 'high',
          status: 'in_progress',
          dueDate: now.add(const Duration(days: 5)),
          createdAt: now.subtract(const Duration(days: 10)),
          updatedAt: now,
        ),
        Task(
          id: 'task-2',
          title: 'Instalação de placas',
          description: 'Colocar sinalização vertical km 100-115',
          contractId: 'contract-2',
          assignedUserId: 'user-3',
          priority: 'urgent',
          status: 'pending',
          dueDate: now.add(const Duration(days: 1)),
          createdAt: now.subtract(const Duration(days: 8)),
          updatedAt: now,
        ),
        Task(
          id: 'task-3',
          title: 'Aplicação de pintura',
          description: 'Pintura de faixas e demarcação viária',
          contractId: 'contract-1',
          assignedUserId: 'user-3',
          priority: 'medium',
          status: 'completed',
          dueDate: now.subtract(const Duration(days: 2)),
          createdAt: now.subtract(const Duration(days: 15)),
          updatedAt: now.subtract(const Duration(days: 2)),
        ),
        Task(
          id: 'task-4',
          title: 'Relatório de progresso',
          description: 'Enviar relatório mensal para a concessionária',
          contractId: 'contract-2',
          assignedUserId: 'user-1',
          priority: 'high',
          status: 'overdue',
          dueDate: now.subtract(const Duration(days: 3)),
          createdAt: now.subtract(const Duration(days: 20)),
          updatedAt: now.subtract(const Duration(days: 5)),
        ),
        Task(
          id: 'task-5',
          title: 'Inspeção de segurança',
          description: 'Vistoria de equipamentos e sinalização',
          contractId: 'contract-5',
          assignedUserId: 'user-2',
          priority: 'medium',
          status: 'pending',
          dueDate: now.add(const Duration(days: 7)),
          createdAt: now.subtract(const Duration(days: 5)),
          updatedAt: now,
        ),
      ];
      await _storage.saveData(
        _storage.tasksKey,
        sampleTasks.map((t) => t.toJson()).toList(),
      );
    }
  }

  Future<List<Task>> getAll() async {
    final data = await _storage.loadData(_storage.tasksKey);
    return data.map((json) => Task.fromJson(json)).toList();
  }

  Future<Task?> getById(String id) async {
    final tasks = await getAll();
    return tasks.cast<Task?>().firstWhere(
      (t) => t?.id == id,
      orElse: () => null,
    );
  }

  Future<List<Task>> getByContractId(String contractId) async {
    final tasks = await getAll();
    return tasks.where((t) => t.contractId == contractId).toList();
  }

  Future<List<Task>> getByUserId(String userId) async {
    final tasks = await getAll();
    return tasks.where((t) => t.assignedUserId == userId).toList();
  }

  Future<void> add(Task task) async {
    final tasks = await getAll();
    tasks.add(task);
    await _storage.saveData(
      _storage.tasksKey,
      tasks.map((t) => t.toJson()).toList(),
    );
  }

  Future<void> update(Task task) async {
    final tasks = await getAll();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await _storage.saveData(
        _storage.tasksKey,
        tasks.map((t) => t.toJson()).toList(),
      );
    }
  }

  Future<void> delete(String id) async {
    final tasks = await getAll();
    tasks.removeWhere((t) => t.id == id);
    await _storage.saveData(
      _storage.tasksKey,
      tasks.map((t) => t.toJson()).toList(),
    );
  }
}
