import 'package:flutter/material.dart';
import '../services/ocr_service.dart';
import '../utils/ocr_helpers.dart';

class OcrVerificationScreen extends StatefulWidget {
  const OcrVerificationScreen({super.key});

  @override
  State<OcrVerificationScreen> createState() => _OcrVerificationScreenState();
}

class _OcrVerificationScreenState extends State<OcrVerificationScreen> {
  final _rawOcrController = TextEditingController();
  String _result = '';

  Future<void> _verify() async {
    final rawOcr = _rawOcrController.text;
    if (rawOcr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Texte OCR requis')));
      return;
    }

    final ocrData = extractCandidateFieldsFromOcr(rawOcr);
    final userData = {
      'nom': 'Jean Dupont',
      'telephone': '0781234567',
      'age': '28',
      'domicile': 'Dakar',
    };

    final response = await OcrService.verifyDocuments(userData: userData, ocrData: ocrData);

    if (response['success'] == true) {
      setState(() {
        _result = 'Résultat de vérification : ${response['comparison']}';
      });
    } else {
      setState(() {
        _result = 'Erreur : ${response['message'] ?? 'Impossible de vérifier'}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vérification OCR')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _rawOcrController,
              decoration: const InputDecoration(
                labelText: 'Texte extrait OCR',
                border: OutlineInputBorder(),
              ),
              minLines: 6,
              maxLines: 10,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _verify,
              child: const Text('Vérifier les données'),
            ),
            const SizedBox(height: 16),
            Text(_result),
          ],
        ),
      ),
    );
  }
}

