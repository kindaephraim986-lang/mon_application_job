import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  // Clés pour SharedPreferences
  static const String _keyCompanyExpiry = 'company_expiry_';
  static const String _keyCandidateMonthlyExpiry = 'candidate_monthly_expiry_';
  static const String _keyCompanyPaymentHistory = 'company_payment_history_';
  static const String _keyCandidatePaymentHistory = 'candidate_payment_history_';

  // === ENTREPRISE ===
  Future<DateTime?> getCompanySubscriptionExpiry(String companyEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_keyCompanyExpiry + companyEmail);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<bool> isCompanySubscriptionActive(String companyEmail) async {
    final expiry = await getCompanySubscriptionExpiry(companyEmail);
    if (expiry == null) return false;
    return expiry.isAfter(DateTime.now());
  }

  Future<void> setCompanySubscription(String companyEmail, Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(duration);
    await prefs.setInt(_keyCompanyExpiry + companyEmail, expiry.millisecondsSinceEpoch);
    
    // Enregistrer l'historique
    await _addPaymentHistory(companyEmail, 'company', 'monthly', expiry);
  }

  Future<int> getRemainingDaysForCompany(String companyEmail) async {
    final expiry = await getCompanySubscriptionExpiry(companyEmail);
    if (expiry == null) return 0;
    final remaining = expiry.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  // === CANDIDAT : forfait mensuel ===
  Future<DateTime?> getCandidateMonthlyExpiry(String candidateEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_keyCandidateMonthlyExpiry + candidateEmail);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<bool> hasCandidateMonthlyPass(String candidateEmail) async {
    final expiry = await getCandidateMonthlyExpiry(candidateEmail);
    if (expiry == null) return false;
    return expiry.isAfter(DateTime.now());
  }

  Future<void> setCandidateMonthlyPass(String candidateEmail, Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(duration);
    await prefs.setInt(_keyCandidateMonthlyExpiry + candidateEmail, expiry.millisecondsSinceEpoch);
    
    // Enregistrer l'historique
    await _addPaymentHistory(candidateEmail, 'candidate', 'monthly_pass', expiry);
  }

  Future<int> getRemainingDaysForCandidate(String candidateEmail) async {
    final expiry = await getCandidateMonthlyExpiry(candidateEmail);
    if (expiry == null) return 0;
    final remaining = expiry.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  // === HISTORIQUE DES PAIEMENTS ===
  Future<void> _addPaymentHistory(String email, String userType, String package, DateTime expiry) async {
    final prefs = await SharedPreferences.getInstance();
    final key = userType == 'company' ? _keyCompanyPaymentHistory : _keyCandidatePaymentHistory;
    final List<String> history = prefs.getStringList(key + email) ?? [];
    
    final paymentRecord = '${DateTime.now().toIso8601String()}|$package|${expiry.toIso8601String()}';
    history.add(paymentRecord);
    await prefs.setStringList(key + email, history);
  }

  Future<List<String>> getPaymentHistory(String email, String userType) async {
    final prefs = await SharedPreferences.getInstance();
    final key = userType == 'company' ? _keyCompanyPaymentHistory : _keyCandidatePaymentHistory;
    return prefs.getStringList(key + email) ?? [];
  }

  Future<int> getTotalPaymentsCount(String email, String userType) async {
    final history = await getPaymentHistory(email, userType);
    return history.length;
  }

  // === RESET POUR TEST (UTILE POUR LES SIMULATIONS) ===
  Future<void> resetSubscription(String email, String userType) async {
    final prefs = await SharedPreferences.getInstance();
    if (userType == 'company') {
      await prefs.remove(_keyCompanyExpiry + email);
      await prefs.remove(_keyCompanyPaymentHistory + email);
    } else {
      await prefs.remove(_keyCandidateMonthlyExpiry + email);
      await prefs.remove(_keyCandidatePaymentHistory + email);
    }
  }
}