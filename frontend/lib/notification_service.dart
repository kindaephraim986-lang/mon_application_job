import 'api_service.dart';

/// Modèle pour une notification
class Notification {
  final int id;
  final String message;
  final String? typeNotification;
  final bool estLu;
  final DateTime? dateNotification;

  Notification({
    required this.id,
    required this.message,
    this.typeNotification,
    required this.estLu,
    this.dateNotification,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      message: json['message']?.toString() ?? '',
      typeNotification: json['type_notification']?.toString(),
      estLu: json['est_lu'] == 1 || json['est_lu'] == true,
      dateNotification: json['date_notification'] != null
          ? DateTime.parse(json['date_notification'].toString())
          : null,
    );
  }
}

/// Service pour gérer les notifications via l'API (base de données)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Propriétés statiques pour compatibilité avec les dashboards
  static int candidatCount = 0;
  static int entrepriseCount = 0;
  static List<String> notifications = [];

  /// Obtenir toutes les notifications de l'utilisateur
  static Future<List<Notification>> getNotifications() async {
    final notifications = await ApiService.getNotifications();
    return notifications.map((n) => Notification.fromJson(n)).toList();
  }

  /// Compter les notifications non lues
  static Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.estLu).length;
  }

  /// Marquer une notification comme lue
  static Future<bool> markAsRead(int notificationId) async {
    // Cette méthode nécessite un nouvel endpoint dans ApiService
    // À implémenter dans le backend
    return true;
  }

  /// Notifier l'entreprise d'une candidature
  static void notifyCompany(String message) {
    notifications.add('[Entreprise] $message');
    entrepriseCount++;
  }

  /// Notifier le candidat d'une réponse
  static void notifyCandidate(String message) {
    notifications.add('[Candidat] $message');
    candidatCount++;
  }

  /// Réinitialiser le compteur pour les candidats
  static void resetCandidateCount() {
    candidatCount = 0;
  }

  /// Réinitialiser le compteur pour les entreprises
  static void resetCompanyCount() {
    entrepriseCount = 0;
  }

  /// Marquer toutes les notifications comme lues
  static Future<bool> markAllAsRead() async {
    // Cette méthode nécessite un nouvel endpoint dans ApiService
    // À implémenter dans le backend
    return true;
  }
}


