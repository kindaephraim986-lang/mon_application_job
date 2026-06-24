// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

Future<bool> downloadDocument({
  required String signedUrl,
  required String filename,
}) async {
  try {
    final anchor = html.AnchorElement(href: signedUrl)
      ..download = filename
      ..rel = 'noopener'
      ..target = '_blank';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> openDocumentInBrowser(String signedUrl) async {
  try {
    html.window.open(signedUrl, '_blank');
    return true;
  } catch (_) {
    return false;
  }
}
