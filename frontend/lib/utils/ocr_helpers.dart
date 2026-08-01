String _normalizeText(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r'[\u0300-\u036f]'), '')
      .replaceAll(RegExp(r'[^a-z0-9\s:+-]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _cleanPhone(String raw) {
  return raw.replaceAll(RegExp(r'[^0-9+]'), '');
}

String _extractPattern(String text, RegExp pattern) {
  final match = pattern.firstMatch(text);
  return match != null && match.groupCount >= 1 ? match.group(1)!.trim() : '';
}

Map<String, String> extractCandidateFieldsFromOcr(String rawOcrText) {
  final normalized = _normalizeText(rawOcrText);

  return {
    'nom': _extractPattern(normalized, RegExp(r'nom\s*[:\-]\s*([a-z\s]+)', caseSensitive: false)),
    'telephone': _cleanPhone(_extractPattern(normalized, RegExp(r'(?:tel|telephone)\s*[:\-]?\s*([0-9+\s-]{8,20})', caseSensitive: false))),
    'age': _extractPattern(normalized, RegExp(r'age\s*[:\-]?\s*([0-9]{1,3})', caseSensitive: false)),
    'domicile': _extractPattern(normalized, RegExp(r'(?:adresse|domicile|ville)\s*[:\-]\s*([a-z0-9\s]+)', caseSensitive: false)),
  };
}

Map<String, dynamic> buildOcrVerificationPayload({
  required Map<String, dynamic> userData,
  required Map<String, dynamic> ocrData,
}) {
  return {
    'userData': {
      'nom': userData['nom'] ?? userData['fullName'] ?? '',
      'telephone': userData['telephone'] ?? '',
      'age': userData['age']?.toString() ?? '',
      'domicile': userData['domicile'] ?? userData['adresse'] ?? '',
    },
    'ocrData': {
      'nom': ocrData['nom'] ?? '',
      'telephone': ocrData['telephone'] ?? '',
      'age': ocrData['age']?.toString() ?? '',
      'domicile': ocrData['domicile'] ?? '',
    },
  };
}

