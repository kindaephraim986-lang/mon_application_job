import 'package:flutter/foundation.dart';

class Candidature {
  final String id;
  final String offreTitre;
  final String entreprise;
  final DateTime datePostulation;
  String statut; // "En cours", "Acceptée", "Refusée"
  final String candidatEmail;
  final String candidatNom;
  final String candidatTel;
  final String candidatEmailContact;
  final Uint8List? photoBytes;
  final Uint8List? cvBytes;
  final Uint8List? cnibRectoBytes;  // Ajout
  final Uint8List? cnibVersoBytes;  // Ajout

  Candidature({
    required this.id,
    required this.offreTitre,
    required this.entreprise,
    required this.datePostulation,
    required this.statut,
    required this.candidatEmail,
    required this.candidatNom,
    required this.candidatTel,
    required this.candidatEmailContact,
    this.photoBytes,
    this.cvBytes,
    this.cnibRectoBytes,
    this.cnibVersoBytes,
  });
}

class CandidatureService {
  static final CandidatureService _instance = CandidatureService._internal();
  factory CandidatureService() => _instance;
  CandidatureService._internal();

  final List<Candidature> _candidatures = [];
  
  // Centralisation des offres partagées (ValueNotifier pour notifications)
  final offresGlobalesNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([
    {
      'id': '1',
      'typeContrat': 'Stage',
      'titre': 'Développeur Flutter H/F',
      'description': 'Développement d’applications mobiles avec Flutter.',
      'competences': 'Dart, Flutter, Git',
      'niveau': 'Bac+3',
      'experience': '1 an',
      'lieu': 'Ouagadougou / Remote',
      'salaire': '',
      'logoBytes': null,
      'entreprise': 'TechCorp SAS',
    },
    {
      'id': '2',
      'typeContrat': 'Emploi',
      'titre': 'Administrateur Base de Données',
      'description': 'Gestion des bases de données de l\'entreprise.',
      'competences': 'MySQL, PostgreSQL',
      'niveau': 'Bac+3',
      'experience': '2 ans',
      'lieu': 'Bobo-Dioulasso',
      'salaire': '',
      'logoBytes': null,
      'entreprise': 'Innov Faso',
    }
  ]);

  List<Map<String, dynamic>> get offresGlobales => offresGlobalesNotifier.value;

  void addOffer(Map<String, dynamic> offre) {
    final newList = List<Map<String, dynamic>>.from(offresGlobalesNotifier.value);
    newList.add(offre);
    offresGlobalesNotifier.value = newList;
  }

  void replaceOffers(List<Map<String, dynamic>> offres) {
    offresGlobalesNotifier.value = List<Map<String, dynamic>>.from(offres);
  }

  void clearOffers() {
    offresGlobalesNotifier.value = [];
  }

  void removeOfferById(String id) {
    final newList = List<Map<String, dynamic>>.from(offresGlobalesNotifier.value);
    newList.removeWhere((o) => o['id'] == id);
    offresGlobalesNotifier.value = newList;
  }

  List<Candidature> getCandidaturesForCandidate(String email) {
    return _candidatures.where((c) => c.candidatEmail == email).toList();
  }

  List<Candidature> getCandidaturesForCompany(String entrepriseName) {
    return _candidatures.where((c) => c.entreprise == entrepriseName).toList();
  }

  void addCandidature(Candidature candidature) {
    _candidatures.add(candidature);
  }

  void removeCandidature(String id) {
    _candidatures.removeWhere((c) => c.id == id);
  }

  void updateStatut(String id, String nouveauStatut) {
    final index = _candidatures.indexWhere((c) => c.id == id);
    if (index != -1) {
      _candidatures[index].statut = nouveauStatut;
    }
  }

  bool aDejaPostule(String candidatEmail, String offreTitre, String entreprise) {
    return _candidatures.any((c) =>
        c.candidatEmail == candidatEmail &&
        c.offreTitre == offreTitre &&
        c.entreprise == entreprise);
  }
}



