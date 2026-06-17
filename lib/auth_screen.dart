import 'package:flutter/material.dart';

import 'custom_widgets.dart';
import 'candidate_dashboard.dart';
import 'company_dashboard.dart';
import 'services/api_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isCandidat = true;
  String selectedSexe = 'Masculin';

  final _nomController = TextEditingController(text: "KINDA Ephraim");
  final _emailController = TextEditingController(text: "ephraim@example.com");
  final _telController = TextEditingController(text: "+226 70 00 00 00");
  final _filiereController = TextEditingController(text: "Développeur Full-Stack");
  final _ageController = TextEditingController(text: "25 ans");
  final _domicileController = TextEditingController(text: "Ouagadougou");
  final _passController = TextEditingController(text: "123456789");

  final _societeController = TextEditingController(text: "TechCorp SAS");
  final _emailSocieteController = TextEditingController(text: "contact@techcorp.com");
  final _domaineController = TextEditingController(text: "Ingénierie Logicielle & Cloud");
  final _telSocieteController = TextEditingController(text: "+226 25 30 00 00");

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telController.dispose();
    _filiereController.dispose();
    _ageController.dispose();
    _domicileController.dispose();
    _passController.dispose();
    _societeController.dispose();
    _emailSocieteController.dispose();
    _domaineController.dispose();
    _telSocieteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Icon(Icons.business_center, size: 80, color: Colors.blue[800]),
                const SizedBox(height: 10),
                Text(
                  isLogin ? "Connexion" : "Créer un compte",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => isCandidat = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isCandidat ? Colors.blue[800] : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Candidat",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isCandidat ? Colors.white : Colors.blue[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => isCandidat = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !isCandidat ? Colors.blue[800] : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Entreprise",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !isCandidat ? Colors.white : Colors.blue[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                isLogin ? _buildLoginForm() : _buildRegisterForm(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isLogin ? "Se connecter" : "S'inscrire",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin ? "Pas encore de compte ? Inscrivez-vous" : "Déjà un compte ? Connectez-vous",
                    style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        CustomTextField(
          hintText: isCandidat ? "Adresse email" : "Email Société",
          icon: Icons.email,
          controller: isCandidat ? _emailController : _emailSocieteController,
          keyboardType: TextInputType.emailAddress,
        ),
        CustomTextField(
          hintText: "Mot de passe",
          icon: Icons.lock,
          isPassword: true,
          controller: _passController,
        ),
      ],
    );
  }

  // Modifiez la fonction _handleAuth dans auth_screen.dart
Future<void> _handleAuth() async {
  // Vérifier les champs requis
  if (isLogin) {
    if ((isCandidat ? _emailController.text : _emailSocieteController.text).isEmpty ||
        _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }
  } else {
    if (isCandidat) {
      if (_nomController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _filiereController.text.isEmpty ||
          _passController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez remplir tous les champs')),
        );
        return;
      }
    } else {
      if (_societeController.text.isEmpty ||
          _emailSocieteController.text.isEmpty ||
          _domaineController.text.isEmpty ||
          _passController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez remplir tous les champs')),
        );
        return;
      }
    }
  }

  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    if (isLogin) {
      final response = await ApiService.login(
        email: isCandidat ? _emailController.text : _emailSocieteController.text,
        password: _passController.text,
      );

      if (mounted) Navigator.pop(context);

      if (response['token'] != null) {
        // Sauvegarder le token
        await ApiService.saveToken(response['token']);
        
        final user = response['user'];
        final Map<String, String> userData = {
          'id': user['id'].toString(),
          'email': user['email'].toString(),
          'userType': user['userType'].toString(),
          'nom': user['nom']?.toString() ?? '',
          if (user['userType'] == 'entreprise' && user['nom'] != null) 'nom_societe': user['nom'].toString(),
          if (user['filiere'] != null) 'filiere': user['filiere'].toString(),
          if (user['domaine'] != null) 'domaine': user['domaine'].toString(),
          if (user['telephone'] != null) 'telephone': user['telephone'].toString(),
          if (user['age'] != null) 'age': user['age'].toString(),
          if (user['domicile'] != null) 'domicile': user['domicile'].toString(),
          if (user['sexe'] != null) 'sexe': user['sexe'].toString(),
          if (user['photo'] != null) 'photo': user['photo'].toString(),
        };
        
        // Sauvegarder les données utilisateur
        await ApiService.saveUser(userData);
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => isCandidat 
                  ? CandidateDashboard(initialData: userData) 
                  : CompanyDashboard(initialData: userData),
            ),
          );
        }
      }
    } else {
      // INSCRIPTION INTELLIGENTE - Crée le compte ou connecte si existe
      final extraData = isCandidat 
          ? {
              'nom': _nomController.text,
              'filiere': _filiereController.text,
              'telephone': _telController.text,
              'sexe': selectedSexe,
              'age': int.tryParse(_ageController.text.split(' ')[0]) ?? 22,
              'domicile': _domicileController.text,
            }
          : {
              'nomSociete': _societeController.text,
              'domaine': _domaineController.text,
              'telephone': _telSocieteController.text,
              'description': 'Entreprise partenaire',
              'adresse': 'Non spécifié'
            };
      
      final response = await ApiService.smartRegisterOrLogin(
        email: isCandidat ? _emailController.text : _emailSocieteController.text,
        password: _passController.text,
        userType: isCandidat ? 'candidat' : 'entreprise',
        extraData: extraData,
      );

      if (mounted) Navigator.pop(context);

      if (response['token'] != null) {
        // Sauvegarder le token
        await ApiService.saveToken(response['token']);
        
        final user = response['user'];
        final Map<String, String> userData = {
          'id': user['id'].toString(),
          'email': user['email'].toString(),
          'userType': user['userType'].toString(),
          'nom': user['nom']?.toString() ?? '',
          if (user['userType'] == 'entreprise' && user['nom'] != null) 'nom_societe': user['nom'].toString(),
          if (user['filiere'] != null) 'filiere': user['filiere'].toString(),
          if (user['domaine'] != null) 'domaine': user['domaine'].toString(),
          if (user['telephone'] != null) 'telephone': user['telephone'].toString(),
          if (user['age'] != null) 'age': user['age'].toString(),
          if (user['domicile'] != null) 'domicile': user['domicile'].toString(),
          if (user['sexe'] != null) 'sexe': user['sexe'].toString(),
          if (user['photo'] != null) 'photo': user['photo'].toString(),
        };
        
        // Sauvegarder les données utilisateur
        await ApiService.saveUser(userData);
        
        String msgType = response['isNewAccount'] ?? false ? 'Compte créé' : 'Connecté';
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $msgType avec succès!'),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => isCandidat 
                  ? CandidateDashboard(initialData: userData) 
                  : CompanyDashboard(initialData: userData),
            ),
          );
        }
      }
    }
          _emailController.clear();
        } else {
          _emailSocieteController.clear();
        }
      }
    }
  } catch (e) {
    if (mounted) Navigator.pop(context);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception:', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
Widget _buildRegisterForm() {
  if (isCandidat) {
    return Column(
      children: [
        CustomTextField(
          hintText: "Nom complet",
          icon: Icons.person,
          controller: _nomController,
        ),
        CustomTextField(
          hintText: "Email",
          icon: Icons.email,
          controller: _emailController,
        ),
        CustomTextField(
          hintText: "Téléphone",
          icon: Icons.phone,
          controller: _telController,
        ),
        CustomTextField(
          hintText: "Filière",
          icon: Icons.school,
          controller: _filiereController,
        ),
        CustomTextField(
          hintText: "Age",
          icon: Icons.cake,
          controller: _ageController,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.transgender),
              labelText: 'Sexe',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedSexe,
                isExpanded: true,
                items: ['Masculin', 'Féminin', 'Autre']
                    .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedSexe = value;
                    });
                  }
                },
              ),
            ),
          ),
        ),
        CustomTextField(
          hintText: "Lieu de résidence",
          icon: Icons.home,
          controller: _domicileController,
        ),
        CustomTextField(
          hintText: "Mot de passe",
          icon: Icons.lock,
          controller: _passController,
          isPassword: true,
        ),
      ],
    );
  }

  return Column(
    children: [
      CustomTextField(
        hintText: "Nom de la société",
        icon: Icons.business,
        controller: _societeController,
      ),
      CustomTextField(
        hintText: "Email société",
        icon: Icons.email,
        controller: _emailSocieteController,
      ),
      CustomTextField(
        hintText: "Domaine",
        icon: Icons.work,
        controller: _domaineController,
      ),
      CustomTextField(
        hintText: "Téléphone",
        icon: Icons.phone,
        controller: _telSocieteController,
      ),
      CustomTextField(
        hintText: "Mot de passe",
        icon: Icons.lock,
        controller: _passController,
        isPassword: true,
      ),
    ],
  );
}
}