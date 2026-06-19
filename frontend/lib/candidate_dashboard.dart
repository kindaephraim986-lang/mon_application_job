import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'notification_service.dart';
import 'chat_service.dart';
import 'profile_image_helper.dart';
import 'candidature_service.dart';
import 'services/api_service.dart';
import 'payment_service.dart';
import 'utils/logger.dart';
import 'subscription_service.dart';

class CandidateDashboard extends StatefulWidget {
  final Map<String, String> initialData;
  const CandidateDashboard({Key? key, required this.initialData}) : super(key: key);

  @override
  State<CandidateDashboard> createState() => _CandidateDashboardState();
}

class _CandidateDashboardState extends State<CandidateDashboard> {
  int _selectedIndex = 0;
  int _notificationCount = 0;
  int _unreadMessagesCount = 0;
  late Map<String, String> candidatData;
  bool _hasMonthlyPass = false;

  // Parcourir par filière
  String _selectedField = '';
  List<Map<String, String>> _offersByField = [];
  bool _isLoadingOffers = false;

  static const List<String> popularFields = [
    'Informatique',
    'Ingénierie',
    'Ventes',
    'Marketing',
    'Ressources Humaines',
    'Finance',
    'Comptabilité',
    'Santé',
    'Éducation',
    'Droit',
    'Agriculture',
    'Construction',
    'Transport',
    'Logistique',
    'Tourisme',
    'Hôtellerie',
    'Restauration',
    'Artisanat',
    'Commerce',
    'Services',
    'Télécommunications',
    'Énergie',
    'Environnement',
    'Média',
    'Divertissement',
  ];

  List<String> _availableFields = [];

  String get _candidateEmail => candidatData['email'] ?? '';
  String get _candidateNom => candidatData['nom'] ?? 'Candidat';
  String get _candidateFiliere => _firstCandidateValue(['filiere', 'filiere_specialite']);
  String get _candidateSexe => _firstCandidateValue(['sexe', 'genre']);
  String get _candidateAge => _firstCandidateValue(['age']);
  String get _candidateDomicile => _firstCandidateValue(['domicile', 'villeLieu']);

  static const List<String> _validCvExtensions = ['pdf', 'doc', 'docx'];
  // Fichiers
  Uint8List? _cvBytes;
  String _cvFileName = '';
  Uint8List? _cnibRectoBytes;
  String _cnibRectoFileName = '';
  Uint8List? _cnibVersoBytes;
  String _cnibVersoFileName = '';

  String _firstCandidateValue(List<String> keys) {
    for (final key in keys) {
      final value = candidatData[key]?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return 'Non spécifié';
  }

  @override
  void initState() {
    super.initState();
    candidatData = widget.initialData;
    _refreshCounts();
    _checkMonthlyPass();
    _loadCandidateApplications();
    _loadAvailableFields();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    final user = await ApiService.getCurrentUser();
    if (!mounted || user == null) return;
    setState(() {
      candidatData.addAll({
        'id': user['id']?.toString() ?? candidatData['id'] ?? '',
        'email': user['email']?.toString() ?? candidatData['email'] ?? '',
        'userType': user['userType']?.toString() ?? candidatData['userType'] ?? 'candidat',
        'nom': user['nom']?.toString() ?? candidatData['nom'] ?? '',
        'telephone': user['telephone']?.toString() ?? candidatData['telephone'] ?? '',
        'filiere': (user['filiere'] ?? user['filiere_specialite'])?.toString() ?? candidatData['filiere'] ?? '',
        'age': user['age']?.toString() ?? candidatData['age'] ?? '',
        'domicile': (user['domicile'] ?? user['villeLieu'])?.toString() ?? candidatData['domicile'] ?? '',
        'sexe': (user['sexe'] ?? user['genre'])?.toString() ?? candidatData['sexe'] ?? '',
        'cvUrl': user['cvUrl']?.toString() ?? candidatData['cvUrl'] ?? '',
        'cnibRectoUrl': user['cnibRectoUrl']?.toString() ?? candidatData['cnibRectoUrl'] ?? '',
        'cnibVersoUrl': user['cnibVersoUrl']?.toString() ?? candidatData['cnibVersoUrl'] ?? '',
      });
    });
  }

  Future<void> _loadAvailableFields() async {
    try {
      final list = await ApiService.getFields();
      if (list.isEmpty) {
        // fallback to popular hardcoded list
        setState(() => _availableFields = popularFields);
      } else {
        setState(() => _availableFields = list);
      }
    } catch (e) {
      setState(() => _availableFields = popularFields);
    }
  }

  Future<void> _checkMonthlyPass() async {
    final email = candidatData['email'] ?? '';
    if (email.isEmpty) return;
    final has = await SubscriptionService.hasCandidateMonthlyPass(email);
    final remainingDays = await SubscriptionService.getRemainingDaysForCandidate(email);
    setState(() {
      _hasMonthlyPass = has;
    });
    if (has && remainingDays > 0 && remainingDays <= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ Votre forfait expire dans $remainingDays jours"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _loadCandidateApplications() async {
    try {
      final email = candidatData['email'] ?? '';
      final nom = candidatData['nom'] ?? 'Candidat';
      if (email.isEmpty) return;

      final applications = await ApiService.getMyApplications();
      if (applications.isEmpty) return;

      for (final app in applications) {
        final existing = CandidatureService().aDejaPostule(
          email,
          app['titre']?.toString() ?? '',
          app['nom_societe']?.toString() ?? '',
        );
        if (existing) continue;

        CandidatureService().addCandidature(
          Candidature(
            id: app['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            offreTitre: app['titre']?.toString() ?? 'Offre',
            entreprise: app['nom_societe']?.toString() ?? 'Entreprise',
            datePostulation: DateTime.tryParse(app['date_postulation']?.toString() ?? '') ?? DateTime.now(),
            statut: app['statut']?.toString() ?? 'En cours',
            candidatEmail: email,
            candidatNom: nom,
            candidatTel: candidatData['telephone'] ?? '',
            candidatEmailContact: email,
            photoBytes: null,
            cvBytes: null,
            cnibRectoBytes: null,
            cnibVersoBytes: null,
          ),
        );
      }
      setState(() {});
    } catch (error) {
      Logger.error('Échec du chargement des candidatures : $error');
    }
  }

  Future<void> _refreshCounts() async {
    final email = candidatData['email'] ?? '';
    if (email.isEmpty) return;
    final unread = await ChatService.getTotalUnreadForCandidate(email);
    setState(() {
      _notificationCount = NotificationService.candidatCount;
      _unreadMessagesCount = unread;
    });
  }

  bool _isValidImageBytes(Uint8List bytes) {
    if (bytes.lengthInBytes < 8) return false;
    final header = bytes.sublist(0, 8);
    final jpgHeader = [0xFF, 0xD8, 0xFF];
    final pngHeader = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    if (header.length >= jpgHeader.length && const ListEquality().equals(header.sublist(0, jpgHeader.length), jpgHeader)) {
      return true;
    }
    return const ListEquality().equals(header, pngHeader);
  }

  bool _isValidCNIBImage(Uint8List bytes) {
    // Vérifier que c'est une vrai image
    if (!_isValidImageBytes(bytes)) return false;
    
    // Vérifier la taille approximative (CNIB en photo n'est pas énorme)
    // Entre 50KB et 10MB raisonnable
    final sizeInKB = bytes.lengthInBytes / 1024;
    if (sizeInKB < 50 || sizeInKB > 10000) {
      return false;
    }
    
    return true;
  }

  bool _isValidCvBytes(Uint8List bytes, String ext) {
    final lowerExt = ext.toLowerCase();
    if (lowerExt == 'pdf') {
      return bytes.lengthInBytes >= 4 && String.fromCharCodes(bytes.sublist(0, 4)) == '%PDF';
    }
    if (lowerExt == 'docx') {
      final zipHeader = [0x50, 0x4B, 0x03, 0x04];
      return bytes.lengthInBytes >= 4 && const ListEquality().equals(bytes.sublist(0, 4), zipHeader);
    }
    if (lowerExt == 'doc') {
      final oleHeader = [0xD0, 0xCF, 0x11, 0xE0];
      return bytes.lengthInBytes >= 4 && const ListEquality().equals(bytes.sublist(0, 4), oleHeader);
    }
    return false;
  }

  bool _isFormationDocument(String fileName) {
    final forbiddenKeywords = [
      'diplôme', 'diploma', 'certificat', 'certificate', 'attestation',
      'degree', 'baccalauréat', 'licence', 'master', 'bac', 'coursera',
      'udemy', 'formation', 'course', 'training', 'grade', 'transcript',
      'relevé', 'marks', 'score', 'notes'
    ];
    
    final lowerFileName = fileName.toLowerCase();
    for (final keyword in forbiddenKeywords) {
      if (lowerFileName.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _importCV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _validCvExtensions,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun fichier sélectionné")),
        );
        return;
      }

      final file = result.files.first;
      final ext = _getExtension(file.name);
      if (!_validCvExtensions.contains(ext)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Format non accepté. Utilisez PDF, DOC ou DOCX.")),
        );
        return;
      }

      // Vérifier que ce n'est pas un document de formation
      if (_isFormationDocument(file.name)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ Ceci semble être un diplôme ou certificat, pas un CV professionnel. Sélectionnez votre CV."),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      Uint8List? bytes = file.bytes;
      if (bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible de lire le fichier sélectionné.")),
        );
        return;
      }

      if (!_isValidCvBytes(bytes, ext)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fichier CV invalide. Sélectionnez un PDF, DOC ou DOCX réel.")),
        );
        return;
      }

      // Vérifier la taille raisonnable (CV entre 20KB et 10MB)
      final sizeInKB = bytes.lengthInBytes / 1024;
      if (sizeInKB < 20 || sizeInKB > 10000) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("La taille du fichier semble anormale (${sizeInKB.toStringAsFixed(0)} KB). Vérifiez votre CV."),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        _cvBytes = bytes;
        _cvFileName = file.name;
      });
      await _saveProfileDocument(bytes: bytes, fileName: file.name, urlField: 'cvUrl');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✓ CV importé avec succès"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'import du CV : $e")),
      );
    }
  }

  Future<void> _pickCNIBRecto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun fichier sélectionné pour le recto de la CNIB")),
        );
        return;
      }

      final bytes = await image.readAsBytes();
      if (!_isValidImageBytes(bytes)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fichier CNIB invalide. Sélectionnez une image JPG ou PNG réelle.")),
        );
        return;
      }

      if (!_isValidCNIBImage(bytes)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("L'image semble trop petite ou corrompue. Assurez-vous que la CNIB est bien lisible.")),
        );
        return;
      }

      setState(() {
        _cnibRectoBytes = bytes;
        _cnibRectoFileName = image.name;
      });
      await _saveProfileDocument(bytes: bytes, fileName: image.name, urlField: 'cnibRectoUrl');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✓ Recto CNIB importé avec succès")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur import recto CNIB : $e")),
      );
    }
  }

  Future<void> _pickCNIBVerso() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun fichier sélectionné pour le verso de la CNIB")),
        );
        return;
      }

      final bytes = await image.readAsBytes();
      if (!_isValidImageBytes(bytes)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fichier CNIB invalide. Sélectionnez une image JPG ou PNG réelle.")),
        );
        return;
      }

      if (!_isValidCNIBImage(bytes)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("L'image semble trop petite ou corrompue. Assurez-vous que la CNIB est bien lisible.")),
        );
        return;
      }

      setState(() {
        _cnibVersoBytes = bytes;
        _cnibVersoFileName = image.name;
      });
      await _saveProfileDocument(bytes: bytes, fileName: image.name, urlField: 'cnibVersoUrl');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✓ Verso CNIB importé avec succès")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur import verso CNIB : $e")),
      );
    }
  }

  void _showImageDialog(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.memory(imageBytes, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _previewCVFromProfil() async {
    if (_cvBytes == null || _cvFileName.isEmpty) return;
    final ext = _getExtension(_cvFileName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aperçu non supporté'),
        content: Text(
          ext != 'pdf'
              ? 'Seul le format PDF peut être visualisé directement. Votre fichier est en format $ext.'
              : (kIsWeb
                  ? 'La visualisation PDF n’est pas disponible dans la version Web. Téléchargez votre CV localement pour le consulter.'
                  : 'Aperçu PDF non disponible actuellement dans cette version.'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }

  String _getExtension(String fileName) {
    final lowerName = fileName.toLowerCase();
    final dotIndex = lowerName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == lowerName.length - 1) return '';
    return lowerName.substring(dotIndex + 1);
  }

  Future<void> _saveProfileDocument({
    required Uint8List bytes,
    required String fileName,
    required String urlField,
  }) async {
    final upload = await ApiService.uploadFileBytes(bytes: bytes, fileName: fileName);
    if (upload['success'] != true) {
      throw Exception(upload['message'] ?? 'Upload impossible');
    }

    final url = upload['url']?.toString() ?? '';
    final result = await ApiService.updateProfile(
      nom: candidatData['nom'] ?? '',
      telephone: candidatData['telephone'],
      filiere: candidatData['filiere'] ?? candidatData['filiere_specialite'],
      age: candidatData['age'],
      domicile: candidatData['domicile'] ?? candidatData['villeLieu'],
      sexe: candidatData['sexe'] ?? candidatData['genre'],
      cvUrl: urlField == 'cvUrl' ? url : null,
      cnibRectoUrl: urlField == 'cnibRectoUrl' ? url : null,
      cnibVersoUrl: urlField == 'cnibVersoUrl' ? url : null,
    );
    if (result['success'] != true) {
      throw Exception(result['message'] ?? 'Sauvegarde impossible');
    }
    setState(() => candidatData[urlField] = url);
  }

  bool _aDejaPostule(String offreTitre, String entreprise) {
    final email = _candidateEmail;
    if (email.isEmpty) return false;
    return CandidatureService().aDejaPostule(email, offreTitre, entreprise);
  }

  Future<void> _ajouterCandidature(Candidature nouvelle) async {
    // Vérifier si une candidature identique existe déjà
    final existeDeja = CandidatureService().getCandidaturesForCandidate(_candidateEmail).any(
      (c) => c.offreTitre == nouvelle.offreTitre && c.entreprise == nouvelle.entreprise,
    );

    if (existeDeja) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vous avez déjà postulé à cette offre"), backgroundColor: Colors.orange),
      );
      return;
    }

    CandidatureService().addCandidature(nouvelle);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Candidature envoyée pour ${nouvelle.offreTitre}"), backgroundColor: Colors.green),
    );
    NotificationService.notifyCompany(
      "Nouvelle candidature de $_candidateNom pour l'offre ${nouvelle.offreTitre}",
    );
    setState(() {});
    _refreshCounts();
  }
  
  void _retirerCandidature(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Retirer la candidature"),
        content: const Text("Voulez-vous vraiment retirer cette candidature ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(
            onPressed: () {
              CandidatureService().removeCandidature(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Candidature retirée avec succès")),
              );
              setState(() {});
              _refreshCounts();
            },
            child: const Text("Retirer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      body: Row(
        children: [
          Material(
            color: Colors.blue[900],
            child: SizedBox(
              width: 280,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const ProfileImagePicker(),
                  const SizedBox(height: 15),
                  Text(
                    _candidateNom,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    _candidateFiliere,
                    style: TextStyle(color: Colors.blue[100], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildMenuItem(0, Icons.person, "Mon Profil"),
                        _buildMenuItem(1, Icons.search, "Mes Offres"),
                        _buildMenuItem(8, Icons.filter_list, "Parcourir par Filière"),
                        _buildMenuItem(2, Icons.dashboard, "Mon Tableau de bord"),
                        _buildMenuItem(3, Icons.lightbulb, "Conseils"),
                        _buildMenuItem(7, Icons.payment, "Mon abonnement"),
                        _buildMenuItem(4, Icons.contact_mail, "Contact"),
                        _buildMenuItem(5, Icons.chat, "Messages", count: _unreadMessagesCount),
                        _buildMenuItem(6, Icons.notifications, "Notifications", count: _notificationCount),
                        const Divider(color: Colors.white24, height: 20),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBF360C),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.logout, color: Colors.white),
                              SizedBox(width: 8),
                              Text("Déconnexion", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: _buildMainContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title, {int count = 0}) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.white : Colors.blue[200]),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.blue[100],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: count > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
              child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12)),
            )
          : null,
      tileColor: isSelected ? Colors.blue[800] : Colors.transparent,
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 6) {
          NotificationService.resetCandidateCount();
          _refreshCounts();
        }
      },
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildMonProfil();
      case 1:
        return _buildRechercheOffres();
      case 8:
        return _buildBrowseByField();
      case 2:
        return _buildDashboard();
      case 3:
        return _buildConseils();
      case 7:
        return _buildSubscriptionPage();
      case 4:
        return _buildContact();
      case 5:
        return _buildMessagesList();
      case 6:
        return _buildNotificationsContent();
      default:
        return _buildMonProfil();
    }
  }

  Widget _buildSubscriptionPage() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Abonnement candidat", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900])),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _hasMonthlyPass ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _hasMonthlyPass ? Colors.green : Colors.orange),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_hasMonthlyPass ? Icons.check_circle : Icons.warning,
                          color: _hasMonthlyPass ? Colors.green : Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        _hasMonthlyPass ? "Forfait actif" : "Aucun forfait actif",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _hasMonthlyPass ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_hasMonthlyPass) ...[
                    FutureBuilder<int>(
                      future: _candidateEmail.isNotEmpty ? SubscriptionService.getRemainingDaysForCandidate(_candidateEmail) : Future.value(0),
                      builder: (context, snapshot) {
                        final days = snapshot.data ?? 0;
                        return Text("📅 Jours restants : $days jours");
                      },
                    ),
                    const Text("✅ Candidatures illimitées"),
                  ] else ...[
                    const Text("⚠️ Chaque candidature coûte 500 FCFA"),
                    const Text("💡 Forfait mensuel à 1000 FCFA pour candidatures illimitées"),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    "🔧 Mode simulation - Aucun paiement réel",
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton.icon(
              onPressed: _hasMonthlyPass || _candidateEmail.isEmpty ? null : () async {
                final success = await PaymentService.payCandidateMonthly(context, _candidateEmail);
                if (success) await _checkMonthlyPass();
              },
              icon: const Icon(Icons.payment),
              label: const Text("Acheter le forfait illimité (1000 FCFA / mois)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            
            if (_hasMonthlyPass) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_candidateEmail.isEmpty) return;
                  await SubscriptionService.resetSubscription(_candidateEmail, 'candidate');
                  await _checkMonthlyPass();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Abonnement réinitialisé pour test")),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Réinitialiser (test)"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ================== MON PROFIL ==================
  Widget _buildMonProfil() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mon Profil Professionnel", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900])),
            const Divider(height: 30),
            Expanded(
              child: ListView(
                children: [
                  _buildProfileRow("Nom Complet", _firstCandidateValue(['nom'])),
                  _buildProfileRow("Téléphone", _firstCandidateValue(['telephone'])),
                  _buildProfileRow("Adresse Email", _firstCandidateValue(['email'])),
                  _buildProfileRow("Filière / Spécialité", _candidateFiliere),
                  _buildProfileRow("Sexe", _candidateSexe),
                  _buildProfileRow("Âge", _candidateAge),
                  _buildProfileRow("Lieu de résidence", _candidateDomicile),
                  const Divider(height: 20),
                  const Text("Curriculum Vitae (CV)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _importCV,
                        icon: const Icon(Icons.upload_file),
                        label: const Text("Importer mon CV"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
                      ),
                      const SizedBox(width: 12),
                      if (_cvFileName.isNotEmpty)
                        Expanded(
                          child: GestureDetector(
                            onTap: _cvBytes != null ? () => _previewCVFromProfil() : null,
                            child: Text(
                              _cvFileName,
                              style: const TextStyle(fontSize: 14, color: Colors.green, decoration: TextDecoration.underline),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (_cvBytes != null) const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text("✓ CV chargé", style: TextStyle(color: Colors.green, fontSize: 12)),
                  ),
                  const Divider(height: 20),
                  const Text("CNIB (Recto / Verso)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickCNIBRecto,
                        icon: const Icon(Icons.upload_file),
                        label: const Text("Importer recto"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
                      ),
                      const SizedBox(width: 12),
                      if (_cnibRectoFileName.isNotEmpty)
                        Expanded(
                          child: GestureDetector(
                            onTap: _cnibRectoBytes != null ? () => _showImageDialog(_cnibRectoBytes!) : null,
                            child: Text(
                              _cnibRectoFileName,
                              style: const TextStyle(fontSize: 14, color: Colors.green, decoration: TextDecoration.underline),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickCNIBVerso,
                        icon: const Icon(Icons.upload_file),
                        label: const Text("Importer verso"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
                      ),
                      const SizedBox(width: 12),
                      if (_cnibVersoFileName.isNotEmpty)
                        Expanded(
                          child: GestureDetector(
                            onTap: _cnibVersoBytes != null ? () => _showImageDialog(_cnibVersoBytes!) : null,
                            child: Text(
                              _cnibVersoFileName,
                              style: const TextStyle(fontSize: 14, color: Colors.green, decoration: TextDecoration.underline),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (_cnibRectoBytes != null || _cnibVersoBytes != null)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text("✓ CNIB chargée (cliquer sur le nom pour visualiser)", style: TextStyle(color: Colors.green, fontSize: 12)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== ÉDITION PROFIL ==================

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 3, child: Text(value, style: TextStyle(fontSize: 16, color: Colors.blue[900], fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  // ================== TABLEAU DE BORD ==================
  Widget _buildDashboard() {
    final candidatures = CandidatureService().getCandidaturesForCandidate(_candidateEmail);
    int enCours = candidatures.where((c) => c.statut == "En cours").length;
    int acceptees = candidatures.where((c) => c.statut == "Acceptée").length;
    int refusees = candidatures.where((c) => c.statut == "Refusée").length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Suivi de mes candidatures", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900])),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildStatCard("Total", candidatures.length.toString(), Icons.description, Colors.blue),
            const SizedBox(width: 12),
            _buildStatCard("En cours", enCours.toString(), Icons.hourglass_empty, Colors.orange),
            const SizedBox(width: 12),
            _buildStatCard("Acceptées", acceptees.toString(), Icons.check_circle, Colors.green),
            const SizedBox(width: 12),
            _buildStatCard("Refusées", refusees.toString(), Icons.cancel, Colors.red),
          ],
        ),
        const SizedBox(height: 25),
        const Text("Détail des candidatures", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Expanded(
          child: candidatures.isEmpty
              ? const Center(child: Text("Aucune candidature pour le moment. Allez dans 'Mes Offres' pour postuler."))
              : ListView.builder(
                  itemCount: candidatures.length,
                  itemBuilder: (context, index) {
                    final c = candidatures[index];
                    Color statutColor;
                    IconData statutIcon;
                    switch (c.statut) {
                      case "Acceptée":
                        statutColor = Colors.green;
                        statutIcon = Icons.check_circle;
                        break;
                      case "Refusée":
                        statutColor = Colors.red;
                        statutIcon = Icons.cancel;
                        break;
                      default:
                        statutColor = Colors.orange;
                        statutIcon = Icons.hourglass_empty;
                    }
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(statutIcon, color: statutColor, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    c.offreTitre,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statutColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    c.statut,
                                    style: TextStyle(color: statutColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text("Entreprise : ${c.entreprise}"),
                            Text("Postulé le : ${_formatDate(c.datePostulation)}"),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => _retirerCandidature(c.id),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text("Retirer ma candidature"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade100,
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2), spreadRadius: 0)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  // ================== LISTE DES OFFRES ==================
  Widget _buildRechercheOffres() {
    List<Map<String, dynamic>> offresMisesAJour = CandidatureService().offresGlobales;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Offres de stages & d'emplois disponibles", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900])),
        const SizedBox(height: 20),
        if (!_hasMonthlyPass)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.shade700),
            ),
            child: const Text(
              "Abonnement requis pour accéder aux informations de l'entreprise. Activez votre forfait pour contacter et voir les coordonnées.",
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
        Expanded(
          child: offresMisesAJour.isEmpty 
          ? const Center(child: Text("Aucune offre disponible pour le moment."))
          : ListView.builder(
            itemCount: offresMisesAJour.length,
            itemBuilder: (context, index) {
              final o = offresMisesAJour[index];
              final dejaPostule = _aDejaPostule(o['titre']?.toString() ?? '', o['entreprise']?.toString() ?? '');
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: o['logoBytes'] != null
                      ? CircleAvatar(backgroundImage: MemoryImage(o['logoBytes']))
                      : const CircleAvatar(child: Icon(Icons.business)),
                  title: Text(o['titre']?.toString() ?? 'Offre', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(_hasMonthlyPass ? "${o['entreprise']} - ${o['lieu']} (${o['typeContrat']})" : "Abonnement requis pour voir les informations de l'entreprise"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!dejaPostule)
                        ElevatedButton(
                          onPressed: () {
                            Map<String, String> offreData = {
                              'id': o['id'].toString(),
                              'titre': o['titre'].toString(),
                              'poste': o['titre'].toString(),
                              'entreprise': o['entreprise'].toString(),
                            };
                            _openPostulationForm(context, offre: offreData);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text("Postuler"),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text("Déjà postulé", style: TextStyle(color: Colors.grey)),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _hasMonthlyPass && _candidateEmail.isNotEmpty
                            ? () async {
                                await ChatService.getOrCreateConversationForCandidate(_candidateEmail, o['entreprise']?.toString() ?? '');
                                NotificationService.notifyCompany("Le candidat $_candidateNom a initié un chat avec vous.");
                                setState(() => _selectedIndex = 5);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasMonthlyPass ? Colors.blue : Colors.grey,
                        ),
                        child: const Text("Contacter"),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openPostulationForm(BuildContext context, {required Map<String, String> offre}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PostulationFormDialog(
          offre: offre,
          candidatEmail: _candidateEmail,
          candidatNom: _candidateNom,
          candidatTel: candidatData['telephone'] ?? '',
          onValidate: (nom, telephone, email, photoBytes, cvBytes, cnibRecto, cnibVerso) async {
            Navigator.of(dialogContext).pop();

            final candidateEmail = _candidateEmail;
            if (candidateEmail.isEmpty) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Email du candidat manquant."), backgroundColor: Colors.red),
              );
              return;
            }

            final bool paymentSuccess = _hasMonthlyPass
                ? true
                : await PaymentService.payCandidatePerApplication(
                    context,
                    candidateEmail,
                    offre['titre'] ?? 'Offre',
                  );

            if (!paymentSuccess) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("❌ Paiement échoué."), backgroundColor: Colors.red),
              );
              return;
            }

            await _creerEtAjouterCandidature(
              nom,
              telephone,
              email,
              photoBytes,
              cvBytes,
              cnibRecto,
              cnibVerso,
              offre,
            );
          },
        );
      },
    );
  }

  Widget _buildBrowseByField() {
    if (_selectedField.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 28),
                onPressed: () => setState(() => _selectedField = ''),
              ),
              const SizedBox(width: 12),
              Text(
                "Offres en $_selectedField",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoadingOffers
                ? const Center(child: CircularProgressIndicator())
                : _offersByField.isEmpty
                    ? const Center(child: Text("Aucune offre disponible dans cette catégorie"))
                    : ListView.builder(
                        itemCount: _offersByField.length,
                        itemBuilder: (context, index) {
                          final o = _offersByField[index];
                          final dejaPostule = _aDejaPostule(o['titre'] ?? '', o['entreprise'] ?? '');
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.business)),
                              title: Text(o['titre'] ?? 'Offre', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(_hasMonthlyPass ? "${o['entreprise']} - ${o['lieu']}" : "Abonnement requis"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!dejaPostule)
                                    ElevatedButton(
                                      onPressed: () {
                                        final offreData = {
                                          'id': o['id'] ?? '',
                                          'titre': o['titre'] ?? '',
                                          'entreprise': o['entreprise'] ?? '',
                                        };
                                        _openPostulationForm(context, offre: offreData);
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      child: const Text("Postuler"),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text("Déjà postulé", style: TextStyle(color: Colors.grey)),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Parcourir les offres par domaine",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900]),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _availableFields.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: _availableFields.length,
                  itemBuilder: (context, index) {
                    final field = _availableFields[index];
                    return GestureDetector(
                      onTap: () async {
                        setState(() {
                          _selectedField = field;
                          _isLoadingOffers = true;
                        });
                        await _loadOffersByField(field);
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade400, Colors.blue.shade700],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getFieldIcon(field),
                                size: 40,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                field,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _loadOffersByField(String field) async {
    try {
      final offers = await ApiService.getOffers(field: field);
      final mapped = offers.map((o) => {
            'id': o['id']?.toString() ?? '',
            'titre': o['titre']?.toString() ?? '',
            'entreprise': o['nom_societe']?.toString() ?? o['entreprise']?.toString() ?? '',
            'lieu': o['lieu']?.toString() ?? o['ville_lieu']?.toString() ?? '',
            'typeContrat': o['type_contrat']?.toString() ?? o['typeContrat']?.toString() ?? '',
          }).toList();

      setState(() {
        _offersByField = mapped;
        _isLoadingOffers = false;
      });
    } catch (e) {
      Logger.error('Erreur chargement offres : $e');
      setState(() => _isLoadingOffers = false);
    }
  }

  IconData _getFieldIcon(String field) {
    final fieldMap = {
      'Informatique': Icons.computer,
      'Ingénierie': Icons.engineering,
      'Ventes': Icons.trending_up,
      'Marketing': Icons.campaign,
      'Ressources Humaines': Icons.people,
      'Finance': Icons.attach_money,
      'Comptabilité': Icons.calculate,
      'Santé': Icons.local_hospital,
      'Éducation': Icons.school,
      'Droit': Icons.gavel,
      'Agriculture': Icons.agriculture,
      'Construction': Icons.domain,
      'Transport': Icons.local_shipping,
      'Logistique': Icons.local_shipping,
      'Tourisme': Icons.flight,
      'Hôtellerie': Icons.hotel,
      'Restauration': Icons.restaurant,
      'Artisanat': Icons.handyman,
      'Commerce': Icons.store,
      'Services': Icons.miscellaneous_services,
      'Télécommunications': Icons.phone,
      'Énergie': Icons.bolt,
      'Environnement': Icons.eco,
      'Média': Icons.newspaper,
      'Divertissement': Icons.theater_comedy,
    };
    return fieldMap[field] ?? Icons.work;
  }

  Future<void> _creerEtAjouterCandidature(
    String nom,
    String tel,
    String email,
    Uint8List? photo,
    Uint8List? cv,
    Uint8List? recto,
    Uint8List? verso,
    Map<String, String> offre,
  ) async {
    final offreId = offre['id']?.toString() ?? '';
    if (offreId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible de postuler : identifiant de l'offre manquant."), backgroundColor: Colors.red),
      );
      return;
    }

    final succeeded = await _sendCandidatureToBackend(offreId);
    if (!succeeded) return;

    final nouvelle = Candidature(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      offreTitre: offre['titre'] ?? 'Offre',
      entreprise: offre['entreprise'] ?? 'Inconnue',
      datePostulation: DateTime.now(),
      statut: 'En cours',
      candidatEmail: email.isNotEmpty ? email : _candidateEmail,
      candidatNom: nom.isNotEmpty ? nom : _candidateNom,
      candidatTel: tel,
      candidatEmailContact: email.isNotEmpty ? email : _candidateEmail,
      photoBytes: photo,
      cvBytes: cv,
      cnibRectoBytes: recto,
      cnibVersoBytes: verso,
    );

    await _ajouterCandidature(nouvelle);
  }

  Future<bool> _sendCandidatureToBackend(String offreId) async {
    try {
      final offreIdInt = int.parse(offreId);
      final response = await ApiService.applyToOffer(offreIdInt);

      if (response['success'] == true) {
        return true;
      }

      if (response['requiresPayment'] == true) {
        final paymentSuccess = await PaymentService.payCandidatePerApplication(
          context,
          _candidateEmail,
          'candidature',
        );
        if (paymentSuccess) {
          return await _sendCandidatureToBackend(offreId);
        }
        return false;
      }

      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Erreur en envoyant la candidature')),
      );
      return false;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur du serveur : $error'), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }
      
  // ================== CONSEILS ==================
  Widget _buildConseils() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "📘 Nos conseils pour décrocher l'emploi ou le stage de vos rêves",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900]),
          ),
          const SizedBox(height: 20),
          _buildConseilTile(
            numero: "1.",
            titre: "Soignez votre CV et votre lettre de motivation",
            texte: "Votre CV est souvent la première chose que verra un recruteur. Assurez-vous qu'il soit clair, concis et sans fautes d'orthographe. Adaptez votre lettre de motivation à chaque offre.",
          ),
          _buildConseilTile(
            numero: "2.",
            titre: "Préparez vos documents à l'avance",
            texte: "Ayez toujours votre CV et CNIB prêts au format numérique. Cela vous fera gagner du temps lors de vos candidatures.",
          ),
          _buildConseilTile(
            numero: "3.",
            titre: "Personnalisez votre approche",
            texte: "Renseignez-vous sur l'entreprise avant de postuler. Montrez que vous avez fait vos recherches dans votre lettre de motivation.",
          ),
          _buildConseilTile(
            numero: "4.",
            titre: "Relisez-vous avant d'envoyer",
            texte: "Une faute d'orthographe ou une information incohérente peut vous disqualifier. Prenez le temps de tout vérifier.",
          ),
        ],
      ),
    );
  }

  Widget _buildConseilTile({required String numero, required String titre, required String texte}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(numero, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: Text(titre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 8),
            Text(texte, style: const TextStyle(fontSize: 14, height: 1.4), textAlign: TextAlign.justify),
          ],
        ),
      ),
    );
  }

  // ================== CONTACT ==================
  Widget _buildContact() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Contactez-nous", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue[900])),
          const SizedBox(height: 12),
          Text(
            "Nous sommes disponibles pour répondre à vos questions et vous accompagner dans votre recherche d'emploi ou de stage.",
            style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.4),
          ),
          const SizedBox(height: 30),
          const Divider(thickness: 1, color: Colors.grey),
          const SizedBox(height: 30),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.location_city, size: 28, color: Colors.blue[800]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Siège social", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                        const SizedBox(height: 4),
                        Text("Burkina Faso, Bobo-Dioulasso\nSecteur 10", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.phone, size: 28, color: Colors.blue[800]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Passer un appel", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                        const SizedBox(height: 4),
                        Text("+226 57 29 13 86\n+226 01 25 61 47", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.email, size: 28, color: Colors.blue[800]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Envoyer un mail", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                        const SizedBox(height: 4),
                        Text("afrijob22@gmail.com", style: TextStyle(fontSize: 14, color: Colors.blue[700])),
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

  // ================== MESSAGES ==================
  Widget _buildMessagesList() {
    return FutureBuilder<List<Conversation>>(
      future: _candidateEmail.isNotEmpty ? ChatService.getConversationsForCandidate(_candidateEmail) : Future.value([]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur lors du chargement des discussions : ${snapshot.error}'));
        }
        final conversations = snapshot.data ?? [];
        if (conversations.isEmpty) {
          return const Center(child: Text("Aucune discussion en cours. Allez sur 'Mes Offres' pour contacter une entreprise."));
        }
        return ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conv = conversations[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.blue[900], child: const Icon(Icons.business, color: Colors.white)),
                title: Text(conv.otherPartyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(conv.derniereMessage ?? "Aucun message"),
                trailing: conv.nonLus > 0
                    ? CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Text('${conv.nonLus}', style: const TextStyle(color: Colors.white, fontSize: 12)))
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  await ChatService.markAsReadForCandidate(conv.id);
                  await _refreshCounts();
                  if (!mounted) return;
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CandidateChatScreen(conversationId: conv.id, candidatData: candidatData)));
                },
              ),
            );
          },
        );
      },
    );
  }

  // ================== NOTIFICATIONS ==================
  Widget _buildNotificationsContent() {
    final list = NotificationService.notifications.where((n) => n.contains('[Candidat]')).toList();
    if (list.isEmpty) return const Center(child: Text("Aucune notification pour le moment."));
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) => Card(
        child: ListTile(
          leading: const Icon(Icons.notifications, color: Colors.blue),
          title: Text(list[index].replaceAll('[Candidat] ', '')),
        ),
      ),
    );
  }
}

// ================== DIALOGUE DE POSTULATION ==================
class PostulationFormDialog extends StatefulWidget {
  final Map<String, String> offre;
  final String candidatEmail;
  final String candidatNom;
  final String candidatTel;
  final Function(String nom, String telephone, String email, Uint8List? photo, Uint8List? cv, Uint8List? cnibRecto, Uint8List? cnibVerso) onValidate;

  const PostulationFormDialog({
    Key? key,
    required this.offre,
    required this.candidatEmail,
    required this.candidatNom,
    required this.candidatTel,
    required this.onValidate,
  }) : super(key: key);

  @override
  State<PostulationFormDialog> createState() => _PostulationFormDialogState();
}

class _PostulationFormDialogState extends State<PostulationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  Uint8List? _photoBytes;
  Uint8List? _cvBytes;
  Uint8List? _cnibRectoBytes;
  Uint8List? _cnibVersoBytes;
  String _cvFileName = '';
  String _cnibRectoFileName = '';
  String _cnibVersoFileName = '';
  bool _isSubmitting = false;

  static const List<String> _validCvExtensions = ['pdf', 'doc', 'docx'];
  static const List<String> _validImageExtensions = ['jpg', 'jpeg', 'png'];

  @override
  void initState() {
    super.initState();
    _nomCtrl.text = widget.candidatNom;
    _telCtrl.text = widget.candidatTel;
    _emailCtrl.text = widget.candidatEmail;
  }

  String _getExtension(String fileName) {
    final lowerName = fileName.toLowerCase();
    final dotIndex = lowerName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == lowerName.length - 1) return '';
    return lowerName.substring(dotIndex + 1);
  }

  void _showImageDialog(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.memory(imageBytes, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  void _previewCV() async {
    if (_cvBytes == null || _cvFileName.isEmpty) return;
    final ext = _getExtension(_cvFileName);
    if (ext != 'pdf') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Aperçu non supporté'),
          content: const Text('Seul le format PDF peut être visualisé directement dans l\'application. Pour DOC/DOCX, utilisez un lecteur externe.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
          ],
        ),
      );
      return;
    }

    if (kIsWeb) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Aperçu non supporté sur le Web'),
          content: const Text('La visualisation PDF n’est pas disponible dans la version Web. Téléchargez votre CV localement pour le consulter.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Aperçu du CV'),
              backgroundColor: Colors.blue[900],
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('Aperçu PDF non disponible dans cette version de l\'application.'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() => _photoBytes = bytes);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur photo : $e")));
    }
  }

  Future<void> _pickCV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _validCvExtensions,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun fichier sélectionné")),
        );
        return;
      }

      final file = result.files.first;
      final ext = _getExtension(file.name);
      if (!_validCvExtensions.contains(ext)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Format non accepté. Utilisez PDF, DOC ou DOCX.")),
        );
        return;
      }

      final bytes = file.bytes;
      if (bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible de lire le fichier sélectionné.")),
        );
        return;
      }

      setState(() {
        _cvBytes = bytes;
        _cvFileName = file.name;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("CV chargé avec succès")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur CV : $e")),
      );
    }
  }

  Future<void> _pickCNIBRecto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _validImageExtensions,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun fichier sélectionné pour le recto de la CNIB")),
        );
        return;
      }

      final file = result.files.first;
      final ext = _getExtension(file.name);
      if (!_validImageExtensions.contains(ext)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez sélectionner une image JPG ou PNG pour la CNIB")),
        );
        return;
      }

      final bytes = file.bytes;
      if (bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible de lire le fichier sélectionné.")),
        );
        return;
      }

      setState(() {
        _cnibRectoBytes = bytes;
        _cnibRectoFileName = file.name;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recto CNIB chargé avec succès")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur recto CNIB : $e")),
      );
    }
  }

  Future<void> _pickCNIBVerso() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _validImageExtensions,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun fichier sélectionné pour le verso de la CNIB")),
        );
        return;
      }

      final file = result.files.first;
      final ext = _getExtension(file.name);
      if (!_validImageExtensions.contains(ext)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez sélectionner une image JPG ou PNG pour la CNIB")),
        );
        return;
      }

      final bytes = file.bytes;
      if (bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible de lire le fichier sélectionné.")),
        );
        return;
      }

      setState(() {
        _cnibVersoBytes = bytes;
        _cnibVersoFileName = file.name;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verso CNIB chargé avec succès")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur verso CNIB : $e")),
      );
    }
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_cvBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez importer votre CV")),
        );
        return;
      }
      
      if (_cnibRectoBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez importer le recto de votre CNIB")),
        );
        return;
      }
      
      if (_cnibVersoBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez importer le verso de votre CNIB")),
        );
        return;
      }

      setState(() => _isSubmitting = true);
      
      // Appeler la fonction de validation
      widget.onValidate(
        _nomCtrl.text.trim(),
        _telCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _photoBytes,
        _cvBytes,
        _cnibRectoBytes,
        _cnibVersoBytes,
      );
      
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _telCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Postuler : ${widget.offre['poste'] ?? widget.offre['titre']}"),
            backgroundColor: Colors.blue[900],
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: _photoBytes != null ? MemoryImage(_photoBytes!) : null,
                          child: _photoBytes == null ? const Icon(Icons.person, size: 40) : null,
                        ),
                        const SizedBox(width: 12),
                        const Text("Ajouter une photo (optionnel)", style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  const Text("Informations personnelles", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  
                  TextFormField(
                    controller: _nomCtrl,
                    decoration: const InputDecoration(
                      labelText: "Nom complet *",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? "Champ requis" : null,
                  ),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: _telCtrl,
                    decoration: const InputDecoration(
                      labelText: "Numéro de téléphone *",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? "Champ requis" : null,
                  ),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: "Adresse email *",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.isEmpty ? "Champ requis" : null,
                  ),
                  const SizedBox(height: 20),
                  
                  const Text("Documents requis", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: _cvBytes != null ? Colors.green : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Icon(_cvBytes != null ? Icons.check_circle : Icons.description, 
                                  color: _cvBytes != null ? Colors.green : Colors.grey),
                      title: Text(_cvFileName.isEmpty ? "Curriculum Vitae (CV) *" : _cvFileName),
                      subtitle: _cvBytes == null 
                          ? const Text("Format accepté : PDF, DOC, DOCX", style: TextStyle(fontSize: 12))
                          : const Text("Fichier chargé", style: TextStyle(color: Colors.green, fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_cvBytes != null)
                            IconButton(
                              icon: const Icon(Icons.visibility, color: Colors.blue),
                              tooltip: 'Voir le CV',
                              onPressed: _previewCV,
                            ),
                          ElevatedButton(
                            onPressed: _pickCV,
                            child: Text(_cvBytes == null ? "Importer" : "Modifier"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: _cnibRectoBytes != null ? Colors.green : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Icon(_cnibRectoBytes != null ? Icons.check_circle : Icons.credit_card,
                                  color: _cnibRectoBytes != null ? Colors.green : Colors.grey),
                      title: Text(_cnibRectoFileName.isEmpty ? "CNIB - Recto *" : _cnibRectoFileName),
                      subtitle: _cnibRectoBytes == null
                          ? const Text("Format accepté : JPG, PNG (image uniquement)", style: TextStyle(fontSize: 12))
                          : const Text("Image chargée", style: TextStyle(color: Colors.green, fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_cnibRectoBytes != null)
                            IconButton(
                              icon: const Icon(Icons.visibility, color: Colors.blue),
                              tooltip: 'Voir le recto',
                              onPressed: () => _showImageDialog(_cnibRectoBytes!),
                            ),
                          ElevatedButton(
                            onPressed: _pickCNIBRecto,
                            child: Text(_cnibRectoBytes == null ? "Importer" : "Modifier"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: _cnibVersoBytes != null ? Colors.green : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Icon(_cnibVersoBytes != null ? Icons.check_circle : Icons.credit_card,
                                  color: _cnibVersoBytes != null ? Colors.green : Colors.grey),
                      title: Text(_cnibVersoFileName.isEmpty ? "CNIB - Verso *" : _cnibVersoFileName),
                      subtitle: _cnibVersoBytes == null
                          ? const Text("Format accepté : JPG, PNG (image uniquement)", style: TextStyle(fontSize: 12))
                          : const Text("Image chargée", style: TextStyle(color: Colors.green, fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_cnibVersoBytes != null)
                            IconButton(
                              icon: const Icon(Icons.visibility, color: Colors.blue),
                              tooltip: 'Voir le verso',
                              onPressed: () => _showImageDialog(_cnibVersoBytes!),
                            ),
                          ElevatedButton(
                            onPressed: _pickCNIBVerso,
                            child: Text(_cnibVersoBytes == null ? "Importer" : "Modifier"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isSubmitting 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Envoyer ma candidature", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "CV et CNIB (recto + verso) sont obligatoires",
                            style: TextStyle(fontSize: 12, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================== CHAT CANDIDAT ==================
class CandidateChatScreen extends StatefulWidget {
  final String conversationId;
  final Map<String, String> candidatData;
  const CandidateChatScreen({Key? key, required this.conversationId, required this.candidatData}) : super(key: key);

  @override
  State<CandidateChatScreen> createState() => _CandidateChatScreenState();
}

class _CandidateChatScreenState extends State<CandidateChatScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    final email = widget.candidatData['email'] ?? '';
    if (email.isEmpty) return;
    final conversations = await ChatService.getConversationsForCandidate(email);
    final conv = conversations.firstWhere(
      (c) => c.id == widget.conversationId,
      orElse: () => throw Exception("Conversation introuvable"),
    );
    final success = await ChatService.sendMessageFromCandidate(conv.id, _controller.text.trim());
    if (success) {
      setState(() {
        _controller.clear();
      });
      NotificationService.notifyCompany("Nouveau message de ${widget.candidatData['nom']}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final candidateEmail = widget.candidatData['email'] ?? '';
    return FutureBuilder<List<Conversation>>(
      future: candidateEmail.isNotEmpty
          ? ChatService.getConversationsForCandidate(candidateEmail)
          : Future.value([]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text("Discussion"), backgroundColor: Colors.blue[900]),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text("Discussion"), backgroundColor: Colors.blue[900]),
            body: Center(child: Text('Erreur lors du chargement de la conversation : ${snapshot.error}')),
          );
        }
        final conversations = snapshot.data ?? [];
        final currentConv = conversations.firstWhere(
          (c) => c.id == widget.conversationId,
          orElse: () => Conversation(id: widget.conversationId, otherPartyName: 'Utilisateur', otherPartyType: 'unknown', derniereMessage: null, nonLus: 0),
        );
        return Scaffold(
          appBar: AppBar(
            title: Text("Discussion avec ${currentConv.otherPartyName}"),
            backgroundColor: Colors.blue[900],
          ),
          body: FutureBuilder<List<Message>>(
            future: ChatService.getMessages(int.tryParse(currentConv.id) ?? 0),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Aucun message (Erreur: ${snapshot.error})"));
              }
              final messages = snapshot.data ?? [];
              if (messages.isEmpty) {
                return const Center(child: Text("Aucun message pour cette conversation."));
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages.reversed.toList()[index];
                        final isMe = msg.senderId.startsWith('candidat');
                        final displayName = isMe
                            ? (widget.candidatData['nom'] ?? "Moi")
                            : msg.senderName;
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue[100] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  displayName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isMe ? Colors.blue[900] : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(child: Text(msg.text, style: const TextStyle(fontSize: 15))),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                                      onPressed: () async {
                                        await ChatService.deleteMessage(widget.conversationId, msg.id);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: "Écrivez un message...",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}



