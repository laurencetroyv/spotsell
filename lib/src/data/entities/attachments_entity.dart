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
