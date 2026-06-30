import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_screen.dart';
import 'candidate_dashboard.dart';
import './company_dashboard_impl.dart';
import 'screens/home_page.dart';
import 'services/api_service.dart';
import 'config/app_config.dart';
import 'admin_dashboard_v2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job research - Plateforme de Recrutement',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue[900],
        scaffoldBackgroundColor: const Color(0xfff5f7fa),
        fontFamily: 'Poppins',
      ),
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<bool> _apiCheckFuture;

  @override
  void initState() {
    super.initState();
    _apiCheckFuture = _checkApiAvailability();
  }

  /// Vérifie si le serveur API est accessible
  Future<bool> _checkApiAvailability() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/health'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Réessaye de vérifier l'API
  void _retryConnection() {
    setState(() {
      _apiCheckFuture = _checkApiAvailability();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _apiCheckFuture,
      builder: (context, apiSnapshot) {
        // Vérifier d'abord que l'API est accessible
        if (apiSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Connexion au serveur...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        // Si l'API n'est pas accessible, afficher un message d'erreur
        if (apiSnapshot.hasError || apiSnapshot.data == false) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_off,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Impossible de se connecter au serveur',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Serveur: ${AppConfig.baseUrl}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Assurez-vous que le serveur backend est en cours d\'exécution.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _retryConnection,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Si l'API est accessible, vérifier si l'utilisateur est connecté
        return FutureBuilder<bool>(
          future: ApiService.isLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.data == true) {
              // L'utilisateur est connecté, vérifier son type
              return FutureBuilder<Map<String, dynamic>?>(
                future: ApiService.getCurrentUser(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (userSnapshot.hasError) {
                    return Scaffold(
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 80,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Erreur lors du chargement du profil',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${userSnapshot.error}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () => setState(() {}),
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final user = userSnapshot.data;
                  if (user != null) {
                    final userType = user['userType']?.toString().toLowerCase() ?? 'candidat';
                  final userData = {
                      'id': user['id'].toString(),
                      'email': user['email'].toString(),
                      'userType': userType,
                      'nom': user['nom']?.toString() ?? '',
                      'nom_societe': user['nom_societe']?.toString() ??
                          (userType == 'entreprise'
                              ? user['nom']?.toString() ?? ''
                              : ''),
                      'filiere': (user['filiere'] ?? user['filiere_specialite'])
                              ?.toString() ??
                          '',
                      'domaine': user['domaine']?.toString() ?? '',
                      'telephone': user['telephone']?.toString() ?? '',
                      'sexe': user['sexe']?.toString() ?? '',
                      'age': user['age']?.toString() ?? '',
                      'domicile': user['domicile']?.toString() ?? '',
                      'adresse': user['adresse']?.toString() ?? '',
                      'villeLieu': user['villeLieu']?.toString() ?? ''
                    };

                    if (userType == 'admin') {
                      return const AdminDashboard();
                    }

                    if (userType == 'entreprise') {
                      return CompanyDashboard(initialData: userData);
                    }

                    return CandidateDashboard(initialData: userData);
                  }
                  return const AuthScreen();
                },
              );
            }

            return const AuthScreen();
          },
        );
      },
    );
  }
}


