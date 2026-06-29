import 'package:flutter/material.dart';
import 'services/api_service.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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

      if (!mounted) return;
      setState(() {
        _stats = stats['stats'] ?? {};
        _users = users;
        _offers = offers;
        _applications = applications;
        _payments = payments;
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

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
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
          ],
        ),
        actions: [
          IconButton(onPressed: _loadAllData, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
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
            ],
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
                  subtitle: Text('${user['email']} • ${user['userType'] ?? 'user'}'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Supprimer'),
                        onTap: () => _deleteUser(int.parse(user['id'].toString()), user['nom'] ?? 'utilisateur'),
                      ),
                    ],
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
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('${payment['montant'] ?? '0'} FCFA'),
                  subtitle: Text('${payment['nom'] ?? 'Utilisateur'} • ${payment['methode_paiement'] ?? 'Méthode'}'),
                  trailing: Chip(label: Text(payment['statut'] ?? 'pending')),
                ),
              );
            },
          );
  }
}
