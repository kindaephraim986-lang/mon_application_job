import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'config/app_config.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;
  String _message = 'Chargement du panneau d’administration...';
  List<Map<String, dynamic>> _offers = [];
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    try {
      final offers = await ApiService.getOffers();
      final prefs = await SharedPreferences.getInstance();
      final currentUser = prefs.getString(AppConfig.tokenKey);
      if (!mounted) return;
      setState(() {
        _offers = offers;
        _users = [
          {
            'id': 1,
            'email': 'kinda@admin.com',
            'nom': 'KINDA',
            'type': 'admin',
          }
        ];
        _message = currentUser != null ? 'Panneau d’administration prêt' : 'Vous êtes connecté';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _message = 'Erreur : $e';
      });
    }
  }

  Future<void> _deleteOffer(int offerId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l’offre ?'),
        content: const Text('Cette action supprimera l’offre sélectionnée.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await ApiService.deleteOffer(offerId);
    if (!mounted) return;
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offre supprimée')));
      await _loadAdminData();
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
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _isLoading
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const CircularProgressIndicator(), const SizedBox(height: 16), Text(_message)]))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bienvenue KINDA', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_message, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Utilisateurs'),
                  const SizedBox(height: 8),
                  Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _users.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.admin_panel_settings)),
                          title: Text(user['nom'] ?? user['email']),
                          subtitle: Text('${user['email']} • ${user['type']}'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Offres'),
                  const SizedBox(height: 8),
                  if (_offers.isEmpty)
                    const Card(child: ListTile(title: Text('Aucune offre disponible')))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _offers.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final offer = _offers[index];
                        return Card(
                          child: ListTile(
                            title: Text(offer['titre'] ?? 'Sans titre'),
                            subtitle: Text(offer['description'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteOffer(int.parse(offer['id'].toString())),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }
}
