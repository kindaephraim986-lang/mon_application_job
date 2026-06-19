/// lib/widgets/notifications_center.dart
/// Centre de notifications avec badge et liste

import 'package:flutter/material.dart';
import '../services/notification_service_flutter.dart';

class NotificationsCenter extends StatefulWidget {
  const NotificationsCenter({Key? key}) : super(key: key);

  @override
  State<NotificationsCenter> createState() => _NotificationsCenterState();
}

class _NotificationsCenterState extends State<NotificationsCenter> {
  late Future<Map<String, dynamic>> _notificationsFuture;
  int _unreadCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshNotifications();
  }

  void _refreshNotifications() {
    _notificationsFuture = NotificationServiceFlutter.getAllNotifications();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await NotificationServiceFlutter.getUnreadCount();
    if (mounted) {
      setState(() => _unreadCount = count);
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    final success = await NotificationServiceFlutter.markAsRead(notificationId);
    if (success) {
      _refreshNotifications();
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    final success = await NotificationServiceFlutter.deleteNotification(notificationId);
    if (success) {
      _refreshNotifications();
    }
  }

  Future<void> _markAllAsRead() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final updated = await NotificationServiceFlutter.markAllAsRead();

    if (mounted) {
      setState(() => _isLoading = false);
      if (updated > 0) {
        _refreshNotifications();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$updated notification(s) marquée(s) comme lue(s)')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextButton.icon(
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text('Tout marquer comme lu', style: TextStyle(color: Colors.white)),
                onPressed: _isLoading ? null : _markAllAsRead,
              ),
            ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!['success'] != true) {
            return Center(
              child: Text(
                snapshot.data?['message'] ?? 'Erreur lors du chargement',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final data = snapshot.data!;
          final notifications = data['notifications'] as List<Map<String, dynamic>>? ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune notification',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final isRead = notification['isRead'] as bool? ?? false;
              final type = notification['type'] as String? ?? '';
              final title = notification['title'] as String? ?? 'Notification';
              final message = notification['message'] as String? ?? '';
              final createdAt = notification['createdAt'] as String? ?? '';
              final notificationId = notification['id'] as int?;

              final formattedTime = createdAt.isNotEmpty
                  ? NotificationServiceFlutter.formatNotificationTime(
                      DateTime.parse(createdAt))
                  : '';

              return NotificationTile(
                isRead: isRead,
                type: type,
                title: title,
                message: message,
                formattedTime: formattedTime,
                onMarkAsRead: () => _markAsRead(notificationId!),
                onDelete: () => _deleteNotification(notificationId!),
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final bool isRead;
  final String type;
  final String title;
  final String message;
  final String formattedTime;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const NotificationTile({
    Key? key,
    required this.isRead,
    required this.type,
    required this.title,
    required this.message,
    required this.formattedTime,
    required this.onMarkAsRead,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icon = NotificationServiceFlutter.getNotificationIcon(type);
    final color = NotificationServiceFlutter.getNotificationColor(type);

    return Container(
      color: isRead ? Colors.white : Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),

            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formattedTime,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'read') {
                  onMarkAsRead();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (BuildContext context) => [
                if (!isRead)
                  const PopupMenuItem(
                    value: 'read',
                    child: Row(
                      children: [
                        Icon(Icons.check, size: 18),
                        SizedBox(width: 8),
                        Text('Marquer comme lue'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge de notification à utiliser dans la barre d'appbar
class NotificationBadge extends StatefulWidget {
  final VoidCallback onTap;

  const NotificationBadge({Key? key, required this.onTap}) : super(key: key);

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  late Future<int> _unreadCountFuture;

  @override
  void initState() {
    super.initState();
    _unreadCountFuture = NotificationServiceFlutter.getUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _unreadCountFuture,
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: widget.onTap,
            ),
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
