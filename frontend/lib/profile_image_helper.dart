import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/profile_photo_service.dart';

class ProfileImagePicker extends StatefulWidget {
  final String? initialPhotoUrl;
  final Future<String?> Function(Uint8List imageBytes, String filename)? onImageUploaded;

  const ProfileImagePicker({super.key, this.initialPhotoUrl, this.onImageUploaded});

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  Uint8List? _imageBytes;
  String? _photoUrl;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _photoUrl = widget.initialPhotoUrl;
  }

  @override
  void didUpdateWidget(covariant ProfileImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPhotoUrl != oldWidget.initialPhotoUrl) {
      setState(() {
        _photoUrl = widget.initialPhotoUrl;
        if (_photoUrl == null || _photoUrl!.isEmpty) {
          _imageBytes = null;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = imageBytes;
        });

        if (widget.onImageUploaded != null) {
          setState(() {
            _isUploading = true;
          });
          try {
            final uploadedUrl = await widget.onImageUploaded!(imageBytes, pickedFile.name);
            if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
              setState(() {
                _photoUrl = uploadedUrl;
                _imageBytes = null;
              });
            }
          } catch (e) {
            debugPrint('Erreur upload image: $e');
          } finally {
            if (mounted) {
              setState(() {
                _isUploading = false;
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Erreur lors de la sélection de l'image : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? resolvedPhotoUrl = _photoUrl != null && _photoUrl!.isNotEmpty
        ? ProfilePhotoService.generateCachedUrl(_photoUrl!)
        : null;
    final ImageProvider? backgroundImage = _imageBytes != null
      ? MemoryImage(_imageBytes!) as ImageProvider
      : (resolvedPhotoUrl != null && resolvedPhotoUrl.isNotEmpty ? NetworkImage(resolvedPhotoUrl) as ImageProvider : null);

    return GestureDetector(
      onTap: _isUploading ? null : _pickImage,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white24,
            backgroundImage: backgroundImage,
            child: _isUploading
                ? const CircularProgressIndicator(color: Colors.white)
                : (backgroundImage == null ? const Icon(Icons.person, size: 50, color: Colors.white70) : null),
          ),
          const SizedBox(height: 8),
          const Text(
            "Modifier la photo",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}



