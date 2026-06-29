import 'dart:typed_data';

import 'file_actions_stub.dart'
    if (dart.library.io) 'file_actions_io.dart'
    if (dart.library.html) 'file_actions_web.dart' as impl;

class FileActions {
  static Future<bool> saveBytesToDownloads(
    Uint8List bytes,
    String suggestedName,
  ) {
    return impl.saveBytesToDownloads(bytes, suggestedName);
  }

  static Future<String?> createTemporaryFile(
    Uint8List bytes,
    String fileName,
  ) {
    return impl.createTemporaryFile(bytes, fileName);
  }

  static Future<bool> openBytesInBrowser(
    Uint8List bytes,
    String fileName,
    String mimeType,
  ) {
    return impl.openBytesInBrowser(bytes, fileName, mimeType);
  }
}
