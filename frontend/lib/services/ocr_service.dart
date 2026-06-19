import '../services/api_service.dart';

class OcrService {
  /// Envoie les données utilisateur et OCR au backend pour vérification.
  static Future<Map<String, dynamic>> verifyDocuments({
    required Map<String, dynamic> userData,
    required Map<String, dynamic> ocrData,
  }) async {
    return await ApiService.verifyOcrData(userData: userData, ocrData: ocrData);
  }
}
