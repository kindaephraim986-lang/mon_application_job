import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'candidate_dashboard.dart';
import './company_dashboard_impl.dart';
import 'admin_dashboard_v2.dart';
import 'services/api_service.dart';
import 'utils/cnib_reconnect_helper.dart';
import 'utils/phone_utils_fixed.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  bool isLogin = true;
  bool isCandidat = true;
  bool isAdmin = false;
  bool _obscurePassword = true;
  String selectedSexe = 'Masculin';
  String _selectedCandidateDialCode = '+226';
  String _selectedEntrepriseDialCode = '+226';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telController = TextEditingController();
  final _filiereController = TextEditingController();
  final _ageController = TextEditingController();
  final _domicileController = TextEditingController();
  final _passController = TextEditingController();

  final _adminNomController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPhoneController = TextEditingController();

  final _societeController = TextEditingController();
  final _emailSocieteController = TextEditingController();
  final _domaineController = TextEditingController();
  final _lieuEntrepriseController = TextEditingController();
  final _telSocieteController = TextEditingController();

  final List<Map<String, String>> _countryDialCodes = [
    {'name': 'Burkina Faso', 'dialCode': '+226'},
    {'name': 'Côte d’Ivoire', 'dialCode': '+225'},
    {'name': 'Sénégal', 'dialCode': '+221'},
    {'name': 'Mali', 'dialCode': '+223'},
    {'name': 'France', 'dialCode': '+33'},
    {'name': 'Belgique', 'dialCode': '+32'},
    {'name': 'Canada', 'dialCode': '+1'},
    {'name': 'États-Unis', 'dialCode': '+1'},
    {'name': 'Royaume-Uni', 'dialCode': '+44'},
    {'name': 'Allemagne', 'dialCode': '+49'},
    {'name': 'Espagne', 'dialCode': '+34'},
    {'name': 'Italie', 'dialCode': '+39'},
    {'name': 'Portugal', 'dialCode': '+351'},
    {'name': 'Suisse', 'dialCode': '+41'},
    {'name': 'Pays-Bas', 'dialCode': '+31'},
    {'name': 'Luxembourg', 'dialCode': '+352'},
    {'name': 'Afrique du Sud', 'dialCode': '+27'},
    {'name': 'Nigeria', 'dialCode': '+234'},
    {'name': 'Ghana', 'dialCode': '+233'},
    {'name': 'Kenya', 'dialCode': '+254'},
    {'name': 'Togo', 'dialCode': '+228'},
    {'name': 'Bénin', 'dialCode': '+229'},
    {'name': 'Guinée', 'dialCode': '+224'},
    {'name': 'Niger', 'dialCode': '+227'},
    {'name': 'Mauritanie', 'dialCode': '+222'},
    {'name': 'Algérie', 'dialCode': '+213'},
    {'name': 'Maroc', 'dialCode': '+212'},
    {'name': 'Tunisie', 'dialCode': '+216'},
    {'name': 'Égypte', 'dialCode': '+20'},
    {'name': 'Libye', 'dialCode': '+218'},
    {'name': 'Ethiopie', 'dialCode': '+251'},
    {'name': 'Tanzanie', 'dialCode': '+255'},
    {'name': 'Ouganda', 'dialCode': '+256'},
    {'name': 'Rwanda', 'dialCode': '+250'},
    {'name': 'Cameroun', 'dialCode': '+237'},
    {'name': 'Congo', 'dialCode': '+242'},
    {'name': 'RD Congo', 'dialCode': '+243'},
    {'name': 'Gabon', 'dialCode': '+241'},
    {'name': 'République centrafricaine', 'dialCode': '+236'},
    {'name': 'Tchad', 'dialCode': '+235'},
    {'name': 'Djibouti', 'dialCode': '+253'},
    {'name': 'Comores', 'dialCode': '+269'},
    {'name': 'Madagascar', 'dialCode': '+261'},
    {'name': 'Maurice', 'dialCode': '+230'},
    {'name': 'Seychelles', 'dialCode': '+248'},
    {'name': 'Sao Tomé-et-Principe', 'dialCode': '+239'},
    {'name': 'Cap-Vert', 'dialCode': '+238'},
    {'name': 'Guinée-Bissau', 'dialCode': '+245'},
    {'name': 'Guinée équatoriale', 'dialCode': '+240'},
    {'name': 'Angola', 'dialCode': '+244'},
    {'name': 'Mozambique', 'dialCode': '+258'},
    {'name': 'Zimbabwe', 'dialCode': '+263'},
    {'name': 'Zambie', 'dialCode': '+260'},
    {'name': 'Malawi', 'dialCode': '+265'},
    {'name': 'Botswana', 'dialCode': '+267'},
    {'name': 'Lesotho', 'dialCode': '+266'},
    {'name': 'Namibie', 'dialCode': '+264'},
    {'name': 'Eswatini', 'dialCode': '+268'},
    {'name': 'Somalie', 'dialCode': '+252'},
    {'name': 'Érythrée', 'dialCode': '+291'},
    {'name': 'Soudan', 'dialCode': '+249'},
    {'name': 'Soudan du Sud', 'dialCode': '+211'},
    {'name': 'Liban', 'dialCode': '+961'},
    {'name': 'Jordanie', 'dialCode': '+962'},
    {'name': 'Israël', 'dialCode': '+972'},
    {'name': 'Palestine', 'dialCode': '+970'},
    {'name': 'Arabie saoudite', 'dialCode': '+966'},
    {'name': 'Émirats arabes unis', 'dialCode': '+971'},
    {'name': 'Qatar', 'dialCode': '+974'},
    {'name': 'Koweït', 'dialCode': '+965'},
    {'name': 'Bahreïn', 'dialCode': '+973'},
    {'name': 'Oman', 'dialCode': '+968'},
    {'name': 'Yémen', 'dialCode': '+967'},
    {'name': 'Iran', 'dialCode': '+98'},
    {'name': 'Irak', 'dialCode': '+964'},
    {'name': 'Syrie', 'dialCode': '+963'},
    {'name': 'Turquie', 'dialCode': '+90'},
    {'name': 'Arménie', 'dialCode': '+374'},
    {'name': 'Azerbaïdjan', 'dialCode': '+994'},
    {'name': 'Géorgie', 'dialCode': '+995'},
    {'name': 'Kazakhstan', 'dialCode': '+7'},
    {'name': 'Ouzbékistan', 'dialCode': '+998'},
    {'name': 'Turkménistan', 'dialCode': '+993'},
    {'name': 'Tadjikistan', 'dialCode': '+992'},
    {'name': 'Kirghizstan', 'dialCode': '+996'},
    {'name': 'Russie', 'dialCode': '+7'},
    {'name': 'Ukraine', 'dialCode': '+380'},
    {'name': 'Pologne', 'dialCode': '+48'},
    {'name': 'Tchéquie', 'dialCode': '+420'},
    {'name': 'Slovaquie', 'dialCode': '+421'},
    {'name': 'Hongrie', 'dialCode': '+36'},
    {'name': 'Roumanie', 'dialCode': '+40'},
    {'name': 'Bulgarie', 'dialCode': '+359'},
    {'name': 'Serbie', 'dialCode': '+381'},
    {'name': 'Croatie', 'dialCode': '+385'},
    {'name': 'Slovénie', 'dialCode': '+386'},
    {'name': 'Bosnie-Herzégovine', 'dialCode': '+387'},
    {'name': 'Monténégro', 'dialCode': '+382'},
    {'name': 'Albanie', 'dialCode': '+355'},
    {'name': 'Macédoine du Nord', 'dialCode': '+389'},
    {'name': 'Grèce', 'dialCode': '+30'},
    {'name': 'Chypre', 'dialCode': '+357'},
    {'name': 'Malte', 'dialCode': '+356'},
    {'name': 'Norvège', 'dialCode': '+47'},
    {'name': 'Suède', 'dialCode': '+46'},
    {'name': 'Danemark', 'dialCode': '+45'},
    {'name': 'Finlande', 'dialCode': '+358'},
    {'name': 'Islande', 'dialCode': '+354'},
    {'name': 'Irlande', 'dialCode': '+353'},
    {'name': 'Autriche', 'dialCode': '+43'},
    {'name': 'Brésil', 'dialCode': '+55'},
    {'name': 'Argentine', 'dialCode': '+54'},
    {'name': 'Chili', 'dialCode': '+56'},
    {'name': 'Pérou', 'dialCode': '+51'},
    {'name': 'Colombie', 'dialCode': '+57'},
    {'name': 'Venezuela', 'dialCode': '+58'},
    {'name': 'Mexique', 'dialCode': '+52'},
    {'name': 'Costa Rica', 'dialCode': '+506'},
    {'name': 'Guatemala', 'dialCode': '+502'},
    {'name': 'Salvador', 'dialCode': '+503'},
    {'name': 'Honduras', 'dialCode': '+504'},
    {'name': 'Nicaragua', 'dialCode': '+505'},
    {'name': 'Panama', 'dialCode': '+507'},
    {'name': 'Dominique', 'dialCode': '+1'},
    {'name': 'Jamaïque', 'dialCode': '+1'},
    {'name': 'Haïti', 'dialCode': '+509'},
    {'name': 'Bolivie', 'dialCode': '+591'},
    {'name': 'Paraguay', 'dialCode': '+595'},
    {'name': 'Uruguay', 'dialCode': '+598'},
    {'name': 'Équateur', 'dialCode': '+593'},
    {'name': 'Guyana', 'dialCode': '+592'},
    {'name': 'Suriname', 'dialCode': '+597'},
    {'name': 'Australie', 'dialCode': '+61'},
    {'name': 'Nouvelle-Zélande', 'dialCode': '+64'},
    {'name': 'Papouasie-Nouvelle-Guinée', 'dialCode': '+675'},
    {'name': 'Fidji', 'dialCode': '+679'},
    {'name': 'Indonésie', 'dialCode': '+62'},
    {'name': 'Malaisie', 'dialCode': '+60'},
    {'name': 'Philippines', 'dialCode': '+63'},
    {'name': 'Singapour', 'dialCode': '+65'},
    {'name': 'Thaïlande', 'dialCode': '+66'},
    {'name': 'Vietnam', 'dialCode': '+84'},
    {'name': 'Cambodge', 'dialCode': '+855'},
    {'name': 'Laos', 'dialCode': '+856'},
    {'name': 'Birmanie', 'dialCode': '+95'},
    {'name': 'Inde', 'dialCode': '+91'},
    {'name': 'Pakistan', 'dialCode': '+92'},
    {'name': 'Bangladesh', 'dialCode': '+880'},
    {'name': 'Sri Lanka', 'dialCode': '+94'},
    {'name': 'Népal', 'dialCode': '+977'},
    {'name': 'Bhoutan', 'dialCode': '+975'},
    {'name': 'Maldive', 'dialCode': '+960'},
    {'name': 'Japon', 'dialCode': '+81'},
    {'name': 'Corée du Sud', 'dialCode': '+82'},
    {'name': 'Corée du Nord', 'dialCode': '+850'},
    {'name': 'Chine', 'dialCode': '+86'},
    {'name': 'Taïwan', 'dialCode': '+886'},
    {'name': 'Hong Kong', 'dialCode': '+852'},
    {'name': 'Macao', 'dialCode': '+853'},
    {'name': 'Pakistan', 'dialCode': '+92'},
  ];

  @override
  void initState() {
    super.initState();
    isLogin = false;
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
    _adminNomController.dispose();
    _adminEmailController.dispose();
    _adminPhoneController.dispose();
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
                child: Form(
                  key: _formKey,
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
          _buildTabButton("Candidat", isCandidatTab: true, isAdminTab: false),
          const SizedBox(width: 8),
          _buildTabButton("Entreprise", isCandidatTab: false, isAdminTab: false),
          const SizedBox(width: 8),
          _buildTabButton("Admin", isCandidatTab: false, isAdminTab: true),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, {required bool isCandidatTab, required bool isAdminTab}) {
    bool isSelected = isAdminTab ? isAdmin : (isCandidatTab ? isCandidat : !isCandidat && !isAdmin);
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          if (isAdminTab) {
            isAdmin = true;
            isCandidat = false;
          } else if (isCandidatTab) {
            isAdmin = false;
            isCandidat = true;
          } else {
            isAdmin = false;
            isCandidat = false;
          }
        }),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFBF360C) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
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
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'L’email est requis';
            }
            if (!value.contains('@')) {
              return 'Email invalide';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _passController,
          hintText: "Mot de passe",
          icon: Icons.lock_outline,
          isPassword: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le mot de passe est requis';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    if (isAdmin) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Inscription administrateur désactivée',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Créer un compte admin n’est pas autorisé. Utilisez l’onglet connexion pour vous connecter.',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        if (isCandidat) ...[
          _buildInputField(
            controller: _nomController,
            hintText: "Nom complet",
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le nom est obligatoire';
              }
              if (value.trim().length < 3) {
                return 'Nom trop court';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildPhoneInputField(
            controller: _telController,
            selectedDialCode: _selectedCandidateDialCode,
            onDialCodeChanged: (value) => setState(() => _selectedCandidateDialCode = value),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le téléphone est obligatoire';
              }
              final normalized = value.trim();
              if (!isValidPhoneNumber(normalized)) {
                return 'Téléphone invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _ageController,
            hintText: "Âge",
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'L’âge est requis';
              }
              final age = int.tryParse(value);
              if (age == null || age < 18 || age > 65) {
                return 'L’âge doit être entre 18 et 65';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _domicileController,
            hintText: "Lieu de résidence",
            icon: Icons.location_on_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le domicile est obligatoire';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _filiereController,
            hintText: "Filière / Spécialité",
            icon: Icons.school_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La filière est obligatoire';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _emailController,
            hintText: "Adresse email",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'L’email est requis';
              }
              if (!value.contains('@')) {
                return 'Email invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
        ] else ...[
          _buildInputField(
            controller: _societeController,
            hintText: "Nom de la société",
            icon: Icons.business_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le nom de la société est obligatoire';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _domaineController,
            hintText: "Domaine d'activité",
            icon: Icons.domain_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le domaine est obligatoire';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _lieuEntrepriseController,
            hintText: "Ville / Lieu de l'entreprise",
            icon: Icons.location_on_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La ville / lieu est obligatoire';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildPhoneInputField(
            controller: _telSocieteController,
            selectedDialCode: _selectedEntrepriseDialCode,
            onDialCodeChanged: (value) => setState(() => _selectedEntrepriseDialCode = value),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le téléphone est obligatoire';
              }
              final normalized = value.trim();
              if (!isValidPhoneNumber(normalized)) {
                return 'Téléphone invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _emailSocieteController,
            hintText: "Email de contact",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'L’email est requis';
              }
              if (!value.contains('@')) {
                return 'Email invalide';
              }
              return null;
            },
          ),
        ],
        const SizedBox(height: 12),
        _buildInputField(
          controller: _passController,
          hintText: "Mot de passe",
          icon: Icons.lock_outline,
          isPassword: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le mot de passe est requis';
            }
            if (value.trim().length < 6) {
              return 'Le mot de passe doit contenir au moins 6 caractères';
            }
            return null;
          },
        ),
      ],
    );
  }



  Widget _buildPhoneInputField({
    required TextEditingController controller,
    required String selectedDialCode,
    required ValueChanged<String> onDialCodeChanged,
    required String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333), width: 1.5),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedDialCode,
                dropdownColor: const Color(0xFF1A1A1A),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                items: _countryDialCodes.map((country) {
                  return DropdownMenuItem<String>(
                    value: country['dialCode'],
                    child: Text('${country['dialCode']} ${country['name']}', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onDialCodeChanged(value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.phone,
              validator: validator,
              decoration: const InputDecoration(
                hintText: 'Numéro de téléphone',
                hintStyle: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                errorStyle: TextStyle(color: Colors.redAccent, fontSize: 12),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333), width: 1.5),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: Icon(icon, color: Colors.white70, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  splashRadius: 18,
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white54,
                    size: 18,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
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
        onPressed: isAdmin && !isLogin ? null : _handleAuth,
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
      child: TextButton(
        onPressed: () => setState(() => isLogin = !isLogin),
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF7A8A99)),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPhoneNumber(String rawPhone, String dialCode) {
    final digits = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    return '$dialCode$digits';
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez corriger les erreurs du formulaire'), backgroundColor: Colors.red));
      return;
    }

    if (!isLogin && isAdmin) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Inscription administrateur désactivée. Utilisez l’onglet connexion.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    

    var isLoadingDialogOpen = false;
    try {
      if (!mounted) return;
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

        if (!mounted) return;
        if (isLoadingDialogOpen) {
          Navigator.pop(context);
          isLoadingDialogOpen = false;
        }

        if (response['token'] != null) {
          final user = response['user'] ?? {};
          final userType = user['userType']?.toString().toLowerCase() ?? 'candidat';
          final prefs = await SharedPreferences.getInstance();
          final persistedRecto = prefs.getString('cnib_recto_url')?.trim() ?? '';
          final persistedVerso = prefs.getString('cnib_verso_url')?.trim() ?? '';
          final resolvedCnibRecto = resolveCnibUrl(
            userValue: user['cnibRectoUrl']?.toString(),
            initialValue: user['cnib_recto_url']?.toString(),
            persistedValue: persistedRecto,
          );
          final resolvedCnibVerso = resolveCnibUrl(
            userValue: user['cnibVersoUrl']?.toString(),
            initialValue: user['cnib_verso_url']?.toString(),
            persistedValue: persistedVerso,
          );
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
            'photo': user['photo']?.toString() ?? '',
            'age': user['age']?.toString() ?? '',
            'cvUrl': user['cvUrl']?.toString() ?? '',
            'cnibRectoUrl': resolvedCnibRecto,
            'cnibVersoUrl': resolvedCnibVerso,
          };

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                  if (userType == 'admin') {
                    return const AdminDashboard();
                } else if (userType == 'entreprise') {
                  return CompanyDashboard(initialData: userData);
                } else {
                  return CandidateDashboard(initialData: userData);
                }
              },
            ),
          );
        } else {
          final String message = response['message']?.toString() ?? 'Échec de la connexion';
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      } else {
        // INSCRIPTION
        final Map<String, dynamic> extraData = {};
        final normalizedCandidatePhone = _formatPhoneNumber(_telController.text, _selectedCandidateDialCode);
        final normalizedEntreprisePhone = _formatPhoneNumber(_telSocieteController.text, _selectedEntrepriseDialCode);

        if (isCandidat) {
          extraData.addAll({
            'nom': _nomController.text,
            'filiere': _filiereController.text,
            'telephone': normalizedCandidatePhone,
            'sexe': selectedSexe,
            'age': int.tryParse(_ageController.text.split(' ')[0])?.toString() ?? '22',
            'domicile': _domicileController.text,
            'villeLieu': _domicileController.text,
          });
        } else {
          extraData.addAll({
            'nomSociete': _societeController.text,
            'domaine': _domaineController.text,
            'villeLieu': _lieuEntrepriseController.text,
            'telephone': normalizedEntreprisePhone,
            'description': 'Entreprise partenaire',
            'adresse': _lieuEntrepriseController.text,
          });
        }

        final registerResponse = await ApiService.register(
          email: isCandidat ? _emailController.text : _emailSocieteController.text,
          password: _passController.text,
          userType: isCandidat ? 'candidat' : 'entreprise',
          nom: isCandidat ? _nomController.text : _societeController.text,
          telephone: isCandidat ? normalizedCandidatePhone : normalizedEntreprisePhone,
          filiere: isCandidat ? _filiereController.text : null,
          age: isCandidat ? int.tryParse(_ageController.text.split(' ')[0])?.toString() ?? _ageController.text : null,
          sexe: isCandidat ? selectedSexe : null,
          domicile: isCandidat ? _domicileController.text : null,
          extraData: extraData,
        );

        if (!mounted) return;
        if (registerResponse['success'] == true && registerResponse['token'] != null) {
          final uploadedUrls = <String, String>{};
          final originalUser = Map<String, dynamic>.from(registerResponse['user'] ?? {});
          Map<String, dynamic> user = Map<String, dynamic>.from(originalUser);
          if (isCandidat && uploadedUrls.isNotEmpty) {
            final updateResponse = await ApiService.updateProfile(
              nom: _nomController.text,
              telephone: normalizedCandidatePhone,
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
              throw Exception(updateResponse['message'] ?? "Documents non sauvegardés");
            }
          }
          if (!mounted) return;
          if (isLoadingDialogOpen) {
            Navigator.pop(context);
            isLoadingDialogOpen = false;
          }
          final userType = user['userType']?.toString().toLowerCase() ?? 'candidat';
          final prefs = await SharedPreferences.getInstance();
          final persistedRecto = prefs.getString('cnib_recto_url')?.trim() ?? '';
          final persistedVerso = prefs.getString('cnib_verso_url')?.trim() ?? '';
          final resolvedCnibRecto = resolveCnibUrl(
            userValue: user['cnibRectoUrl']?.toString(),
            initialValue: user['cnib_recto_url']?.toString(),
            persistedValue: persistedRecto,
          );
          final resolvedCnibVerso = resolveCnibUrl(
            userValue: user['cnibVersoUrl']?.toString(),
            initialValue: user['cnib_verso_url']?.toString(),
            persistedValue: persistedVerso,
          );
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
            'photo': user['photo']?.toString() ?? '',
            'age': user['age']?.toString() ?? '',
            'cvUrl': user['cvUrl']?.toString() ?? '',
            'cnibRectoUrl': resolvedCnibRecto,
            'cnibVersoUrl': resolvedCnibVerso,
          };

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                  if (userType == 'admin') {
                    return const AdminDashboard();
                } else if (userType == 'entreprise') {
                  return CompanyDashboard(initialData: userData);
                } else {
                  return CandidateDashboard(initialData: userData);
                }
              },
            ),
          );
        } else {
          final String message = registerResponse['message']?.toString() ?? 'Erreur lors de l\'inscription';
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      if (isLoadingDialogOpen) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception:', '')), backgroundColor: Colors.red));
    }
  }
}




