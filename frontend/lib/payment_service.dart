import 'package:flutter/material.dart';
import 'subscription_service.dart';

class PaymentService {
  static const int companyMonthlyAmount = 2000;
  static const int candidateMonthlyAmount = 1000;
  static const int candidatePerApplicationAmount = 500;

  // Méthodes de paiement disponibles
  static final List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      id: 'orange_money',
      name: 'Orange Money',
      code: 'OM',
      icon: Icons.phone_android,
      color: Colors.orange,
    ),
    PaymentMethod(
      id: 'wave',
      name: 'Wave',
      code: 'WAVE',
      icon: Icons.waves,
      color: Colors.blue,
    ),
    PaymentMethod(
      id: 'moov_money',
      name: 'Moov Money',
      code: 'MM',
      icon: Icons.phone_iphone,
      color: Colors.red,
    ),
  ];

  // Sélectionner la méthode de paiement
  static Future<PaymentMethod?> selectPaymentMethod(BuildContext context, int amount) async {
  return await showDialog<PaymentMethod>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Paiement", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("$amount FCFA", style: const TextStyle(fontSize: 28, color: Colors.blue, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              // Liste des méthodes
              ...paymentMethods.map((method) => ListTile(
                leading: Icon(method.icon, color: method.color),
                title: Text(method.name),
                onTap: () => Navigator.pop(context, method),
              )).toList(),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              )
            ],
          ),
        ),
      );
    },
  );
}

  // Simuler un paiement
  static Future<bool> simulatePayment({
    required BuildContext context,
    required int amount,
    required String reason,
    required String userEmail,
    required String userType,
    required PaymentMethod method,
    required Duration duration,
    required String successMessage,
  }) async {
    final phoneController = TextEditingController();
    final otpController = TextEditingController();
    bool otpSent = false;
    bool isProcessing = false;
    bool? result;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: method.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(method.icon, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      method.name,
                      style: TextStyle(color: method.color, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("💰 Montant: $amount FCFA", style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("📝 Motif: $reason"),
                        Text("👤 ${userType == 'company' ? 'Entreprise' : 'Candidat'}"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!otpSent) ...[
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Numéro ${method.name}",
                        hintText: "Ex: 0700000000",
                        prefixIcon: Icon(Icons.phone, color: method.color),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Numéro de test: 0700000000",
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ] else ...[
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Code OTP",
                        hintText: "123456",
                        prefixIcon: Icon(Icons.security, color: method.color),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Code de test: 123456",
                      style: TextStyle(fontSize: 11, color: Colors.green[700]),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text("Annuler", style: TextStyle(color: Colors.red)),
                ),
                if (!otpSent)
                  ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () {
                            if (phoneController.text.isNotEmpty) {
                              setState(() {
                                otpSent = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Code OTP envoyé au ${phoneController.text}"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Veuillez entrer votre numéro")),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: method.color),
                    child: const Text("Envoyer OTP"),
                  ),
                if (otpSent)
                  ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () async {
                            if (otpController.text == "123456") {
                              setState(() => isProcessing = true);
                              await Future.delayed(const Duration(seconds: 1));
                              
                              if (duration.inDays > 0) {
                                if (userType == 'company') {
                                  await SubscriptionService.setCompanySubscription(userEmail, duration.inDays);
                                } else {
                                  await SubscriptionService.setCandidateMonthlyPass(userEmail, duration.inDays);
                                }
                              }
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
                                );
                              }
                              Navigator.pop(context, true);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Code OTP incorrect"), backgroundColor: Colors.red),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: isProcessing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("Confirmer"),
                  ),
              ],
            );
          },
        );
      },
    ).then((value) => result = value);

    phoneController.dispose();
    otpController.dispose();
    return result ?? false;
  }

  // Paiement entreprise
  static Future<bool> payCompanyMonthly(BuildContext context, String companyEmail) async {
    // CORRECTION : Utiliser companyMonthlyAmount au lieu de 'amount'
    final method = await selectPaymentMethod(context, companyMonthlyAmount);
    if (method == null) return false;
    
    return simulatePayment(
      context: context,
      amount: companyMonthlyAmount,
      reason: 'Abonnement entreprise - 30 jours',
      userEmail: companyEmail,
      userType: 'company',
      method: method,
      duration: const Duration(days: 30),
      successMessage: '✅ Abonnement entreprise activé pour 30 jours !',
    );
  }

  // Paiement candidat forfait mensuel
  static Future<bool> payCandidateMonthly(BuildContext context, String candidateEmail) async {
    // CORRECTION : Utiliser candidateMonthlyAmount au lieu de 'amount'
    final method = await selectPaymentMethod(context, candidateMonthlyAmount);
    if (method == null) return false;
    
    return simulatePayment(
      context: context,
      amount: candidateMonthlyAmount,
      reason: 'Forfait candidature illimitée - 30 jours',
      userEmail: candidateEmail,
      userType: 'candidate',
      method: method,
      duration: const Duration(days: 30),
      successMessage: '✅ Forfait mensuel candidat activé pour 30 jours !',
    );
  }

  // Paiement candidat à l'unité
  static Future<bool> payCandidatePerApplication(BuildContext context, String candidateEmail, String offreTitre) async {
    // CORRECTION : Utiliser candidatePerApplicationAmount au lieu de 'amount'
    final method = await selectPaymentMethod(context, candidatePerApplicationAmount);
    if (method == null) return false;
    
    return simulatePayment(
      context: context,
      amount: candidatePerApplicationAmount,
      reason: 'Candidature: $offreTitre',
      userEmail: candidateEmail,
      userType: 'candidate',
      method: method,
      duration: const Duration(days: 0),
      successMessage: '✅ Paiement accepté, candidature envoyée !',
    );
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final String code;
  final IconData icon;
  final Color color;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.code,
    required this.icon,
    required this.color,
  });
}



