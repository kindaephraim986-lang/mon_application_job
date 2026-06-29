import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<bool> saveBytesToDownloads(Uint8List bytes, String suggestedName) async {
  final outputPath = await FilePicker.saveFile(
    dialogTitle: 'Enregistrer le fichier',
    fileName: suggestedName,
    bytes: bytes,
  );

  if (outputPath == null) return false;

  final file = File(outputPath);
  if (!await file.exists()) {
    await file.writeAsBytes(bytes);
  }
  return true;
}

Future<String?> createTemporaryFile(Uint8List bytes, String fileName) async {
  final tempDir = await Directory.systemTemp.createTemp('cv_preview_');
  final file = File('${tempDir.path}${Platform.pathSeparator}$fileName');
  await file.writeAsBytes(bytes);
  return file.path;
}

Future<bool> openBytesInBrowser(
  Uint8List bytes,
  String fileName,
  String mimeType,
) async {
  return false;
}
