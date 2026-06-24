/// lib/services/document_service.dart
/// Service pour gérer l'accès aux documents (CV, CNIB) avec URLs signées

import 'package:flutter/material.dart';
import 'api_service.dart';
import 'document_service_stub.dart' if (dart.library.html) 'document_service_web.dart' as web_impl;

class DocumentService {
  static final DocumentService _instance = DocumentService._internal();

  factory DocumentService() {
    return _instance;
  }

  DocumentService._internal();

  /// Générer une URL signée pour accéder à un document
  /// @param documentId - ID du document
  /// @param documentType - Type du document (cv, cnib_recto, cnib_verso, photo)
  /// @param candidatId - ID du candidat propriétaire
  /// @return URL signée ou erreur
  static Future<Map<String, dynamic>> generateSignedUrl({
    required int documentId,
    required String documentType,
    required int candidatId
  }) async {
    try {
      final response = await ApiService.generateSignedUrl(
        documentId: documentId,
        documentType: documentType,
        candidatId: candidatId
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'signedUrl': response['signedUrl'],
          'expiresIn': response['expiresIn'] ?? 3600
        };
      }

      // Si erreur 402 (abonnement requis)
      if (response['statusCode'] == 402) {
        return {
          'success': false,
          'message': response['message'] ?? 'Abonnement requis',
          'code': 'SUBSCRIPTION_REQUIRED',
          'requiresSubscription': true
        };
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Erreur lors de la génération de l\'URL'
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Erreur: $error'
      };
    }
  }

  /// Télécharger un document (force le download)
  /// @param signedUrl - URL signée du document
  /// @param filename - Nom du fichier à télécharger
  static Future<bool> downloadDocument({
    required String signedUrl,
    required String filename
  }) async {
    return await web_impl.downloadDocument(
      signedUrl: signedUrl,
      filename: filename,
    );
  }

  /// Ouvrir un document dans le navigateur (affichage inline)
  /// @param signedUrl - URL signée du document
  static Future<bool> openDocumentInBrowser(String signedUrl) async {
    return await web_impl.openDocumentInBrowser(signedUrl);
  }

  /// Obtenir les infos du document
  /// @param signedUrl - URL signée (contient le token)
  static Future<Map<String, dynamic>> getDocumentInfo(String signedUrl) async {
    try {
      // Extraire le token de l'URL signée
      final token = signedUrl.split('/').last;

      final response = await ApiService.getDocumentInfo(token);

      if (response['success'] == true) {
        return {
          'success': true,
          'documentId': response['documentId'],
          'documentType': response['documentType'],
          'fileSize': response['fileSize'],
          'filename': response['filename'],
          'createdAt': response['createdAt']
        };
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Erreur'
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Erreur: $error'
      };
    }
  }

  /// Formater la taille de fichier
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  /// Obtenir l'icône pour un type de document
  static IconData getDocumentIcon(String documentType) {
    switch (documentType) {
      case 'cv':
        return Icons.description;
      case 'cnib_recto':
      case 'cnib_verso':
        return Icons.credit_card;
      case 'photo':
        return Icons.photo;
      default:
        return Icons.file_present;
    }
  }

  /// Obtenir le label pour un type de document
  static String getDocumentLabel(String documentType) {
    switch (documentType) {
      case 'cv':
        return 'CV';
      case 'cnib_recto':
        return 'CNIB (Recto)';
      case 'cnib_verso':
        return 'CNIB (Verso)';
      case 'photo':
        return 'Photo';
      default:
        return 'Document';
    }
  }
}
