import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<String> notifications = [];
  int candidatCount = 0;
  int entrepriseCount = 0;

  void notifyCompany(String message, BuildContext context) {
    final fullMsg = "[Entreprise] $message";
    notifications.add(fullMsg);
    entrepriseCount++;
    // Affiche un snackbar pour l'exemple
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Notification: $message")),
    );
  }

  void notifyCandidate(String message, BuildContext context) {
    final fullMsg = "[Candidat] $message";
    notifications.add(fullMsg);
    candidatCount++;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Notification: $message")),
    );
  }

  void resetCandidateCount() {
    candidatCount = 0;
  }

  void resetCompanyCount() {
    entrepriseCount = 0;
  }
}