import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:viasolucoes/models/notification.dart';
import 'package:viasolucoes/services/notification_service.dart';
import 'package:viasolucoes/services/user_service.dart';
import 'package:viasolucoes/theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationService = NotificationService();
  final _userService = UserService();
  List<ViaNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final userId = await _userService.getCurrentUserId();
    if (userId != null) {
      final notifications = await _notificationService.getByUserId(userId);
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String id) async {
    await _notificationService.markAsRead(id);
    _loadNotifications();
  }

  Future<void> _markAllAsRead() async {
    final userId = await _userService.getCurrentUserId();
    if (userId != null) {
      await _notificationService.markAllAsRead(userId);
      _loadNotifications();
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'warning':
        return ViaColors.accent;
      case 'error':
        return ViaColors.error;
      case 'success':
        return ViaColors.success;
      case 'info':
        return ViaColors.secondary;
      default:
        return ViaColors.textSecondary;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'error':
        return Icons.error_outline;
      case 'success':
        return Icons.check_circle_outline;
      case 'info':
        return Icons.info_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notificações',
                style: Theme.of(context).textTheme.displaySmall,
              ).animate().fadeIn(duration: 400.ms),
              if (_notifications.any((n) => !n.isRead))
                TextButton(
                  onPressed: _markAllAsRead,
                  child: Text(
                    'Marcar todas',
                    style: TextStyle(color: ViaColors.primary),
                  ),
                ).animate().fadeIn(delay: 200.ms),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: ViaColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma notificação',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: ViaColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child:
                            InkWell(
                                  onTap: () => _markAsRead(notification.id),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: notification.isRead
                                          ? Theme.of(context).cardTheme.color
                                          : _getNotificationColor(
                                              notification.type,
                                            ).withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12),
                                      border: notification.isRead
                                          ? null
                                          : Border.all(
                                              color: _getNotificationColor(
                                                notification.type,
                                              ).withValues(alpha: 0.3),
                                            ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: _getNotificationColor(
                                              notification.type,
                                            ).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            _getNotificationIcon(
                                              notification.type,
                                            ),
                                            color: _getNotificationColor(
                                              notification.type,
                                            ),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      notification.title,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                            fontWeight:
                                                                notification
                                                                    .isRead
                                                                ? FontWeight
                                                                      .normal
                                                                : FontWeight
                                                                      .w600,
                                                          ),
                                                    ),
                                                  ),
                                                  if (!notification.isRead)
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            _getNotificationColor(
                                                              notification.type,
                                                            ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                notification.message,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                DateFormat(
                                                  'dd/MM/yyyy HH:mm',
                                                ).format(
                                                  notification.createdAt,
                                                ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: ViaColors
                                                          .textSecondary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: (index * 50).ms)
                                .slideX(begin: 0.2),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
