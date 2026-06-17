import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'candidate_dashboard.dart';

class ProfileConfirmationScreen extends StatefulWidget {
  final Map<String, String> userData;
  final Uint8List? photoBytes;

  const ProfileConfirmationScreen({
    Key? key,
    required this.userData,
    this.photoBytes,
  }) : super(key: key);

  @override
  State<ProfileConfirmationScreen> createState() => _ProfileConfirmationScreenState();
}

class _ProfileConfirmationScreenState extends State<ProfileConfirmationScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const SizedBox(),
        title: const Text(
          "Mon Profil Professionnel",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Photo de Profil
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue[100],
                      border: Border.all(
                        color: Colors.blue[300]!,
                        width: 2,
                      ),
                    ),
                    child: widget.photoBytes != null
                        ? ClipOval(
                            child: Image.memory(
                              widget.photoBytes!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.blue,
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.userData['nom'] ?? 'Nom non spécifié',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.userData['filiere'] ?? 'Filière non spécifiée',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 24),

            // Section Informations Personnelles
            const Text(
              "Informations Personnelles",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildProfileRow("Nom Complet", widget.userData['nom'] ?? 'Non spécifié'),
            _buildProfileRow("Téléphone", widget.userData['telephone'] ?? 'Non spécifié'),
            _buildProfileRow("Adresse Email", widget.userData['email'] ?? 'Non spécifié'),
            _buildProfileRow("Filière / Spécialité", widget.userData['filiere'] ?? widget.userData['filiere_specialite'] ?? 'Non spécifié'),
            _buildProfileRow("Sexe", widget.userData['sexe'] ?? widget.userData['genre'] ?? 'Non spécifié'),
            _buildProfileRow("Âge", widget.userData['age'] ?? 'Non spécifié'),
            _buildProfileRow("Lieu de résidence", widget.userData['domicile'] ?? widget.userData['villeLieu'] ?? 'Non spécifié'),

            const SizedBox(height: 24),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 24),

            // Section Curriculum Vitae
            const Text(
              "Curriculum Vitae (CV)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.description, color: Colors.blue[700], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.userData['cvUrl']?.isNotEmpty == true ? "✓ CV chargé" : "CV non chargé",
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.userData['cvUrl']?.isNotEmpty == true ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (widget.userData['cvUrl']?.isNotEmpty == true)
                    Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 24),

            // Section CNIB
            const Text(
              "CNIB (Recto / Verso)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            _buildDocumentStatus("CNIB - Recto", widget.userData['cnibRectoUrl']?.isNotEmpty == true),
            const SizedBox(height: 12),
            _buildDocumentStatus("CNIB - Verso", widget.userData['cnibVersoUrl']?.isNotEmpty == true),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CandidateDashboard(initialData: widget.userData),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            "Accéder au Tableau de Bord",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentStatus(String title, bool isLoaded) {
    return Container(
      decoration: BoxDecoration(
        color: isLoaded ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLoaded ? Colors.green[200]! : Colors.grey[300]!,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Icon(
            Icons.credit_card,
            color: isLoaded ? Colors.green[700] : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: isLoaded ? Colors.green[700] : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isLoaded)
            Icon(Icons.check_circle, color: Colors.green[700], size: 20)
          else
            Icon(Icons.cancel, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }
}
