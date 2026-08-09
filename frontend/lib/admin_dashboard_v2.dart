import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'auth_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _offers = [];
  List<Map<String, dynamic>> _applications = [];
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await ApiService.getAdminStats();
      final users = await ApiService.getAdminUsers();
      final offers = await ApiService.getAdminOffers();
      final applications = await ApiService.getAdminApplications();
      final payments = await ApiService.getAdminPayments();
      final subscriptions = await ApiService.getAdminSubscriptions();

      if (!mounted) return;
      setState(() {
        _stats = stats['stats'] ?? {};
        _users = users;
        _offers = offers;
        _applications = applications;
        _payments = payments;
        _subscriptions = subscriptions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUser(int userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'utilisateur ?'),
        content: Text('Supprimer définitivement "$userName" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await ApiService.deleteAdminUser(userId);
    if (!mounted) return;
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Utilisateur supprimé')));
      await _loadAllData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Erreur')));
    }
  }

  Future<void> _deleteOffer(int offerId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'offre ?'),
        content: Text('Supprimer définitivement "$title" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await ApiService.deleteOffer(offerId);
    if (!mounted) return;
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offre supprimée')));
      await _loadAllData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Erreur')));
    }
  }

  Future<void> _deleteSubscription(int subscriptionId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'abonnement ?'),
        content: Text('Supprimer définitivement l\'abonnement de "$name" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await ApiService.deleteAdminSubscription(subscriptionId);
    if (!mounted) return;
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abonnement supprimé')));
      await _loadAllData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Erreur')));
    }
  }

  Future<void> _deletePayment(int paymentId, String label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le paiement ?'),
        content: Text('Supprimer définitivement le paiement de "$label" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await ApiService.deleteAdminPayment(paymentId);
    if (!mounted) return;
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paiement supprimé')));
      await _loadAllData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Erreur')));
    }
  }

  Future<void> _logout() async {
    // Effacer la session
    await ApiService.logout();
    
    if (!mounted) return;
    
    // Naviguer vers l'écran d'authentification et effacer l'historique
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Statistiques'),
            Tab(icon: Icon(Icons.people), text: 'Utilisateurs'),
            Tab(icon: Icon(Icons.work), text: 'Offres'),
            Tab(icon: Icon(Icons.assignment), text: 'Candidatures'),
            Tab(icon: Icon(Icons.payment), text: 'Paiements'),
            Tab(icon: Icon(Icons.subscriptions), text: 'Abonnements'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStatsTab(),
                _buildUsersTab(),
                _buildOffersTab(),
                _buildApplicationsTab(),
                _buildPaymentsTab(),
                _buildSubscriptionsTab(),
              ],
            ),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aperçu du système', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildStatCard('Utilisateurs', _stats['totalUsers']?.toString() ?? '0', Icons.people, Colors.blue),
              _buildStatCard('Offres', _stats['totalOffers']?.toString() ?? '0', Icons.work, Colors.orange),
              _buildStatCard('Candidatures', _stats['totalApplications']?.toString() ?? '0', Icons.assignment, Colors.green),
              _buildStatCard('Paiements', _stats['totalPayments']?.toString() ?? '0', Icons.payment, Colors.purple),
              _buildStatCard('Abonnements', _stats['totalSubscriptions']?.toString() ?? '0', Icons.subscriptions, Colors.teal),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return _users.isEmpty
        ? const Center(child: Text('Aucun utilisateur'))
        : ListView.builder(
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              final userType = (user['userType'] as String?) ?? 'inconnu';
              final subtitleLines = <String>[];
              subtitleLines.add(user['email'] ?? 'Email inconnu');
              subtitleLines.add(userType);
              if (userType == 'candidat') {
                final filiere = user['filiere_specialite'];
                if (filiere != null && filiere.toString().isNotEmpty) {
                  subtitleLines.add('Filière: $filiere');
                }
              } else if (userType == 'entreprise') {
                final domaine = user['domaine_activite'];
                if (domaine != null && domaine.toString().isNotEmpty) {
                  subtitleLines.add('Domaine: $domaine');
                }
              }

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      (user['nom'] as String?)?.isNotEmpty == true
                          ? (user['nom'] as String)[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(user['nom'] ?? 'Sans nom'),
                  subtitle: Text(subtitleLines.join(' • ')),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Supprimer cet inscrit',
                    onPressed: () => _deleteUser(int.parse(user['id'].toString()), user['nom'] ?? 'utilisateur'),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildOffersTab() {
    return _offers.isEmpty
        ? const Center(child: Text('Aucune offre'))
        : ListView.builder(
            itemCount: _offers.length,
            itemBuilder: (context, index) {
              final offer = _offers[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(offer['titre'] ?? 'Sans titre'),
                  subtitle: Text('${offer['nom_societe'] ?? 'Entreprise'} • ${offer['lieu'] ?? 'Lieu'}'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Supprimer'),
                        onTap: () => _deleteOffer(int.parse(offer['id'].toString()), offer['titre'] ?? 'offre'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildApplicationsTab() {
    return _applications.isEmpty
        ? const Center(child: Text('Aucune candidature'))
        : ListView.builder(
            itemCount: _applications.length,
            itemBuilder: (context, index) {
              final app = _applications[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(app['titre'] ?? 'Offre'),
                  subtitle: Text('${app['nom'] ?? 'Candidat'} • ${app['statut'] ?? 'Statut'}'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Accepter'),
                        onTap: () => ApiService.updateAdminApplication(int.parse(app['id'].toString()), 'acceptée')
                            .then((_) => _loadAllData()),
                      ),
                      PopupMenuItem(
                        child: const Text('Rejeter'),
                        onTap: () => ApiService.updateAdminApplication(int.parse(app['id'].toString()), 'rejetée')
                            .then((_) => _loadAllData()),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildPaymentsTab() {
    return _payments.isEmpty
        ? const Center(child: Text('Aucun paiement'))
        : ListView.builder(
            itemCount: _payments.length,
            itemBuilder: (context, index) {
              final payment = _payments[index];
              final label = payment['nom'] ?? payment['email'] ?? 'Utilisateur';
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('${payment['montant'] ?? '0'} FCFA'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$label • ${payment['methode_paiement'] ?? 'Méthode'}'),
                      const SizedBox(height: 4),
                      Text('Date: ${payment['date_paiement'] ?? '—'}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Supprimer ce paiement',
                    onPressed: () => _deletePayment(int.parse(payment['id'].toString()), label),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildSubscriptionsTab() {
    return _subscriptions.isEmpty
        ? const Center(child: Text('Aucun abonnement'))
        : ListView.builder(
            itemCount: _subscriptions.length,
            itemBuilder: (context, index) {
              final subscription = _subscriptions[index];
              final userEmail = subscription['email'] ?? 'Utilisateur inconnu';
              final userType = subscription['userType'] ?? 'Type inconnu';
              final userName = subscription['user_name'] ?? subscription['candidat_nom'] ?? subscription['entreprise_nom'] ?? userEmail;
              final dateDebut = subscription['date_debut'] ?? '—';
              final dateFin = subscription['date_fin'] ?? '—';
              final statut = subscription['statut'] ?? '—';
              final montant = subscription['montant']?.toString() ?? '0';
              final abonnementTypeRaw = subscription['type_abonnement'] ?? '—';
              final abonnementType = abonnementTypeRaw == 'candidat_mensuel'
                  ? 'Candidat mensuel'
                  : abonnementTypeRaw == 'entreprise_mensuel'
                      ? 'Entreprise mensuel'
                      : abonnementTypeRaw;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(userName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$userEmail • $userType • $abonnementType'),
                      const SizedBox(height: 4),
                      Text('Statut: $statut', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Du $dateDebut'),
                      Text('Au $dateFin'),
                      Text('Montant: $montant FCFA'),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Supprimer cet abonnement',
                    onPressed: () => _deleteSubscription(int.parse(subscription['id'].toString()), userName),
                  ),
                ),
              );
            },
          );
  }
}

