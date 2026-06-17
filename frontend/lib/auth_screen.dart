import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'candidate_dashboard.dart';
import 'company_dashboard.dart';
import 'profile_confirmation_screen.dart';
import 'services/api_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  bool isLogin = true;
  bool isCandidat = true;
  String selectedSexe = 'Masculin';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telController = TextEditingController();
  final _filiereController = TextEditingController();
  final _ageController = TextEditingController();
  final _domicileController = TextEditingController();
  final _passController = TextEditingController();

  final _societeController = TextEditingController();
  final _emailSocieteController = TextEditingController();
  final _domaineController = TextEditingController();
  final _lieuEntrepriseController = TextEditingController();
  final _telSocieteController = TextEditingController();
  Uint8List? _registerCvBytes;
  Uint8List? _registerCnibRectoBytes;
  Uint8List? _registerCnibVersoBytes;
  String _registerCvFileName = '';
  String _registerCnibRectoFileName = '';
  String _registerCnibVersoFileName = '';

  static const List<String> _validCvExtensions = ['pdf', 'doc', 'docx'];
  static const List<String> _validImageExtensions = ['jpg', 'jpeg', 'png'];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();
  }

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
    _lieuEntrepriseController.dispose();
    _telSocieteController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeroSection(),
                    const SizedBox(height: 30),
                    _buildTabButtons(),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.98),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 12),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          isLogin ? _buildLoginForm() : _buildRegisterForm(),
                          const SizedBox(height: 20),
                          _buildSubmitButton(),
                          const SizedBox(height: 16),
                          _buildToggleAuthButton(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        // Show a larger centered logo when registering, smaller decorative when logging in
        if (!isLogin)
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          )
        else
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
          ),
        const SizedBox(height: 20),
        Text(
          isLogin ? "Bienvenue !" : "Créer un compte",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: isLogin ? Colors.white : const Color(0xFFBF360C),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isLogin
              ? "Connectez-vous pour continuer votre parcours"
              : "Rejoignez notre communauté dès aujourd'hui",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildTabButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTabButton("Candidat", true),
          _buildTabButton("Entreprise", false),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isSelectedTab) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => isCandidat = isSelectedTab),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: (isCandidat == isSelectedTab) ? const Color(0xFFBF360C) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: (isCandidat == isSelectedTab) ? Colors.white : Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        _buildInputField(
          controller: isCandidat ? _emailController : _emailSocieteController,
          hintText: isCandidat ? "Adresse email" : "Email Société",
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _passController,
          hintText: "Mot de passe",
          icon: Icons.lock_outline,
          isPassword: true,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        if (isCandidat) ...[
          _buildInputField(
            controller: _nomController,
            hintText: "Nom complet",
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _telController,
            hintText: "Numéro de téléphone",
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _ageController,
            hintText: "Âge",
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _domicileController,
            hintText: "Lieu de résidence",
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _filiereController,
            hintText: "Filière / Spécialité",
            icon: Icons.school_outlined,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _emailController,
            hintText: "Adresse email",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _buildDocumentPicker(
            title: _registerCvFileName.isEmpty ? "Curriculum Vitae (CV)" : _registerCvFileName,
            subtitle: "PDF, DOC ou DOCX",
            icon: Icons.description_outlined,
            isLoaded: _registerCvBytes != null,
            onPressed: _pickRegisterCV,
          ),
          const SizedBox(height: 12),
          _buildDocumentPicker(
            title: _registerCnibRectoFileName.isEmpty ? "CNIB - Recto" : _registerCnibRectoFileName,
            subtitle: "Image JPG ou PNG",
            icon: Icons.credit_card,
            isLoaded: _registerCnibRectoBytes != null,
            onPressed: () => _pickRegisterCNIB(isRecto: true),
          ),
          const SizedBox(height: 12),
          _buildDocumentPicker(
            title: _registerCnibVersoFileName.isEmpty ? "CNIB - Verso" : _registerCnibVersoFileName,
            subtitle: "Image JPG ou PNG",
            icon: Icons.credit_card_outlined,
            isLoaded: _registerCnibVersoBytes != null,
            onPressed: () => _pickRegisterCNIB(isRecto: false),
          ),
        ] else ...[
          _buildInputField(
            controller: _societeController,
            hintText: "Nom de la société",
            icon: Icons.business_outlined,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _domaineController,
            hintText: "Domaine d'activité",
            icon: Icons.domain_outlined,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _lieuEntrepriseController,
            hintText: "Ville / Lieu de l'entreprise",
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _telSocieteController,
            hintText: "Numéro de téléphone",
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _emailSocieteController,
            hintText: "Email de contact",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
        const SizedBox(height: 12),
        _buildInputField(
          controller: _passController,
          hintText: "Mot de passe",
          icon: Icons.lock_outline,
          isPassword: true,
        ),
      ],
    );
  }

  Widget _buildDocumentPicker({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isLoaded,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isLoaded ? Colors.green : const Color(0xFF333333), width: 1.5),
      ),
      child: ListTile(
        leading: Icon(isLoaded ? Icons.check_circle : icon, color: isLoaded ? Colors.green : Colors.white70),
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          isLoaded ? "Fichier chargÃ©" : subtitle,
          style: TextStyle(color: isLoaded ? Colors.green : Colors.white54, fontSize: 12),
        ),
        trailing: TextButton(
          onPressed: onPressed,
          child: Text(isLoaded ? "Modifier" : "Importer"),
        ),
      ),
    );
  }

  String _getExtension(String fileName) {
    final lowerName = fileName.toLowerCase();
    final dotIndex = lowerName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == lowerName.length - 1) return '';
    return lowerName.substring(dotIndex + 1);
  }

  Future<void> _pickRegisterCV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _validCvExtensions,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final ext = _getExtension(file.name);
    if (!_validCvExtensions.contains(ext) || file.bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir un CV valide."), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() {
      _registerCvBytes = file.bytes;
      _registerCvFileName = file.name;
    });
  }

  Future<void> _pickRegisterCNIB({required bool isRecto}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _validImageExtensions,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final ext = _getExtension(file.name);
    if (!_validImageExtensions.contains(ext) || file.bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir une image JPG ou PNG."), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() {
      if (isRecto) {
        _registerCnibRectoBytes = file.bytes;
        _registerCnibRectoFileName = file.name;
      } else {
        _registerCnibVersoBytes = file.bytes;
        _registerCnibVersoFileName = file.name;
      }
    });
  }

  Future<Map<String, String>> _uploadRegistrationDocuments() async {
    final urls = <String, String>{};
    if (_registerCvBytes != null) {
      final upload = await ApiService.uploadFileBytes(bytes: _registerCvBytes!, fileName: _registerCvFileName);
      if (upload['success'] != true) throw Exception(upload['message'] ?? "Erreur upload CV");
      urls['cvUrl'] = upload['url']?.toString() ?? '';
    }
    if (_registerCnibRectoBytes != null) {
      final upload = await ApiService.uploadFileBytes(bytes: _registerCnibRectoBytes!, fileName: _registerCnibRectoFileName);
      if (upload['success'] != true) throw Exception(upload['message'] ?? "Erreur upload CNIB recto");
      urls['cnibRectoUrl'] = upload['url']?.toString() ?? '';
    }
    if (_registerCnibVersoBytes != null) {
      final upload = await ApiService.uploadFileBytes(bytes: _registerCnibVersoBytes!, fileName: _registerCnibVersoFileName);
      if (upload['success'] != true) throw Exception(upload['message'] ?? "Erreur upload CNIB verso");
      urls['cnibVersoUrl'] = upload['url']?.toString() ?? '';
    }
    return urls;
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: Icon(icon, color: Colors.white70, size: 20),
          suffixIcon: isPassword
              ? const Icon(Icons.visibility_off, color: Colors.white54, size: 18)
              : null,
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFBF360C),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          shadowColor: Colors.transparent,
        ),
        child: Text(
          isLogin ? "Se connecter" : "S'inscrire",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleAuthButton() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Color(0xFF7A8A99)),
          children: [
            TextSpan(text: isLogin ? "Pas encore de compte ? " : "Déjà un compte ? "),
            TextSpan(
              text: isLogin ? "Inscrivez-vous" : "Connectez-vous",
              style: const TextStyle(
                color: Color(0xFF667eea),
                fontWeight: FontWeight.w600,
              ),
              recognizer: TapGestureRecognizer()..onTap = () => setState(() => isLogin = !isLogin),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAuth() async {
    // Vérifier les champs requis
    if (isLogin) {
      if ((isCandidat ? _emailController.text : _emailSocieteController.text).isEmpty || _passController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs')));
        return;
      }
    } else {
      if (isCandidat) {
        if (_nomController.text.isEmpty || _telController.text.isEmpty || _emailController.text.isEmpty || _ageController.text.isEmpty || _domicileController.text.isEmpty || _filiereController.text.isEmpty || _passController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs')));
          return;
        }
        if (_registerCvBytes == null || _registerCnibRectoBytes == null || _registerCnibVersoBytes == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez importer votre CV et les deux faces de votre CNIB')));
          return;
        }
      } else {
        if (_societeController.text.isEmpty || _telSocieteController.text.isEmpty || _emailSocieteController.text.isEmpty || _domaineController.text.isEmpty || _lieuEntrepriseController.text.isEmpty || _passController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs')));
          return;
        }
      }
    }

    var isLoadingDialogOpen = false;
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
      isLoadingDialogOpen = true;

      if (isLogin) {
        final response = await ApiService.login(
          email: isCandidat ? _emailController.text : _emailSocieteController.text,
          password: _passController.text,
        );

        if (mounted && isLoadingDialogOpen) {
          Navigator.pop(context);
          isLoadingDialogOpen = false;
        }

        if (response['token'] != null) {
          final user = response['user'] ?? {};
          final userType = user['userType']?.toString() ?? 'candidat';
          final Map<String, String> userData = {
            'id': user['id']?.toString() ?? '',
            'email': user['email']?.toString() ?? '',
            'userType': userType,
            'nom': user['nom']?.toString() ?? '',
            'nom_societe': user['nom_societe']?.toString() ?? (userType == 'entreprise' ? user['nom']?.toString() ?? '' : ''),
            'filiere': (user['filiere'] ?? user['filiere_specialite'])?.toString() ?? '',
            'filiere_specialite': user['filiere_specialite']?.toString() ?? '',
            'domaine': user['domaine']?.toString() ?? '',
            'telephone': user['telephone']?.toString() ?? '',
            'adresse': user['adresse']?.toString() ?? '',
            'villeLieu': user['villeLieu']?.toString() ?? '',
            'domicile': (user['domicile'] ?? user['villeLieu'])?.toString() ?? '',
            'sexe': (user['sexe'] ?? user['genre'])?.toString() ?? '',
            'genre': user['genre']?.toString() ?? '',
            'age': user['age']?.toString() ?? '',
            'photo': user['photo']?.toString() ?? '',
            'photoUrl': user['photoUrl']?.toString() ?? '',
                'filiere': _filiereController.text,
                'telephone': _telController.text,
                'sexe': selectedSexe,
                'age': int.tryParse(_ageController.text.split(' ')[0])?.toString() ?? '22',
                'domicile': _domicileController.text,
                'villeLieu': _domicileController.text,
              }
            : {
                'nomSociete': _societeController.text,
                'domaine': _domaineController.text,
                'villeLieu': _lieuEntrepriseController.text,
                'telephone': _telSocieteController.text,
                'description': 'Entreprise partenaire',
                'adresse': _lieuEntrepriseController.text
              };

        final registerResponse = await ApiService.register(
          email: isCandidat ? _emailController.text : _emailSocieteController.text,
          password: _passController.text,
          userType: isCandidat ? 'candidat' : 'entreprise',
          nom: isCandidat ? _nomController.text : _societeController.text,
          extraData: extraData,
        );

        if (registerResponse['success'] == true && registerResponse['token'] != null) {
          final uploadedUrls = isCandidat ? await _uploadRegistrationDocuments() : <String, String>{};
          final originalUser = Map<String, dynamic>.from(registerResponse['user'] ?? {});
          Map<String, dynamic> user = Map<String, dynamic>.from(originalUser);
          if (isCandidat && uploadedUrls.isNotEmpty) {
            final updateResponse = await ApiService.updateProfile(
              nom: _nomController.text,
              telephone: _telController.text,
              filiere: _filiereController.text,
              age: int.tryParse(_ageController.text.split(' ')[0])?.toString() ?? _ageController.text,
              domicile: _domicileController.text,
              sexe: selectedSexe,
              cvUrl: uploadedUrls['cvUrl'],
              cnibRectoUrl: uploadedUrls['cnibRectoUrl'],
              cnibVersoUrl: uploadedUrls['cnibVersoUrl'],
            );
            if (updateResponse['success'] == true) {
              user = Map<String, dynamic>.from(updateResponse['user'] ?? user);
              user['id'] = originalUser['id'];
              user['email'] = originalUser['email'];
              user['userType'] = originalUser['userType'];
            } else {
              throw Exception(updateResponse['message'] ?? "Documents non sauvegardÃ©s");
            }
          }
          if (mounted && isLoadingDialogOpen) {
            Navigator.pop(context);
            isLoadingDialogOpen = false;
          }
          final userType = user['userType']?.toString() ?? 'candidat';
          final Map<String, String> userData = {
            'id': user['id']?.toString() ?? '',
            'email': user['email']?.toString() ?? '',
            'userType': userType,
            'nom': user['nom']?.toString() ?? '',
            'nom_societe': user['nom_societe']?.toString() ?? (userType == 'entreprise' ? user['nom']?.toString() ?? '' : ''),
            'filiere': (user['filiere'] ?? user['filiere_specialite'])?.toString() ?? '',
            'filiere_specialite': user['filiere_specialite']?.toString() ?? '',
            'domaine': user['domaine']?.toString() ?? '',
            'telephone': user['telephone']?.toString() ?? '',
            'adresse': user['adresse']?.toString() ?? '',
            'villeLieu': user['villeLieu']?.toString() ?? '',
            'domicile': (user['domicile'] ?? user['villeLieu'])?.toString() ?? '',
            'sexe': (user['sexe'] ?? user['genre'])?.toString() ?? '',
            'genre': user['genre']?.toString() ?? '',
            'age': user['age']?.toString() ?? '',
            'photo': user['photo']?.toString() ?? '',
            'photoUrl': user['photoUrl']?.toString() ?? '',
            'cvUrl': user['cvUrl']?.toString() ?? '',
            'cnibRectoUrl': user['cnibRectoUrl']?.toString() ?? '',
            'cnibVersoUrl': user['cnibVersoUrl']?.toString() ?? ''
          };

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => userType == 'entreprise' ? CompanyDashboard(initialData: userData) : ProfileConfirmationScreen(userData: userData),
              ),
            );
          }
        } else {
          final String message = registerResponse['message']?.toString() ?? 'Erreur lors de l\'inscription';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted && isLoadingDialogOpen) {
        Navigator.pop(context);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception:', '')), backgroundColor: Colors.red));
      }
    }
  }
}


