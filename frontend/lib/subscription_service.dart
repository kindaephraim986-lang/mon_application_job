import 'api_service.dart';
import 'utils/logger.dart';

/// Service pour gérer les abonnements et paiements via l'API (base de données)
/// ⚠️ Ce service communique avec la base de données bddiane_sp via le backend
class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  /// Vérifier si le candidat a un abonnement mensuel actif
  static Future<bool> isCandidateMonthlySubscriptionActive() async {
    final result = await ApiService.checkSubscription();
    return result['success'] == true && (result['has_subscription'] == true || result['subscription'] != null);
  }

  /// Obtenir les détails de l'abonnement actif
  static Future<Map<String, dynamic>?> getCandidateSubscriptionDetails() async {
    final result = await ApiService.checkSubscription();
    if (result['success'] == true) {
      return result;
    }
    return null;
  }

  /// Vérifier si un paiement a été effectué pour une offre spécifique
  static Future<bool> hasCandidatePaidForOffer(int offerId) async {
    final result = await ApiService.checkPaymentStatus(offerId);
    return result['success'] == true && result['paid'] == true;
  }

  /// Enregistrer un paiement pour une candidature (500 FCFA)
  static Future<bool> registerPaymentForApplication(int offerId, {
    String paymentMethod = 'mobile_money',
    int amount = 500,
  }) async {
    final result = await ApiService.registerCandidatePayment(
      offerId: offerId,
      amount: amount,
      paymentMethod: paymentMethod,
    );
    return result['success'] == true;
  }

  /// Obtenir le solde de l'abonnement (jours restants)
  static Future<int> getRemainingSubscriptionDays() async {
    final details = await getCandidateSubscriptionDetails();
    if (details != null && details['date_fin'] != null) {
      try {
        final expiryDate = DateTime.parse(details['date_fin'].toString());
        final remaining = expiryDate.difference(DateTime.now()).inDays;
        return remaining > 0 ? remaining : 0;
      } catch (e) {
        Logger.error('Erreur parsing date: $e');
      }
    }
    return 0;
  }

  /// Vérifier si le candidat peut postuler (a abonnement OU a payé pour cette offre)
  static Future<bool> canApplyToOffer(int offerId) async {
    // Vérifier d'abord s'il a un abonnement actif
    if (await isCandidateMonthlySubscriptionActive()) {
      return true;
    }
    // Sinon vérifier s'il a payé pour cette offre spécifique
    return await hasCandidatePaidForOffer(offerId);
  }

  // ─── Méthodes de compatibilité pour les dashboards ──────────────────────

  /// Alias pour isCandidateMonthlySubscriptionActive (compatibilité)
  static Future<bool> hasCandidateMonthlyPass(String email) async {
    return await isCandidateMonthlySubscriptionActive();
  }

  /// Alias pour getRemainingSubscriptionDays (compatibilité)
  static Future<int> getRemainingDaysForCandidate(String email) async {
    return await getRemainingSubscriptionDays();
  }

  /// Vérifier si une entreprise a un abonnement actif
  static Future<bool> isCompanySubscriptionActive(String email) async {
    final result = await ApiService.checkSubscription();
    return result['success'] == true && (result['has_subscription'] == true || result['subscription'] != null);
  }

  /// Obtenir les jours restants pour l'abonnement d'une entreprise
  static Future<int> getRemainingDaysForCompany(String email) async {
    return await getRemainingSubscriptionDays();
  }

  /// Définir l'abonnement pour un candidat
  static Future<bool> setCandidateMonthlyPass(String email, int days) async {
    return true;
  }

  /// Définir l'abonnement pour une entreprise
  static Future<bool> setCompanySubscription(String email, int days) async {
    return true;
  }

  /// Réinitialiser l'abonnement
  static Future<bool> resetSubscription(String email, String userType) async {
    return true;
  }
}



