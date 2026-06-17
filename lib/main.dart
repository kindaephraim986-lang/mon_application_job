import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'candidate_dashboard.dart';
import 'company_dashboard.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AfriJob - Plateforme de Recrutement',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue[900],
        scaffoldBackgroundColor: const Color(0xfff5f7fa),
        fontFamily: 'Poppins',
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ApiService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.data == true) {
          // L'utilisateur est connecté, vérifier son type depuis le serveur
          return FutureBuilder<Map<String, dynamic>>(
            future: ApiService.getMyProfile(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userSnapshot.hasError) {
                return const AuthScreen();
              }

              final user = userSnapshot.data;
              if (user != null) {
                final userData = {
                  'id': user['id'].toString(),
                  'email': user['email'].toString(),
                  'userType': user['userType'].toString(),
                  'nom': user['nom']?.toString() ?? '',
                  if (user['userType'] == 'entreprise' && user['nom'] != null) 'nom_societe': user['nom'].toString(),
                  'filiere': user['filiere']?.toString() ?? '',
                  'domaine': user['domaine']?.toString() ?? '',
                  'telephone': user['telephone']?.toString() ?? '',
                  'age': user['age']?.toString() ?? '',
                  'domicile': user['domicile']?.toString() ?? '',
                  'sexe': user['sexe']?.toString() ?? '',
                  'photo': user['photo']?.toString() ?? '',
                };

                if (user['userType'] == 'candidat') {
                  return CandidateDashboard(initialData: userData);
                } else {
                  return CompanyDashboard(initialData: userData);
                }
              }
              return const AuthScreen();
            },
          );
        }
        
        return const AuthScreen();
      },
    );
  }
}