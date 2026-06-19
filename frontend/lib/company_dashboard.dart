import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:typed_data';
import 'dart:io';
import 'notification_service.dart';
import 'chat_service.dart';
import 'profile_image_helper.dart';
import 'candidature_service.dart';
import 'payment_service.dart';
import 'subscription_service.dart';
import 'services/api_service.dart';

class CompanyDashboard extends StatefulWidget {
  final Map<String, String> initialData;
  const CompanyDashboard({Key? key, required this.initialData}) : super(key: key);

  @override
  State<CompanyDashboard> createState() => _CompanyDashboardState();
}

class _CompanyDashboardState extends State<CompanyDashboard> {
  int _selectedIndex = 0;
  int _notificationCount = 0;
  int _unreadMessagesCount = 0;
  late Map<String, String> entrepriseData;
  bool _subscriptionActive = false;

  String get _companyName {
    final nomSociete = entrepriseData['nom_societe']?.trim();
    final nom = entrepriseData['nom']?.trim();
    if (nomSociete != null && nomSociete.isNotEmpty) return nomSociete;
    if (nom != null && nom.isNotEmpty) return nom;
    return 'Entreprise';
  }

  String get _companyEmail => entrepriseData['email'] ?? '';

  final _posteController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _competencesController = TextEditingController();
  final _niveauController = TextEditingController();
  final _experienceController = TextEditingController();
  final _lieuController = TextEditingController();
  final _salaireController = TextEditingController();

  String _selectedTypeContrat = 'CDI';
  Uint8List? _logoBytes;
  String _logoFileName = '';

  @override
  void initState() {
    super.initState();
    entrepriseData = widget.initialData;
    _refreshCounts();
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    final email = entrepriseData['email'] ?? '';
    if (email.isEmpty) return;
    final active = await SubscriptionService.isCompanySubscriptionActive(email);
    final remainingDays = await SubscriptionService.getRemainingDaysForCompany(email);
    setState(() {
      _subscriptionActive = active;
    });
    if (!active) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Vous n'avez pas d'abonnement actif"),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (remainingDays > 0 && remainingDays <= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ Votre abonnement expire dans $remainingDays jours"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _posteController.dispose();
    _descriptionController.dispose();
    _competencesController.dispose();
    _niveauController.dispose();
    _experienceController.dispose();
    _lieuController.dispose();
    _salaireController.dispose();
    super.dispose();
  }

  Future<void> _refreshCounts() async {
    final companyName = _companyName;
    final unread = await ChatService.getTotalUnreadForCompany(companyName);
    setState(() {
      _notificationCount = NotificationService.entrepriseCount;
      _unreadMessagesCount = unread;
      entrepriseData['nom_societe'] = companyName;
    });
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

  void _previewCV(Uint8List cvBytes, String fileName) async {
    final ext = _getExtension(fileName);
    if (ext != 'pdf') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Aperçu non supporté'),
          content: const Text('Seul le format PDF peut être visualisé directement dans l\'application. Pour DOC/DOCX, utilisez le bouton Télécharger.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
          ],
        ),
      );
      return;
    }

    final tempDir = await Directory.systemTemp.createTemp('cv_preview_');
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(cvBytes);

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
            body: WebViewWidget(
              controller: WebViewController()
                ..loadRequest(Uri.file(file.path)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickLogo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      final bytes = result.files.first.bytes;
      final name = result.files.first.name;
      setState(() {
        _logoBytes = bytes;
        _logoFileName = name;
      });
    }
  }

  void _publierOffre() async {
    if (_posteController.text.isEmpty) return;

    final email = entrepriseData['email'] ?? '';
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email d'entreprise introuvable")),
      );
      return;
    }
    final isActive = await SubscriptionService.isCompanySubscriptionActive(email);
    if (!isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vous devez souscrire un abonnement pour publier une offre.")),
      );
      return;
    }

    // Try to create the offer on the backend
    final resp = await ApiService.createOffer(
      titre: _posteController.text,
      description: _descriptionController.text,
      typeContrat: _selectedTypeContrat,
      lieu: _lieuController.text,
      competences: _competencesController.text,
      niveau: _niveauController.text,
      experience: _experienceController.text,
      salaire: _salaireController.text,
    );

    if (resp['success'] == true) {
      final createdId = resp['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      final newOffre = {
        'id': createdId,
        'typeContrat': _selectedTypeContrat,
        'titre': _posteController.text,
        'description': _descriptionController.text,
        'competences': _competencesController.text,
        'niveau': _niveauController.text,
        'experience': _experienceController.text,
        'lieu': _lieuController.text,
        'salaire': _salaireController.text,
        'logoBytes': _logoBytes,
        'entreprise': _companyName,
      };
      setState(() {
        CandidatureService().offresGlobales.add(newOffre);
        _posteController.clear();
        _descriptionController.clear();
        _competencesController.clear();
        _niveauController.clear();
        _experienceController.clear();
        _lieuController.clear();
        _salaireController.clear();
        _logoBytes = null;
        _logoFileName = '';
        _selectedIndex = 2;
      });
      NotificationService.notifyCandidate("Nouvelle offre: ${newOffre['titre']} chez $_companyName");
      // Try to refresh global offers from backend to keep lists in sync
      try {
        final latest = await ApiService.getOffers();
        final mapped = latest.map((o) => {
          'id': o['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'typeContrat': o['type_contrat'] ?? o['typeContrat'] ?? '',
          'titre': o['titre'] ?? '',
          'description': o['description'] ?? '',
          'competences': o['competences'] ?? '',
          'niveau': o['niveau'] ?? '',
          'experience': o['experience'] ?? '',
          'lieu': o['lieu'] ?? o['ville_lieu'] ?? '',
          'salaire': o['salaire'] ?? '',
          'logoBytes': null,
          'entreprise': o['nom_societe'] ?? o['entreprise'] ?? '',
        }).toList();
        CandidatureService().offresGlobales.clear();
        CandidatureService().offresGlobales.addAll(mapped);
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offre publiée')));
    } else {
      // fallback: add locally and show warning
      final newOffre = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'typeContrat': _selectedTypeContrat,
        'titre': _posteController.text,
        'description': _descriptionController.text,
        'competences': _competencesController.text,
        'niveau': _niveauController.text,
        'experience': _experienceController.text,
        'lieu': _lieuController.text,
        'salaire': _salaireController.text,
        'logoBytes': _logoBytes,
        'entreprise': _companyName,
      };
      setState(() {
        CandidatureService().offresGlobales.add(newOffre);
        _posteController.clear();
        _descriptionController.clear();
        _competencesController.clear();
        _niveauController.clear();
        _experienceController.clear();
        _lieuController.clear();
        _salaireController.clear();
        _logoBytes = null;
        _logoFileName = '';
        _selectedIndex = 2;
      });
      // attempt to refresh offers from backend (best-effort)
      try {
        final latest = await ApiService.getOffers();
        final mapped = latest.map((o) => {
          'id': o['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'typeContrat': o['type_contrat'] ?? o['typeContrat'] ?? '',
          'titre': o['titre'] ?? '',
          'description': o['description'] ?? '',
          'competences': o['competences'] ?? '',
          'niveau': o['niveau'] ?? '',
          'experience': o['experience'] ?? '',
          'lieu': o['lieu'] ?? o['ville_lieu'] ?? '',
          'salaire': o['salaire'] ?? '',
          'logoBytes': null,
          'entreprise': o['nom_societe'] ?? o['entreprise'] ?? '',
        }).toList();
        CandidatureService().offresGlobales.clear();
        CandidatureService().offresGlobales.addAll(mapped);
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Offre ajoutée localement (${resp['message'] ?? 'erreur backend'})')));
    }
  }

  void _supprimerOffre(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Voulez-vous vraiment supprimer cette offre ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(
            onPressed: () {
              setState(() {
                CandidatureService().offresGlobales.removeWhere((o) => o['id'] == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Offre supprimée avec succès")),
              );
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _gererCandidature(String candidatureId, String nouveauStatut, String candidatEmail, String offreTitre) {
    CandidatureService().updateStatut(candidatureId, nouveauStatut);
    NotificationService.notifyCandidate("Votre candidature pour l'offre $offreTitre a été $nouveauStatut");
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Candidature $nouveauStatut")),
    );
  }

  // ================== NOUVEAU : Contacter le candidat ==================
  Future<void> _contacterCandidat(Candidature candidature) async {
    final email = _companyEmail;
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email de l'entreprise manquant."), backgroundColor: Colors.red),
      );
      return;
    }
    final isActive = await SubscriptionService.isCompanySubscriptionActive(email);
    setState(() {
      _subscriptionActive = isActive;
    });

    if (!isActive) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vous devez souscrire un abonnement pour contacter un candidat."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final convId = await ChatService.getOrCreateConversationForCompany(
      _companyName,
      candidature.candidatNom,
    );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyChatScreen(
          conversationId: convId,
          entrepriseData: entrepriseData,
        ),
      ),
    ).then((_) async {
      await _refreshCounts();
      if (mounted) setState(() {});
    });
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _downloadFile(Uint8List bytes, String suggestedName) async {
  try {
    // Utilise file_picker pour sauvegarder le fichier sur l'appareil de l'entreprise
    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: "Enregistrer le fichier",
      fileName: suggestedName,
    );
    
    if (outputPath != null) {
      final File file = File(outputPath);
      await file.writeAsBytes(bytes); // Écriture des octets du fichier
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Fichier enregistré : $suggestedName")),
        );
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Erreur : $e"), backgroundColor: Colors.red),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f9),
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
                    _companyName,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    entrepriseData['domaine'] ?? 'Domaine non spécifié',
                    style: TextStyle(color: Colors.blue[100], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildMenuItem(0, Icons.dashboard, "Accueil & Dashboard"),
                        _buildMenuItem(6, Icons.business, "Fiche Entreprise"),
                        _buildMenuItem(10, Icons.payment, "Abonnement"),
                        _buildMenuItem(1, Icons.add_box, "Publier une Offre"),
                        _buildMenuItem(2, Icons.list, "Mes Annonces"),
                        _buildMenuItem(7, Icons.people, "Candidatures reçues"),
                        _buildMenuItem(8, Icons.lightbulb, "Conseils"),
                        _buildMenuItem(9, Icons.contact_mail, "Contact"),
                        _buildMenuItem(4, Icons.chat, "Messages Candidats", count: _unreadMessagesCount),
                        _buildMenuItem(5, Icons.notifications, "Notifications", count: _notificationCount),
                        const Divider(color: Colors.white24, height: 20),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
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
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size.fromHeight(45),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text("Déconnexion", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: Container(padding: const EdgeInsets.all(30), child: _buildMainContent())),
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
              child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            )
          : null,
      tileColor: isSelected ? Colors.blue[800] : Colors.transparent,
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 5) {
          NotificationService.resetCompanyCount();
          _refreshCounts();
        }
      },
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildCompanyDashboardHome();
      case 6:
        return _buildFicheEntreprise();
      case 10:
        return _buildSubscriptionPage();
      case 1:
        return _buildPublierOffre();
      case 2:
        return _buildGererOffres();
      case 7:
        return _buildCandidaturesRecues();
      case 8:
        return _buildConseils();
      case 9:
        return _buildContact();
      case 4:
        return _buildMessagesList();
      case 5:
        return _buildNotificationsContent();
      default:
        return _buildCompanyDashboardHome();
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
            Text("Gestion de l'abonnement", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900])),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _subscriptionActive ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _subscriptionActive ? Colors.green : Colors.orange),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_subscriptionActive ? Icons.check_circle : Icons.warning,
                          color: _subscriptionActive ? Colors.green : Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        _subscriptionActive ? "Abonnement actif" : "Aucun abonnement actif",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _subscriptionActive ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_subscriptionActive) ...[
                    FutureBuilder<int>(
                      future: _companyEmail.isNotEmpty ? SubscriptionService.getRemainingDaysForCompany(_companyEmail) : Future.value(0),
                      builder: (context, snapshot) {
                        final days = snapshot.data ?? 0;
                        return Text("📅 Jours restants : $days jours");
                      },
                    ),
                    const Text("✅ Publication d'offres illimitée"),
                    const Text("✅ Gestion des candidatures"),
                  ] else ...[
                    const Text("⚠️ Abonnement requis pour publier des offres"),
                    const Text("💡 Abonnement mensuel à 2000 FCFA"),
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
              onPressed: _subscriptionActive || _companyEmail.isEmpty ? null : () async {
                final success = await PaymentService.payCompanyMonthly(context, _companyEmail);
                if (success) await _checkSubscription();
              },
              icon: const Icon(Icons.payment),
              label: const Text("S'abonner (2000 FCFA / mois)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () async {
                final email = _companyEmail;
                if (email.isEmpty) return;
                await SubscriptionService.resetSubscription(email, 'company');
                await _checkSubscription();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Abonnement réinitialisé pour test"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Réinitialiser l'abonnement (test)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== CANDIDATURES REÇUES (AVEC BOUTON CONTACTER) ==================
  Widget _buildCandidaturesRecues() {
    final candidatures = CandidatureService().getCandidaturesForCompany(_companyName);

    if (!_subscriptionActive) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.shade700),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Abonnement requis",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              SizedBox(height: 12),
              Text(
                "Vous devez activer un abonnement avant de pouvoir consulter les informations des candidats et leurs candidatures.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (candidatures.isEmpty) {
      return const Center(child: Text("Aucune candidature reçue pour le moment."));
    }

    return ListView.builder(
      itemCount: candidatures.length,
      itemBuilder: (context, index) {
        final c = candidatures[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.offreTitre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Text("Candidat: ${c.candidatNom}"),
                Text("Email: ${c.candidatEmailContact}"),
                Text("Téléphone: ${c.candidatTel}"),
                Text("Postulé le: ${_formatDate(c.datePostulation)}"),
                const Divider(height: 20),
                const Text("Documents joints", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                
                // CV
                if (c.cvBytes != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Curriculum Vitae (CV)",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      "Fichier PDF/DOC",
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                                    onPressed: () => _previewCV(c.cvBytes!, "CV_${c.candidatNom.replaceAll(' ', '_')}.pdf"),
                                    tooltip: "Visualiser",
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.download, color: Colors.green),
                                    onPressed: () => _downloadFile(c.cvBytes!, "CV_${c.candidatNom.replaceAll(' ', '_')}.pdf"),
                                    tooltip: "Télécharger",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange),
                        SizedBox(width: 12),
                        Text("CV non fourni", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                
                // CNIB Recto
                if (c.cnibRectoBytes != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.credit_card, color: Colors.green, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "CNIB - Recto",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      "Image (JPG/PNG)",
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                                    onPressed: () => _showImageDialog(c.cnibRectoBytes!),
                                    tooltip: "Visualiser",
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.download, color: Colors.green),
                                    onPressed: () => _downloadFile(c.cnibRectoBytes!, "CNIB_Recto_${c.candidatNom.replaceAll(' ', '_')}.jpg"),
                                    tooltip: "Télécharger",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange),
                        SizedBox(width: 12),
                        Text("CNIB Recto non fourni", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                
                // CNIB Verso
                if (c.cnibVersoBytes != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.credit_card, color: Colors.green, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "CNIB - Verso",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      "Image (JPG/PNG)",
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                                    onPressed: () => _showImageDialog(c.cnibVersoBytes!),
                                    tooltip: "Visualiser",
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.download, color: Colors.green),
                                    onPressed: () => _downloadFile(c.cnibVersoBytes!, "CNIB_Verso_${c.candidatNom.replaceAll(' ', '_')}.jpg"),
                                    tooltip: "Télécharger",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange),
                        SizedBox(width: 12),
                        Text("CNIB Verso non fourni", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                
                // Photo du candidat (si disponible)
                if (c.photoBytes != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.person, color: Colors.purple, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Photo du candidat",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      "Image (JPG/PNG)",
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                                    onPressed: () => _showImageDialog(c.photoBytes!),
                                    tooltip: "Visualiser",
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.download, color: Colors.green),
                                    onPressed: () => _downloadFile(c.photoBytes!, "Photo_${c.candidatNom.replaceAll(' ', '_')}.jpg"),
                                    tooltip: "Télécharger",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const Divider(height: 20),
                
                // ================== ACTIONS : ACCEPTER / REFUSER / CONTACTER ==================
                Row(
                  children: [
                    if (c.statut == "En cours") ...[
                      ElevatedButton(
                        onPressed: () => _gererCandidature(c.id, "Acceptée", c.candidatEmail, c.offreTitre),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text("Accepter"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _gererCandidature(c.id, "Refusée", c.candidatEmail, c.offreTitre),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text("Refuser"),
                      ),
                    ] else if (c.statut == "Acceptée") ...[
                      // BOUTON CONTACTER POUR LES OFFRES ACCEPTÉES
                      ElevatedButton.icon(
                        onPressed: () {
                          _contacterCandidat(c);
                        },
                        icon: const Icon(Icons.chat, size: 18),
                        label: const Text("Contacter"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          c.statut,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ] else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          c.statut,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================== CONSEILS ==================
  Widget _buildConseils() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "📘 Nos conseils pour recruter efficacement",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900]),
          ),
          const SizedBox(height: 20),
          _buildConseilTile(
            numero: "1.",
            titre: "Rédigez des offres claires et attractives",
            texte: "Un titre précis, une description détaillée des missions, des compétences requises et des avantages. Évitez les jargons internes.",
          ),
          _buildConseilTile(
            numero: "2.",
            titre: "Validez rapidement les candidatures",
            texte: "Les candidats attendent une réponse. Un accusé de réception automatique, puis un retour sous 5 à 7 jours. Cela améliore votre image employeur.",
          ),
          _buildConseilTile(
            numero: "3.",
            titre: "Utilisez les documents fournis",
            texte: "Consultez le CV et la CNIB pour vérifier l’identité et les compétences. Notre plateforme vous permet de visualiser les images instantanément.",
          ),
          _buildConseilTile(
            numero: "4.",
            titre: "Communiquez via le chat",
            texte: "Le chat intégré permet d’échanger directement avec les candidats pour des questions rapides ou une pré-sélection.",
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
          Text(
            "Contactez-nous",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue[900]),
          ),
          const SizedBox(height: 12),
          Text(
            "Nous sommes disponibles pour répondre à vos questions, accompagner vos recrutements ou vous aider dans votre recherche d'emploi.",
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

  // ================== FICHE ENTREPRISE ==================
  Widget _buildFicheEntreprise() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Informations de la Société", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900])),
            const Divider(height: 30),
            _buildProfileRow("Nom de l'entreprise", entrepriseData['nom_societe'] ?? entrepriseData['nom'] ?? 'Non spécifié'),
            _buildProfileRow("Secteur / Domaine", entrepriseData['domaine'] ?? 'Non spécifié'),
            _buildProfileRow("Téléphone", entrepriseData['telephone'] ?? 'Non spécifié'),
            _buildProfileRow("Email Professionnel", entrepriseData['email'] ?? 'Non spécifié'),
            _buildProfileRow("Ville / Lieu", entrepriseData['villeLieu']?.isNotEmpty == true ? entrepriseData['villeLieu']! : entrepriseData['adresse']?.isNotEmpty == true ? entrepriseData['adresse']! : 'Non spécifié'),
            _buildProfileRow("Adresse complète", entrepriseData['adresse']?.isNotEmpty == true ? entrepriseData['adresse']! : entrepriseData['villeLieu']?.isNotEmpty == true ? entrepriseData['villeLieu']! : 'Non spécifié'),
          ],
        ),
      ),
    );
  }

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

  // ================== PUBLIER UNE OFFRE ==================
  Widget _buildPublierOffre() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Créer et publier une nouvelle offre", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900])),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: entrepriseData['nom_societe'],
            readOnly: true,
            decoration: const InputDecoration(labelText: "Nom de l'entreprise", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _pickLogo,
                icon: const Icon(Icons.upload_file),
                label: Text(_logoFileName.isEmpty ? "Importer le logo" : _logoFileName),
              ),
              const SizedBox(width: 12),
              if (_logoBytes != null)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.memory(_logoBytes!),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(controller: _posteController, decoration: const InputDecoration(labelText: "Titre du poste *")),
          const SizedBox(height: 12),
          TextField(controller: _descriptionController, maxLines: 4, decoration: const InputDecoration(labelText: "Description du poste")),
          const SizedBox(height: 12),
          TextField(controller: _competencesController, decoration: const InputDecoration(labelText: "Compétences requises (séparées par des virgules)")),
          const SizedBox(height: 12),
          TextField(controller: _niveauController, decoration: const InputDecoration(labelText: "Niveau d'étude demandé")),
          const SizedBox(height: 12),
          TextField(controller: _experienceController, decoration: const InputDecoration(labelText: "Expérience requise (en années)")),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedTypeContrat,
            decoration: const InputDecoration(labelText: "Type de contrat"),
            items: ['CDI', 'CDD', 'Stage', 'Freelance', 'Alternance'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedTypeContrat = v);
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(controller: _lieuController, decoration: const InputDecoration(labelText: "Lieu (ville, télétravail, etc.)")),
          const SizedBox(height: 12),
          if (_selectedTypeContrat != 'Stage')
            TextField(controller: _salaireController, decoration: const InputDecoration(labelText: "Salaire (optionnel)")),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], minimumSize: const Size.fromHeight(45)),
            onPressed: _publierOffre,
            child: const Text("Publier l'annonce", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // ================== GÉRER LES OFFRES ==================
  Widget _buildGererOffres() {
    final companyName = entrepriseData['nom_societe'] ?? entrepriseData['nom'] ?? 'Entreprise';
    final offresPubliees = CandidatureService().offresGlobales.where((o) => o['entreprise'] == companyName).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Vos annonces publiées", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900])),
        const SizedBox(height: 15),
        Expanded(
          child: offresPubliees.isEmpty
              ? const Center(child: Text("Aucune offre publiée pour le moment."))
              : ListView.builder(
                  itemCount: offresPubliees.length,
                  itemBuilder: (context, index) {
                    final o = offresPubliees[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ExpansionTile(
                        leading: o['logoBytes'] != null
                            ? CircleAvatar(backgroundImage: MemoryImage(o['logoBytes']))
                            : const CircleAvatar(child: Icon(Icons.business)),
                        title: Text(o['titre']?.toString() ?? 'Offre', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${o['typeContrat']} - ${o['lieu']}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _supprimerOffre(o['id']),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Description: ${o['description']}"),
                                Text("Compétences: ${o['competences']}"),
                                Text("Niveau: ${o['niveau']}"),
                                Text("Expérience: ${o['experience']}"),
                                if (o['salaire'] != null && o['salaire']!.isNotEmpty) Text("Salaire: ${o['salaire']}"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ================== MESSAGES CANDIDATS ==================
  Widget _buildMessagesList() {
    return FutureBuilder<List<Conversation>>(
      future: ChatService.getConversationsForCompany(_companyName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur lors du chargement des messages : ${snapshot.error}'));
        }
        final conversations = snapshot.data ?? [];
        if (conversations.isEmpty) {
          return const Center(child: Text("Aucun message reçu de candidat pour l'instant."));
        }
        return ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conv = conversations[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.blue[900], child: const Icon(Icons.person, color: Colors.white)),
                title: Text(conv.otherPartyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(conv.derniereMessage ?? "Aucun message"),
                trailing: conv.nonLus > 0
                    ? CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Text('${conv.nonLus}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      )
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  await ChatService.markAsReadForCompany(conv.id);
                  await _refreshCounts();
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompanyChatScreen(
                        conversationId: conv.id,
                        entrepriseData: entrepriseData,
                      ),
                    ),
                  ).then((_) async {
                    await _refreshCounts();
                    if (mounted) setState(() {});
                  });
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
    final list = NotificationService.notifications.where((n) => n.contains('[Entreprise]')).toList();
    if (list.isEmpty) return const Center(child: Text("Aucune notification pour le moment."));
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) => Card(
        child: ListTile(
          leading: const Icon(Icons.notifications, color: Colors.blue),
          title: Text(list[index].replaceAll('[Entreprise] ', '')),
        ),
      ),
    );
  }

  // ================== ACCUEIL & DASHBOARD ==================
  Widget _buildCompanyDashboardHome() {
    final companyName = entrepriseData['nom_societe'] ?? entrepriseData['nom'] ?? 'Entreprise';
    final offresPubliees = CandidatureService().offresGlobales.where((o) => o['entreprise'] == companyName).toList();
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[900]!, Colors.blue[700]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 12, offset: const Offset(0, 6), spreadRadius: 1)
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Espace Recruteur — $_companyName 🚀",
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Trouvez les meilleurs talents dès aujourd'hui. Secteur d'activité référencé : ${entrepriseData['domaine']}.",
                        style: TextStyle(color: Colors.blue[50], fontSize: 14, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.bolt_rounded, size: 40, color: Colors.white),
                )
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text("Vue d'ensemble de l'activité", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildStatCard("Annonces en ligne", "${offresPubliees.length}", Icons.assignment_turned_in_rounded, Colors.blue),
              const SizedBox(width: 15),
              _buildStatCard("Messages Candidats", "$_unreadMessagesCount", Icons.question_answer_rounded, Colors.orange),
              const SizedBox(width: 15),
              _buildStatCard("Candidatures reçues", "${CandidatureService().getCandidaturesForCompany(_companyName).length}", Icons.people_alt_rounded, Colors.green),
            ],
          ),
          const SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Performance de vos annonces", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
              TextButton(
                onPressed: () => setState(() => _selectedIndex = 2),
                child: const Text("Gérer les annonces →", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...offresPubliees.asMap().entries.map((entry) {
            var offre = entry.value;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2), spreadRadius: 0)
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[50],
                  child: offre['logoBytes'] != null
                      ? Image.memory(offre['logoBytes'], width: 30, height: 30)
                      : Icon(Icons.work_outline_rounded, color: Colors.blue[800]),
                ),
                title: Text(offre['titre']?.toString() ?? 'Offre', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text("Type : ${offre['typeContrat']} | Lieu : ${offre['lieu']}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Active",
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _supprimerOffre(offre['id']),
                      tooltip: "Supprimer l'offre",
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4), spreadRadius: 1)
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== CHAT ENTREPRISE ==================
class CompanyChatScreen extends StatefulWidget {
  final String conversationId;
  final Map<String, String> entrepriseData;
  const CompanyChatScreen({Key? key, required this.conversationId, required this.entrepriseData}) : super(key: key);

  @override
  State<CompanyChatScreen> createState() => _CompanyChatScreenState();
}

class _CompanyChatScreenState extends State<CompanyChatScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    final success = await ChatService.sendMessageFromCompany(
      widget.conversationId,
      _controller.text.trim(),
    );
    if (success) {
      setState(() {
        _controller.clear();
      });
      NotificationService.notifyCandidate("Nouveau message de ${widget.entrepriseData['nom_societe'] ?? widget.entrepriseData['nom'] ?? 'Société'}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Message>>(
      future: ChatService.getMessages(int.tryParse(widget.conversationId) ?? 0),
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
            body: Center(child: Text('Erreur lors du chargement des messages : ${snapshot.error}')),
          );
        }
        final messages = snapshot.data ?? [];
        return Scaffold(
          appBar: AppBar(
            title: Text("Discussion avec ${widget.entrepriseData['nom_societe'] ?? widget.entrepriseData['nom'] ?? 'Utilisateur'}"),
            backgroundColor: Colors.blue[900],
          ),
          backgroundColor: const Color(0xfff4f6f9),
          body: Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? const Center(child: Text('Aucun message pour cette conversation.'))
                    : ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages.reversed.toList()[index];
                          final isMe = msg.senderId.startsWith('entreprise');
                          final displayName = isMe
                              ? (widget.entrepriseData['nom_societe'] ?? "Société")
                              : msg.senderName;
                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.45),
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue[100] : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        displayName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isMe ? Colors.blue[800] : Colors.grey[700],
                                        ),
                                      ),
                                      if (isMe)
                                        GestureDetector(
                                          onTap: () async {
                                            await ChatService.deleteMessage(widget.conversationId, msg.id);
                                            setState(() {});
                                          },
                                          child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    msg.text,
                                    style: const TextStyle(fontSize: 14.5, color: Colors.black87, height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Écrivez votre message ici...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: const Color(0xfff4f6f9),
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.blue[900],
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 18),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



