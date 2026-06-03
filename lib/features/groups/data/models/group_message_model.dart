enum GroupMessageType {
  text,
  image,
  file,
  link,
}

class GroupMessageModel {
  const GroupMessageModel({
    required this.id,
    required this.senderId,
    required this.senderEmail,
    required this.text,
    required this.type,
    this.fileUrl,
    this.fileName,
    this.storagePath,
    this.createdAt,
    this.updatedAt,
    this.readBy = const [],
  });

  final String id;
  final String senderId;
  final String senderEmail;
  final String text;
  final GroupMessageType type;
  final String? fileUrl;
  final String? fileName;
  final String? storagePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String> readBy;

  factory GroupMessageModel.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return GroupMessageModel(
      id: id,
      senderId: data['senderId'] as String? ?? '',
      senderEmail: data['senderEmail'] as String? ?? '',
      text: data['text'] as String? ?? '',
      type: _messageTypeFromString(data['type'] as String?),
      fileUrl: data['fileUrl'] as String?,
      fileName: data['fileName'] as String?,
      storagePath: data['storagePath'] as String?,
      createdAt: data['createdAt'] == null
          ? null
          : (data['createdAt'] as dynamic).toDate() as DateTime,
      updatedAt: data['updatedAt'] == null
          ? null
          : (data['updatedAt'] as dynamic).toDate() as DateTime,
      readBy: List<String>.from(data['readBy'] ?? []),
    );
  }

  static GroupMessageType _messageTypeFromString(String? value) {
    switch (value) {
      case 'image':
        return GroupMessageType.image;
      case 'file':
        return GroupMessageType.file;
      case 'link':
        return GroupMessageType.link;
      case 'text':
      default:
        return GroupMessageType.text;
    }
  }

  String get typeValue {
    switch (type) {
      case GroupMessageType.image:
        return 'image';
      case GroupMessageType.file:
        return 'file';
      case GroupMessageType.link:
        return 'link';
      case GroupMessageType.text:
        return 'text';
    }
  }
}
