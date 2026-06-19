/// lib/services/notification_service_flutter.dart
/// Service pour gérer les notifications côté client

import 'package:flutter/material.dart';
import 'api_service.dart';

class NotificationServiceFlutter {
  static final NotificationServiceFlutter _instance = NotificationServiceFlutter._internal();

  factory NotificationServiceFlutter() {
    return _instance;
  }

  NotificationServiceFlutter._internal();

  /// Récupérer les notifications non lues
  /// @param limit - Nombre de notifications à récupérer
  /// @return Liste des notifications avec count
  static Future<Map<String, dynamic>> getUnreadNotifications({int limit = 20}) async {
    try {
      final response = await ApiService.getUnreadNotifications(limit);

      if (response['success'] == true) {
        List<Map<String, dynamic>> notifications = [];

        if (response['notifications'] != null) {
          notifications = List<Map<String, dynamic>>.from(
            (response['notifications'] as List).map((n) => {
              'id': n['id'],
              'type': n['type'],
              'title': n['title'],
              'message': n['message'],
              'isRead': n['is_read'] == 1 || n['is_read'] == true,
              'createdAt': n['created_at'],
              'relatedId': n['related_id'],
              'relatedType': n['related_type']
            })
          );
        }

        return {
          'success': true,
          'notifications': notifications,
          'unreadCount': response['unreadCount'] ?? notifications.length
        };
      }

      return {'success': false, 'notifications': [], 'unreadCount': 0};
    } catch (error) {
      print('Erreur getUnreadNotifications: $error');
      return {'success': false, 'notifications': [], 'unreadCount': 0};
    }
  }

  /// Récupérer toutes les notifications (paginées)
  /// @param limit - Nombre par page
  /// @param offset - Décalage pour pagination
  /// @return Toutes les notifications avec pagination info
  static Future<Map<String, dynamic>> getAllNotifications({
    int limit = 50,
    int offset = 0
  }) async {
    try {
      final response = await ApiService.getAllNotifications(limit, offset);

      if (response['success'] == true) {
        List<Map<String, dynamic>> notifications = [];

        if (response['notifications'] != null) {
          notifications = List<Map<String, dynamic>>.from(
            (response['notifications'] as List).map((n) => {
              'id': n['id'],
              'type': n['type'],
              'title': n['title'],
              'message': n['message'],
              'isRead': n['is_read'] == 1 || n['is_read'] == true,
              'createdAt': n['created_at'],
              'readAt': n['read_at'],
              'relatedId': n['related_id'],
              'relatedType': n['related_type']
            })
          );
        }

        return {
          'success': true,
          'notifications': notifications,
          'total': response['total'] ?? 0,
          'unread': response['unread'] ?? 0,
          'hasMore': response['hasMore'] ?? false
        };
      }

      return {
        'success': false,
        'notifications': [],
        'total': 0,
        'unread': 0,
        'hasMore': false
      };
    } catch (error) {
      print('Erreur getAllNotifications: $error');
      return {
        'success': false,
        'notifications': [],
        'total': 0,
        'unread': 0,
        'hasMore': false
      };
    }
  }

  /// Récupérer le count de notifications non lues
  /// @return Nombre de notifications non lues
  static Future<int> getUnreadCount() async {
    try {
      final response = await ApiService.getUnreadCount();

      if (response['success'] == true) {
        return response['unreadCount'] ?? 0;
      }

      return 0;
    } catch (error) {
      print('Erreur getUnreadCount: $error');
      return 0;
    }
  }

  /// Marquer une notification comme lue
  /// @param notificationId - ID de la notification
  /// @return Succès de l'opération
  static Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await ApiService.markNotificationAsRead(notificationId);
      return response['success'] == true;
    } catch (error) {
      print('Erreur markAsRead: $error');
      return false;
    }
  }

  /// Marquer toutes les notifications comme lues
  /// @return Nombre de notifications mises à jour
  static Future<int> markAllAsRead() async {
    try {
      final response = await ApiService.markAllNotificationsAsRead();

      if (response['success'] == true) {
        return response['updated'] ?? 0;
      }

      return 0;
    } catch (error) {
      print('Erreur markAllAsRead: $error');
      return 0;
    }
  }

  /// Supprimer une notification
  /// @param notificationId - ID de la notification
  /// @return Succès de l'opération
  static Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await ApiService.deleteNotification(notificationId);
      return response['success'] == true;
    } catch (error) {
      print('Erreur deleteNotification: $error');
      return false;
    }
  }

  /// Supprimer toutes les notifications lues
  /// @return Nombre de notifications supprimées
  static Future<int> deleteReadNotifications() async {
    try {
      final response = await ApiService.deleteReadNotifications();

      if (response['success'] == true) {
        return response['deleted'] ?? 0;
      }

      return 0;
    } catch (error) {
      print('Erreur deleteReadNotifications: $error');
      return 0;
    }
  }

  /// Formater la date d'une notification pour affichage
  /// "Il y a X secondes", "Il y a X minutes", etc.
  static String formatNotificationTime(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return 'Il y a ${mins == 1 ? "1 minute" : "$mins minutes"}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'Il y a ${hours == 1 ? "1 heure" : "$hours heures"}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'Il y a ${days == 1 ? "1 jour" : "$days jours"}';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// Obtenir l'icône pour un type de notification
  static IconData getNotificationIcon(String type) {
    switch (type) {
      case 'offer':
        return Icons.work;
      case 'message':
        return Icons.message;
      case 'application_update':
        return Icons.check_circle;
      case 'subscription':
        return Icons.card_membership;
      case 'document_access':
        return Icons.lock_outline;
      default:
        return Icons.notifications;
    }
  }

  /// Obtenir la couleur pour un type de notification
  static Color getNotificationColor(String type) {
    switch (type) {
      case 'offer':
        return Colors.blue;
      case 'message':
        return Colors.green;
      case 'application_update':
        return Colors.teal;
      case 'subscription':
        return Colors.purple;
      case 'document_access':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

// (imports en tête de fichier)
