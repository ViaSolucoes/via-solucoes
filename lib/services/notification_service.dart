import 'package:viaflow/models/notification.dart';
import 'package:viaflow/services/storage_service.dart';

class NotificationService {
  final StorageService _storage = StorageService();

  Future<void> initializeSampleData(String userId) async {
    final notifications = await getByUserId(userId);
    if (notifications.isEmpty) {
      final now = DateTime.now();
      final sampleNotifications = [
        ViaNotification(
          id: 'notif-1',
          userId: userId,
          title: 'Prazo próximo',
          message: 'A tarefa "Instalação de placas" vence amanhã',
          type: 'warning',
          isRead: false,
          relatedId: 'task-2',
          createdAt: now.subtract(const Duration(hours: 2)),
          updatedAt: now.subtract(const Duration(hours: 2)),
        ),
        ViaNotification(
          id: 'notif-2',
          userId: userId,
          title: 'Contrato atualizado',
          message: 'Progresso do contrato ViaOeste foi atualizado',
          type: 'info',
          isRead: false,
          relatedId: 'contract-1',
          createdAt: now.subtract(const Duration(hours: 5)),
          updatedAt: now.subtract(const Duration(hours: 5)),
        ),
        ViaNotification(
          id: 'notif-3',
          userId: userId,
          title: 'Tarefa concluída',
          message: 'A tarefa "Aplicação de pintura" foi finalizada',
          type: 'success',
          isRead: true,
          relatedId: 'task-3',
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
        ViaNotification(
          id: 'notif-4',
          userId: userId,
          title: 'Atraso detectado',
          message: 'Relatório de progresso está atrasado',
          type: 'error',
          isRead: false,
          relatedId: 'task-4',
          createdAt: now.subtract(const Duration(hours: 1)),
          updatedAt: now.subtract(const Duration(hours: 1)),
        ),
      ];
      final allNotifications = await getAll();
      allNotifications.addAll(sampleNotifications);
      await _storage.saveData(
        _storage.notificationsKey,
        allNotifications.map((n) => n.toJson()).toList(),
      );
    }
  }

  Future<List<ViaNotification>> getAll() async {
    final data = await _storage.loadData(_storage.notificationsKey);
    return data.map((json) => ViaNotification.fromJson(json)).toList();
  }

  Future<List<ViaNotification>> getByUserId(String userId) async {
    final notifications = await getAll();
    return notifications.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<int> getUnreadCount(String userId) async {
    final notifications = await getByUserId(userId);
    return notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String id) async {
    final notifications = await getAll();
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(
        isRead: true,
        updatedAt: DateTime.now(),
      );
      await _storage.saveData(
        _storage.notificationsKey,
        notifications.map((n) => n.toJson()).toList(),
      );
    }
  }

  Future<void> markAllAsRead(String userId) async {
    final notifications = await getAll();
    final now = DateTime.now();
    final updated = notifications.map((n) {
      if (n.userId == userId && !n.isRead) {
        return n.copyWith(isRead: true, updatedAt: now);
      }
      return n;
    }).toList();
    await _storage.saveData(
      _storage.notificationsKey,
      updated.map((n) => n.toJson()).toList(),
    );
  }

  Future<void> delete(String id) async {
    final notifications = await getAll();
    notifications.removeWhere((n) => n.id == id);
    await _storage.saveData(
      _storage.notificationsKey,
      notifications.map((n) => n.toJson()).toList(),
    );
  }
}
