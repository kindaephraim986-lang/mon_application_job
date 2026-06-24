/// Fallback implementation for non-web platforms.

Future<bool> downloadDocument({
  required String signedUrl,
  required String filename,
}) async {
  // Non-web fallback: direct browser download is not supported on this platform.
  return false;
}

Future<bool> openDocumentInBrowser(String signedUrl) async {
  // Non-web fallback: opening a document in browser is not supported on this platform.
  return false;
}
