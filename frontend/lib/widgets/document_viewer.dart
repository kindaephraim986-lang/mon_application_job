/// lib/widgets/document_viewer.dart
/// Lecteur de documents (PDF, images) avec téléchargement

import 'package:flutter/material.dart';
import '../services/document_service.dart';

class DocumentViewer extends StatefulWidget {
  final int documentId;
  final String documentType;
  final int candidatId;
  final String title;

  const DocumentViewer({
    Key? key,
    required this.documentId,
    required this.documentType,
    required this.candidatId,
    required this.title,
  }) : super(key: key);

  @override
  State<DocumentViewer> createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<DocumentViewer> {
  late Future<Map<String, dynamic>> _signedUrlFuture;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _generateSignedUrl();
  }

  void _generateSignedUrl() {
    _signedUrlFuture = DocumentService.generateSignedUrl(
      documentId: widget.documentId,
      documentType: widget.documentType,
      candidatId: widget.candidatId,
    );
  }

  Future<void> _downloadDocument(String signedUrl, String filename) async {
    setState(() => _isDownloading = true);

    final success = await DocumentService.downloadDocument(
      signedUrl: signedUrl,
      filename: filename,
    );

    if (mounted) {
      setState(() => _isDownloading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Téléchargement lancé...'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Erreur lors du téléchargement'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openDocument(String signedUrl) async {
    final success = await DocumentService.openDocumentInBrowser(signedUrl);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Erreur lors de l\'ouverture du document'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _signedUrlFuture,
        builder: (context, snapshot) {
          // Erreur d'abonnement
          if (snapshot.hasData && snapshot.data!['requiresSubscription'] == true) {
            return _buildSubscriptionRequired();
          }

          // Erreur générale
          if (snapshot.hasData && snapshot.data!['success'] != true) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    snapshot.data!['message'] ?? 'Erreur d\'accès au document',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                    onPressed: () {
                      setState(_generateSignedUrl);
                    },
                  ),
                ],
              ),
            );
          }

          // En attente
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final signedUrl = snapshot.data!['signedUrl'] as String? ?? '';
          final filename = '${widget.documentType}_${widget.candidatId}';

          return SingleChildScrollView(
            child: Column(
              children: [
                // Aperçu du document
                _buildDocumentPreview(signedUrl),

                // Actions
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Visualiser'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => _openDocument(signedUrl),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text('Télécharger'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: _isDownloading
                              ? null
                              : () => _downloadDocument(signedUrl, filename),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentPreview(String signedUrl) {
    // Pour les PDFs : afficher un placeholder
    if (widget.documentType == 'cv') {
      return Container(
        width: double.infinity,
        height: 400,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Document PDF\nCliquez sur "Visualiser" pour ouvrir',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Pour les images : afficher un aperçu
    if (['cnib_recto', 'cnib_verso', 'photo'].contains(widget.documentType)) {
      return Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 300),
        color: Colors.grey[100],
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 3.0,
          child: Image.network(
            signedUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('Impossible de charger l\'aperçu'),
              ],
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSubscriptionRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: Colors.orange[400]),
            const SizedBox(height: 24),
            const Text(
              'Abonnement requis',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Vous devez souscrire à un abonnement pour accéder aux coordonnées et documents des candidats.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.card_membership),
              label: const Text('Souscrire maintenant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                // TODO: Naviguer vers la page d'abonnement
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget simplifié pour afficher un bouton d'accès aux documents
class DocumentAccessButton extends StatelessWidget {
  final int documentId;
  final String documentType;
  final int candidatId;
  final String label;

  const DocumentAccessButton({
    Key? key,
    required this.documentId,
    required this.documentType,
    required this.candidatId,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(DocumentService.getDocumentIcon(documentType)),
      label: Text(label),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DocumentViewer(
              documentId: documentId,
              documentType: documentType,
              candidatId: candidatId,
              title: DocumentService.getDocumentLabel(documentType),
            ),
          ),
        );
      },
    );
  }
}
