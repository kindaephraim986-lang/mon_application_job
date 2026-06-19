/// lib/widgets/profile_photo_widget.dart
/// Widget pour afficher et gérer la photo de profil

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/profile_photo_service.dart';

class ProfilePhotoWidget extends StatefulWidget {
  final bool editable;
  final VoidCallback? onPhotoUpdated;
  final String candidatId;

  const ProfilePhotoWidget({
    Key? key,
    this.editable = true,
    this.onPhotoUpdated,
    required this.candidatId,
  }) : super(key: key);

  @override
  State<ProfilePhotoWidget> createState() => _ProfilePhotoWidgetState();
}

class _ProfilePhotoWidgetState extends State<ProfilePhotoWidget> {
  late Future<Map<String, dynamic>> _photoFuture;
  bool _isUploading = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadPhotoUrl();
  }

  void _loadPhotoUrl() {
    _photoFuture = ProfilePhotoService.getCurrentPhoto();
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      // Lire le fichier en bytes
      final imageBytes = await pickedFile.readAsBytes();

      // Uploader la photo
      final result = await ProfilePhotoService.uploadProfilePhoto(imageBytes);

      if (mounted) {
        setState(() => _isUploading = false);

            if (result['success'] == true) {
          // Mettre à jour l'URL et cache buster
          setState(() {
            _photoUrl = result['photoUrl'];
          });

          // Recharger la photo
          _loadPhotoUrl();

          // Notifier le parent
          widget.onPhotoUpdated?.call();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Photo mise à jour avec succès'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${result['message']}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _photoFuture,
      builder: (context, snapshot) {
        String? displayUrl;

        // Utiliser l'URL avec cache buster si disponible
        if (_photoUrl != null) {
          displayUrl = ProfilePhotoService.generateCachedUrl(_photoUrl!);
        } else if (snapshot.hasData && snapshot.data!['success'] == true) {
          final photoUrl = snapshot.data!['photoUrl'] as String?;
          if (photoUrl != null) {
            displayUrl = ProfilePhotoService.generateCachedUrl(photoUrl);
          }
        }

        return Stack(
          children: [
            // Photo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: displayUrl != null
                  ? ClipOval(
                      child: Image.network(
                        displayUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(Icons.person, size: 60, color: Colors.grey[400]),
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(Icons.person, size: 60, color: Colors.grey[400]),
                    ),
            ),

            // Bouton d'édition
            if (widget.editable)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _isUploading ? null : _pickAndUploadPhoto,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Widget pour afficher l'historique des photos
class PhotoHistoryDialog extends StatelessWidget {
  final String candidatId;

  const PhotoHistoryDialog({Key? key, required this.candidatId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: ProfilePhotoService.getPhotoHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              width: 400,
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final photos = snapshot.data ?? [];

          return SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Historique des photos',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                if (photos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Aucune photo',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                else
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        final photo = photos[index];
                        final isCurrent = photo['isCurrent'] as bool? ?? false;

                        return GestureDetector(
                          onTap: () {
                            // Afficher la photo en plein écran
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                child: InteractiveViewer(
                                  child: Image.network(
                                    ProfilePhotoService.generateCachedUrl(
                                      photo['photoUrl'] as String? ?? '',
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: isCurrent
                                      ? Border.all(color: Colors.green, width: 3)
                                      : null,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    ProfilePhotoService.generateCachedUrl(
                                      photo['photoUrl'] as String? ?? '',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              if (isCurrent)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
