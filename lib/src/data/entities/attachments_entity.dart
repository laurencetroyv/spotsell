import 'dart:io';

import 'package:flutter/foundation.dart';

class Attachment {
  String id, originalName, mimeType, url;
  int fileSize;

  Attachment({
    required this.id,
    required this.originalName,
    required this.mimeType,
    required this.url,
    required this.fileSize,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      originalName: json['originalName'],
      mimeType: json['mimeType'],
      url: json['url'],
      fileSize: json['fileSize'],
    );
  }
}

class ImageData {
  final File? file;
  final Uint8List? bytes;
  final String? name;
  final String? mimeType;

  ImageData({this.file, this.bytes, this.name, this.mimeType});

  bool get isValid => (kIsWeb ? bytes != null : file != null);

  int get size {
    if (kIsWeb) {
      return bytes?.length ?? 0;
    } else {
      try {
        return file?.lengthSync() ?? 0;
      } catch (e) {
        return 0;
      }
    }
  }

  String get displayName {
    if (name != null) return name!;
    if (file != null) return file!.path.split('/').last;
    return 'Unknown';
  }
}
