import 'package:flutter/material.dart';
import 'payment_service.dart';
import 'subscription_service.dart';

class TestPaymentScreen extends StatefulWidget {
  const TestPaymentScreen({Key? key}) : super(key: key);

  @override
  State<TestPaymentScreen> createState() => _TestPaymentScreenState();
}

class _TestPaymentScreenState extends State<TestPaymentScreen> {
  bool _isLoading = false;
  String _testResult = '';

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
  }

  Future<void> _testCompanySubscription() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
    });

    try {
      final success = await PaymentService.payCompanyMonthly(
        context, 
        'test_company@example.com'
      );
      
      setState(() {
        _testResult = success 
            ? '✅ Abonnement entreprise activé avec succès !' 
            : '❌ Échec de l\'activation';
      });
      if (success) {
        _checkSubscriptionStatus();
      }
    } catch (e) {
      setState(() {
        _testResult = '❌ Erreur: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testCandidateSubscription() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
    });

    try {
      final success = await PaymentService.payCandidateMonthly(
        context, 
        'test_candidate@example.com'
      );
      
      setState(() {
        _testResult = success 
            ? '✅ Forfait candidat activé avec succès !' 
            : '❌ Échec de l\'activation';
      });
      if (success) {
        _checkSubscriptionStatus();
      }
    } catch (e) {
      setState(() {
        _testResult = '❌ Erreur: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testSingleApplication() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
    });

    try {
      final success = await PaymentService.payCandidatePerApplication(
        context, 
        'test_candidate@example.com',
        'Développeur Flutter (TEST)'
      );
      
      setState(() {
        _testResult = success 
            ? '✅ Candidature payée avec succès !' 
            : '❌ Échec du paiement';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Erreur: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkSubscriptionStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final isCompanyActive = await SubscriptionService
          .isCompanySubscriptionActive('test_company@example.com');
      final companyDays = await SubscriptionService
          .getRemainingDaysForCompany('test_company@example.com');
      
      final isCandidateActive = await SubscriptionService
          .hasCandidateMonthlyPass('test_candidate@example.com');
      final candidateDays = await SubscriptionService
          .getRemainingDaysForCandidate('test_candidate@example.com');
      
      setState(() {
        _testResult = '''
📊 STATUT DES ABONNEMENTS

🏢 ENTREPRISE (test_company@example.com):
   • Abonnement actif: ${isCompanyActive ? '✅ OUI' : '❌ NON'}
   • Jours restants: $companyDays jours

👤 CANDIDAT (test_candidate@example.com):
   • Forfait actif: ${isCandidateActive ? '✅ OUI' : '❌ NON'}
   • Jours restants: $candidateDays jours

💡 Conseil: Cliquez sur un bouton ci-dessous pour tester un paiement
''';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Erreur lors de la vérification: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetAllSubscriptions() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
    });

    try {
      await SubscriptionService.resetSubscription('test_company@example.com', 'company');
      await SubscriptionService.resetSubscription('test_candidate@example.com', 'candidate');
      
      setState(() {
        _testResult = '✅ Tous les abonnements ont été réinitialisés avec succès !';
      });
      _checkSubscriptionStatus();
    } catch (e) {
      setState(() {
        _testResult = '❌ Erreur lors de la réinitialisation: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bannière test
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.orange, Colors.deepOrange],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.science, size: 40, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'MODE TEST',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Panneau de test des paiements - Aucune transaction réelle',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Informations de test
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📱 INFORMATIONS DE TEST',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🔑 Code OTP de test:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('   123456', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 8),
                        Text('📞 Numéros de test:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('   Orange Money: 07 00 00 00 00'),
                        Text('   Wave: 07 00 00 00 01'),
                        Text('   Moov Money: 07 00 00 00 02'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Boutons de test
          const Text(
            '🚀 TESTER LES PAIEMENTS',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _testCompanySubscription,
              icon: const Icon(Icons.business),
              label: const Text('Abonnement ENTREPRISE (2000 FCFA / mois)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _testCandidateSubscription,
              icon: const Icon(Icons.person),
              label: const Text('Forfait CANDIDAT (1000 FCFA / mois)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _testSingleApplication,
              icon: const Icon(Icons.send),
              label: const Text('Candidature UNITAIRE (500 FCFA)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Gestion des abonnements
          const Text(
            '📊 GESTION DES TESTS',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _checkSubscriptionStatus,
              icon: const Icon(Icons.refresh),
              label: const Text('Vérifier le statut des abonnements'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _resetAllSubscriptions,
              icon: const Icon(Icons.delete_sweep),
              label: const Text('Réinitialiser TOUS les abonnements'),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Résultat des tests
          if (_testResult.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _testResult.contains('✅') 
                    ? Colors.green[50] 
                    : _testResult.contains('❌')
                        ? Colors.red[50]
                        : Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _testResult.contains('✅') 
                      ? Colors.green[200]! 
                      : _testResult.contains('❌')
                          ? Colors.red[200]!
                          : Colors.blue[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _testResult.contains('✅') ? Icons.check_circle :
                        _testResult.contains('❌') ? Icons.error_outline : Icons.info_outline,
                        color: _testResult.contains('✅') ? Colors.green :
                               _testResult.contains('❌') ? Colors.red : Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'RÉSULTAT',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _testResult,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          
          // Guide de test
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📖 GUIDE DE TEST',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  const Text('1️⃣ Choisissez un type de paiement à tester'),
                  const Text('2️⃣ Sélectionnez une méthode de paiement (Orange Money, Wave, etc.)'),
                  const Text('3️⃣ Utilisez les numéros de test : 07 00 00 00 00'),
                  const Text('4️⃣ Entrez le code OTP : 123456'),
                  const Text('5️⃣ Validez la transaction'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber, size: 16, color: Colors.amber),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '⚠️ Ce panneau est uniquement pour les tests. Aucune transaction réelle n\'est effectuée.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


