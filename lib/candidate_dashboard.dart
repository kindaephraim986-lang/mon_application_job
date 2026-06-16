import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'document_validation.dart';
import 'notification_service.dart';
import 'chat_service.dart';
import 'profile_image_helper.dart';
import 'candidature_service.dart';
import 'payment_service.dart';
import 'subscription_service.dart';
import 'services/api_service.dart';

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

  // Fichiers
  Uint8List? _cvBytes;
  String _cvFileName = '';
  Uint8List? _cnibRectoBytes;
  String _cnibRectoFileName = '';
  Uint8List? _cnibVersoBytes;
  String _cnibVersoFileName = '';

  @override
  void initState() {
    super.initState();
    candidatData = widget.initialData;
    _refreshCounts();
    _checkMonthlyPass();
  }

  Future<void> _checkMonthlyPass() async {
    final has = await SubscriptionService().hasCandidateMonthlyPass(candidatData['email']!);
    final remainingDays = await SubscriptionService().getRemainingDaysForCandidate(candidatData['email']!);
    if (!mounted) return;
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

  void _refreshCounts() {
    setState(() {
      _notificationCount = NotificationService().candidatCount;
      _unreadMessagesCount = ChatService().getTotalUnreadForCandidate(candidatData['email']!);
    });
  }

  String _extensionFromFileName(String fileName) {
    final parts = fileName.toLowerCase().split('.');
    return parts.length > 1 ? parts.last : '';
  }

  bool _isValidCvFile(String fileName) {
    final extension = _extensionFromFileName(fileName);
    return ['pdf', 'doc', 'docx'].contains(extension);
  }

  bool _isValidCnibImage(String fileName) {
    final extension = _extensionFromFileName(fileName);
    return ['jpg', 'jpeg', 'png'].contains(extension);
  }

  Future<void> _importCV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      if (!mounted) return;
      if (result != null) {
        final pickedFile = result.files.first;
        final fileName = pickedFile.name;
        if (!_isValidCvFile(fileName)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Veuillez sélectionner un fichier CV valide (PDF, DOC, DOCX)")),
          );
          return;
        }
        final bytes = pickedFile.bytes ?? (pickedFile.path != null ? await File(pickedFile.path!).readAsBytes() : null);
        if (bytes == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Impossible de lire le fichier CV sélectionné")),
          );
          return;
        }
        final validContent = await validateCvContent(bytes: bytes, fileName: fileName);
        if (!validContent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Le document sélectionné ne ressemble pas à un CV valide")),
          );
          return;
        }
        setState(() {
          _cvBytes = bytes;
          _cvFileName = fileName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("CV importé avec succès")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun fichier sélectionné")),
        );
      }
    } catch (e) {
      if (!mounted) return;
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
      if (image != null) {
        final imageName = image.name;
        if (!_isValidCnibImage(imageName)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Veuillez sélectionner une image CNIB valide (JPG ou PNG)")),
          );
          return;
        }
        final path = image.path;
        final validContent = path.isNotEmpty && await validateCnibImage(path);
        if (!validContent) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("L'image sélectionnée ne semble pas être une CNIB valide")),
          );
          return;
        }
        final bytes = await image.readAsBytes();
        if (!mounted) return;
        setState(() {
          _cnibRectoBytes = bytes;
          _cnibRectoFileName = imageName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recto CNIB importé avec succès")),
        );
      }
    } catch (e) {
      if (!mounted) return;
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
      if (image != null) {
        final imageName = image.name;
        if (!_isValidCnibImage(imageName)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Veuillez sélectionner une image CNIB valide (JPG ou PNG)")),
          );
          return;
        }
        final path = image.path;
        final validContent = path.isNotEmpty && await validateCnibImage(path);
        if (!validContent) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("L'image sélectionnée ne semble pas être une CNIB valide")),
          );
          return;
        }
        final bytes = await image.readAsBytes();
        if (!mounted) return;
        setState(() {
          _cnibVersoBytes = bytes;
          _cnibVersoFileName = imageName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verso CNIB importé avec succès")),
        );
      }
    } catch (e) {
      if (!mounted) return;
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

  bool _aDejaPostule(String offreTitre, String entreprise) {
    return CandidatureService().aDejaPostule(candidatData['email']!, offreTitre, entreprise);
  }

  void _ajouterCandidature(Candidature nouvelle) {
    // Vérifier si une candidature identique existe déjà
    final existeDeja = CandidatureService().getCandidaturesForCandidate(candidatData['email']!).any(
      (c) => c.offreTitre == nouvelle.offreTitre && c.entreprise == nouvelle.entreprise
    );
    
    if (existeDeja) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vous avez déjà postulé à cette offre"), backgroundColor: Colors.orange),
      );
      return;
    }
    
    CandidatureService().addCandidature(nouvelle);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Candidature envoyée pour ${nouvelle.offreTitre}")),
    );
    NotificationService().notifyCompany(
      "Nouvelle candidature de ${candidatData['nom']} pour l'offre ${nouvelle.offreTitre}",
      context,
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
          Container(
            width: 280,
            color: Colors.blue[900],
            child: Column(
              children: [
                const SizedBox(height: 40),
                const ProfileImagePicker(),
                const SizedBox(height: 15),
                Text(
                  candidatData['nom']!,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  candidatData['filiere']!,
                  style: TextStyle(color: Colors.blue[100], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView(
                    children: [
                      _buildMenuItem(0, Icons.person, "Mon Profil"),
                      _buildMenuItem(1, Icons.search, "Mes Offres"),
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
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: const Size.fromHeight(45),
                    ),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text("Déconnexion", style: TextStyle(color: Colors.white)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
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
          NotificationService().resetCandidateCount();
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
                      future: SubscriptionService().getRemainingDaysForCandidate(candidatData['email']!),
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
              onPressed: _hasMonthlyPass ? null : () async {
                final success = await PaymentService.payCandidateMonthly(context, candidatData['email']!);
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
                  await SubscriptionService().resetSubscription(candidatData['email']!, 'candidate');
                  await _checkMonthlyPass();
                  if (!mounted) return;
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
                  _buildProfileRow("Nom Complet", candidatData['nom'] ?? ''),
                  _buildProfileRow("Téléphone", candidatData['telephone'] ?? ''),
                  _buildProfileRow("Adresse Email", candidatData['email'] ?? ''),
                  _buildProfileRow("Filière / Spécialité", candidatData['filiere'] ?? ''),
                  _buildProfileRow("Sexe", candidatData['sexe'] ?? ''),
                  _buildProfileRow("Âge", candidatData['age'] ?? ''),
                  _buildProfileRow("Lieu de résidence", candidatData['domicile'] ?? ''),
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
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("CV chargé (fichier non image, téléchargement bientôt disponible)")),
                              );
                            },
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

  Widget _buildProfileRow(String label, String? value) {
    final displayValue = (value != null && value.isNotEmpty) ? value : 'Non précisé';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 3, child: Text(displayValue, style: TextStyle(fontSize: 16, color: Colors.blue[900], fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  // ================== TABLEAU DE BORD ==================
  Widget _buildDashboard() {
    final candidatures = CandidatureService().getCandidaturesForCandidate(candidatData['email']!);
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
                                    color: statutColor.withAlpha((0.1 * 255).round()),
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
          boxShadow: [BoxShadow(color: Colors.grey.withAlpha(26), blurRadius: 4, offset: const Offset(0, 2))],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Offres de stages & d'emplois disponibles", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900])),
        const SizedBox(height: 20),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: ApiService.getOffres(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(child: Text("Erreur: ${snapshot.error}"));
              }

              List<dynamic> offres = snapshot.data ?? [];
              
              return offres.isEmpty 
              ? const Center(child: Text("Aucune offre disponible pour le moment."))
              : ListView.builder(
                itemCount: offres.length,
                itemBuilder: (context, index) {
                  final o = offres[index] as Map<String, dynamic>;
                  final offreTitre = o['titre'] ?? 'Offre';
                  final entrepriseNom = o['nom_societe'] ?? 'Entreprise inconnue';
                  final dejaPostule = _aDejaPostule(offreTitre, entrepriseNom);
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: o['logo_url'] != null
                          ? CircleAvatar(backgroundImage: NetworkImage(o['logo_url']))
                          : const CircleAvatar(child: Icon(Icons.business)),
                      title: Text(offreTitre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("$entrepriseNom - ${o['lieu'] ?? 'Lieu'} (${o['type_contrat'] ?? 'Type'})"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!dejaPostule)
                            ElevatedButton(
                              onPressed: () {
                                Map<String, String> offreData = {
                                  'id': o['id'].toString(),
                                  'titre': offreTitre,
                                  'poste': offreTitre,
                                  'entreprise': entrepriseNom,
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
                            onPressed: () {
                              ChatService().getOrCreateConversationForCandidate(
                                candidatEmail: candidatData['email']!,
                                candidatName: candidatData['nom']!,
                                entrepriseName: entrepriseNom,
                              );
                              NotificationService().notifyCompany(
                                "Le candidat ${candidatData['nom']} a initié un chat avec vous.",
                                context,
                              );
                              setState(() => _selectedIndex = 5);
                            },
                            child: const Text("Contacter"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _openPostulationForm(BuildContext context, {required Map<String, String> offre}) {
    final parentContext = context;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PostulationFormDialog(
          offre: offre,
          candidatEmail: candidatData['email']!,
          candidatNom: candidatData['nom']!,
          candidatTel: candidatData['telephone']!,
          onValidate: (nom, telephone, email, photoBytes, cvBytes, cnibRecto, cnibVerso) async {
            Navigator.of(dialogContext).pop(); // Ferme le formulaire
            
            final pageContext = parentContext;
            try {
              if (!mounted) return;
              final hasPass = await SubscriptionService().hasCandidateMonthlyPass(candidatData['email']!);
              if (!mounted) return;
              
              if (hasPass) {
                // Abonné : Candidature directe
                await _creerEtAjouterCandidature(nom, telephone, email, photoBytes, cvBytes, cnibRecto, cnibVerso, offre);
              } else {
                // Non abonné : Paiement 500 FCFA
                final bool paymentSuccess = await PaymentService.payCandidatePerApplication(
                  pageContext, 
                  candidatData['email']!, 
                  offre['titre'] ?? "Offre"
                );
                
                if (paymentSuccess) {
                  await _creerEtAjouterCandidature(nom, telephone, email, photoBytes, cvBytes, cnibRecto, cnibVerso, offre);
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(pageContext).showSnackBar(
                    const SnackBar(content: Text("❌ Paiement échoué."), backgroundColor: Colors.red),
                  );
                }
              }
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(pageContext).showSnackBar(SnackBar(content: Text("Erreur: $e")));
            }
          },
        );
      },
    );
  }

// Nouvelle méthode helper pour éviter la duplication
Future<void> _creerEtAjouterCandidature(nom, tel, email, photo, cv, recto, verso, offre) async {
  try {
    // Récupérer le token
    final token = await ApiService.getToken();
    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur: Token non trouvé"), backgroundColor: Colors.red),
      );
      return;
    }

    // Créer l'objet candidature localement
    final nouvelle = Candidature(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      offreTitre: offre['titre'] ?? "Offre",
      entreprise: offre['entreprise'] ?? "Inconnue",
      datePostulation: DateTime.now(),
      statut: "En cours",
      candidatEmail: candidatData['email']!,
      candidatNom: nom,
      candidatTel: tel,
      candidatEmailContact: email,
      photoBytes: photo,
      cvBytes: cv,
      cnibRectoBytes: recto,
      cnibVersoBytes: verso,
    );

    // Envoyer la candidature au serveur
    if (offre['id'] != null) {
      try {
        await ApiService.applyForOffer(
          offreId: offre['id'],
          token: token,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'envoi de la candidature: $e"), backgroundColor: Colors.red),
        );
      }
    }

    // Ajouter localement aussi
    _ajouterCandidature(nouvelle);
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red),
    );
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
    final conversations = ChatService().getConversationsForCandidate(candidatData['email']!);
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
            subtitle: Text(conv.messages.isNotEmpty ? conv.messages.last.text : "Aucun message"),
            trailing: conv.unreadCountForCandidate > 0
                ? CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Text('${conv.unreadCountForCandidate}', style: const TextStyle(color: Colors.white, fontSize: 12)))
                : const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ChatService().markAsReadForCandidate(conv.id);
              _refreshCounts();
              Navigator.push(context, MaterialPageRoute(builder: (context) => CandidateChatScreen(conversationId: conv.id, candidatData: candidatData)));
            },
          ),
        );
      },
    );
  }

  // ================== NOTIFICATIONS ==================
  Widget _buildNotificationsContent() {
    final list = NotificationService().notifications.where((n) => n.contains('[Candidat]')).toList();
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

  @override
  void initState() {
    super.initState();
    _nomCtrl.text = widget.candidatNom;
    _telCtrl.text = widget.candidatTel;
    _emailCtrl.text = widget.candidatEmail;
  }

  String _extensionFromFileName(String fileName) {
    final parts = fileName.toLowerCase().split('.');
    return parts.length > 1 ? parts.last : '';
  }

  bool _isValidCvFile(String fileName) {
    final extension = _extensionFromFileName(fileName);
    return ['pdf', 'doc', 'docx'].contains(extension);
  }

  bool _isValidCnibImage(String fileName) {
    final extension = _extensionFromFileName(fileName);
    return ['jpg', 'jpeg', 'png'].contains(extension);
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        if (!mounted) return;
        setState(() => _photoBytes = bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur photo : $e")));
      }
    }
  }

  Future<void> _pickCV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      if (result != null) {
        final pickedFile = result.files.first;
        final fileName = pickedFile.name;
        if (!_isValidCvFile(fileName)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Veuillez sélectionner un fichier CV valide (PDF, DOC, DOCX)"))
          );
          return;
        }
        final bytes = pickedFile.bytes ?? (pickedFile.path != null ? await File(pickedFile.path!).readAsBytes() : null);
        if (bytes == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Impossible de lire le fichier CV sélectionné"))
          );
          return;
        }
        final validContent = await validateCvContent(bytes: bytes, fileName: fileName);
        if (!validContent) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Le document sélectionné ne ressemble pas à un CV valide"))
          );
          return;
        }
        if (!mounted) return;
        setState(() {
          _cvBytes = bytes;
          _cvFileName = fileName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("CV chargé avec succès"))
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez sélectionner un fichier PDF ou DOC"))
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur CV : $e"))
        );
      }
    }
  }

  Future<void> _pickCNIBRecto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final imageName = image.name;
        if (!_isValidCnibImage(imageName)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Veuillez sélectionner une image CNIB valide (JPG ou PNG)"))
          );
          return;
        }
        final path = image.path;
        final validContent = path.isNotEmpty && await validateCnibImage(path);
        if (!validContent) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("L'image sélectionnée ne semble pas être une CNIB valide"))
          );
          return;
        }
        final bytes = await image.readAsBytes();
        if (!mounted) return;
        setState(() {
          _cnibRectoBytes = bytes;
          _cnibRectoFileName = imageName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recto CNIB chargé avec succès"))
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur recto CNIB : $e"))
        );
      }
    }
  }

  Future<void> _pickCNIBVerso() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final imageName = image.name;
        if (!_isValidCnibImage(imageName)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Veuillez sélectionner une image CNIB valide (JPG ou PNG)"))
          );
          return;
        }
        final path = image.path;
        final validContent = path.isNotEmpty && await validateCnibImage(path);
        if (!validContent) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("L'image sélectionnée ne semble pas être une CNIB valide"))
          );
          return;
        }
        final bytes = await image.readAsBytes();
        if (!mounted) return;
        setState(() {
          _cnibVersoBytes = bytes;
          _cnibVersoFileName = imageName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verso CNIB chargé avec succès"))
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur verso CNIB : $e"))
        );
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
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
                      trailing: ElevatedButton(
                        onPressed: _pickCV,
                        child: Text(_cvBytes == null ? "Importer" : "Modifier"),
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
                      trailing: ElevatedButton(
                        onPressed: _pickCNIBRecto,
                        child: Text(_cnibRectoBytes == null ? "Importer" : "Modifier"),
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
                      trailing: ElevatedButton(
                        onPressed: _pickCNIBVerso,
                        child: Text(_cnibVersoBytes == null ? "Importer" : "Modifier"),
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

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final conversations = ChatService().getConversationsForCandidate(widget.candidatData['email']!);
    final conv = conversations.firstWhere(
      (c) => c.id == widget.conversationId,
      orElse: () => throw Exception("Conversation introuvable"),
    );
    setState(() {
      ChatService().sendMessageFromCandidate(
        widget.candidatData['email']!,
        widget.candidatData['nom']!,
        conv.otherPartyName,
        _controller.text.trim(),
      );
      _controller.clear();
    });
    NotificationService().notifyCompany(
      "Nouveau message de ${widget.candidatData['nom']}",
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversations = ChatService().getConversationsForCandidate(widget.candidatData['email']!);
    late final Conversation currentConv;
    try {
      currentConv = conversations.firstWhere((c) => c.id == widget.conversationId);
    } catch (e) {
      return Scaffold(
        appBar: AppBar(title: const Text("Discussion"), backgroundColor: Colors.blue[900]),
        body: const Center(child: Text("Conversation introuvable.")),
      );
    }
    final conv = currentConv;
    return Scaffold(
      appBar: AppBar(
        title: Text("Discussion avec ${conv.otherPartyName}"),
        backgroundColor: Colors.blue[900],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: conv.messages.length,
              itemBuilder: (context, index) {
                final msg = conv.messages.reversed.toList()[index];
                final isMe = msg.senderId.startsWith('candidat');
                // Utiliser senderName pour afficher le nom correct
                final displayName = isMe 
                    ? (widget.candidatData['nom'] ?? "Moi")
                    : msg.senderName;  // Nom de l'entreprise
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
                              onPressed: () {
                                setState(() {
                                  ChatService().deleteMessage(widget.conversationId, msg.id);
                                });
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
      ),
    );
  }
}