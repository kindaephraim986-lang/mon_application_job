import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends StatefulWidget {
  const ProfileImagePicker({Key? key}) : super(key: key);

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  // On stocke les données brutes de l'image (bytes) plutôt qu'un XFile.
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // 1. Lire les données brutes de l'image.
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        setState(() {
          // 2. Stocker ces données.
          _imageBytes = imageBytes;
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de la sélection de l'image : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white24,
            // 3. Afficher l'image à partir des données bytes en mémoire.
            backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
            child: _imageBytes == null
                ? const Icon(Icons.person, size: 50, color: Colors.white70)
                : null,
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


