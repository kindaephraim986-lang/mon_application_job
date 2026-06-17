import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pdf_text/pdf_text.dart';

String extractFileExtension(String fileName) {
  final parts = fileName.toLowerCase().split('.');
  return parts.length > 1 ? parts.last : '';
}

bool isCvExtension(String fileName) {
  return ['pdf', 'doc', 'docx'].contains(extractFileExtension(fileName));
}

bool isCnibImageExtension(String fileName) {
  return ['jpg', 'jpeg', 'png'].contains(extractFileExtension(fileName));
}

bool _countKeywords(String text, Iterable<String> keywords, int requiredCount) {
  final lower = text.toLowerCase();
  var count = 0;
  for (final keyword in keywords) {
    if (lower.contains(keyword)) {
      count += 1;
    }
    if (count >= requiredCount) {
      return true;
    }
  }
  return false;
}

bool _hasCvKeywords(String text) {
  const keywords = [
    'expérience',
    'experience',
    'formation',
    'compétences',
    'competences',
    'compétence',
    'competence',
    'diplôme',
    'diplome',
    'profil',
    'objectif',
    'adresse',
    'email',
    'e-mail',
    'téléphone',
    'telephone',
    'loisirs',
    'stage',
    'professionnel',
    'projet',
    'références',
    'references',
  ];
  return _countKeywords(text, keywords, 2);
}

bool _hasCnibKeywords(String text) {
  const keywords = [
    'carte',
    'nationale',
    'identité',
    'identite',
    'république',
    'republique',
    'sénégal',
    'senegal',
    'cnib',
    'cni',
    'numéro',
    'numero',
    'nom',
    'prénom',
    'prenom',
    'date de naissance',
    'lieu de naissance',
  ];
  return _countKeywords(text, keywords, 2);
}

Future<File> _writeTempFile(Uint8List bytes, String fileName) async {
  final tempDir = Directory.systemTemp;
  final uniqueName = 'temp_${DateTime.now().microsecondsSinceEpoch}_$fileName';
  final tempFile = File('${tempDir.path}/$uniqueName');
  await tempFile.writeAsBytes(bytes, flush: true);
  return tempFile;
}

Future<bool> validateCvContent({Uint8List? bytes, String? filePath, required String fileName}) async {
  final extension = extractFileExtension(fileName);
  try {
    if (extension == 'pdf') {
      final path = filePath ?? (bytes != null ? (await _writeTempFile(bytes, 'temp_cv.pdf')).path : null);
      if (path == null) return false;
      final doc = await PDFDoc.fromPath(path);
      final text = await doc.text;
      return _hasCvKeywords(text);
    }

    final data = bytes ?? (filePath != null ? await File(filePath).readAsBytes() : null);
    if (data == null) return false;

    if (extension == 'docx') {
      final archive = ZipDecoder().decodeBytes(data);
      final documentFile = archive.firstWhere(
        (file) => file.name == 'word/document.xml',
        orElse: () => ArchiveFile('', 0, null),
      );
      if (documentFile == null || documentFile.content == null) {
        return false;
      }
      final xml = utf8.decode(documentFile.content as List<int>);
      final text = xml.replaceAll(RegExp(r'<[^>]*>'), ' ');
      return _hasCvKeywords(text);
    }

    if (extension == 'doc') {
      final text = latin1.decode(data);
      return _hasCvKeywords(text);
    }
  } catch (_) {
    return false;
  }
  return false;
}

Future<bool> validateCnibImage(String imagePath) async {
  try {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    return _hasCnibKeywords(recognizedText.text);
  } catch (_) {
    return false;
  }
}
