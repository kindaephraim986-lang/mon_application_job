// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:typed_data';

String _createObjectUrl(Uint8List bytes, String mimeType) {
  final blob = html.Blob(<Object>[bytes], mimeType);
  return html.Url.createObjectUrlFromBlob(blob);
}

Future<bool> saveBytesToDownloads(Uint8List bytes, String suggestedName) async {
  try {
    final url = _createObjectUrl(bytes, 'application/octet-stream');
    final anchor = html.AnchorElement(href: url)
      ..download = suggestedName
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
    return true;
  } catch (_) {
    return false;
  }
}

Future<String?> createTemporaryFile(Uint8List bytes, String fileName) async {
  return null;
}

Future<bool> openBytesInBrowser(
  Uint8List bytes,
  String fileName,
  String mimeType,
) async {
  try {
    final url = _createObjectUrl(bytes, mimeType);
    html.window.open(url, '_blank');
    return true;
  } catch (_) {
    return false;
  }
}
