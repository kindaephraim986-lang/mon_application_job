String ensureInternationalPhone(String phone) {
  final p = phone.trim();
  if (p.isEmpty) return p;
  if (p.startsWith('+')) return p;
  if (p.startsWith('0')) return '+226${p.replaceFirst(RegExp(r'^0+'), '')}';
  if (RegExp(r'^\d+$').hasMatch(p)) return '+226$p';
  return p;
}

bool isValidPhoneNumber(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return false;

  final digits = normalized.replaceAll(RegExp(r'[^\d]'), '');
  return digits.length >= 7 && digits.length <= 15;
}

String formatPhoneNumber(String rawPhone, String dialCode) {
  var digits = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');
  if (digits.startsWith('+')) return digits;
  digits = digits.replaceFirst(RegExp(r'^0+'), '');
  return '$dialCode$digits';
}
