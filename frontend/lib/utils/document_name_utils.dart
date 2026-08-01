String getDisplayFileName(String? source, {required String fallback}) {
  final value = source?.trim() ?? '';
  if (value.isEmpty) {
    return fallback;
  }

  final uri = Uri.tryParse(value);
  if (uri != null) {
    final segments = uri.pathSegments.where((segment) => segment.isNotEmpty).toList();
    if (segments.isNotEmpty) {
      final lastSegment = segments.last;
      if (lastSegment.contains('.')) {
        return lastSegment;
      }
    }
  }

  return fallback;
}

