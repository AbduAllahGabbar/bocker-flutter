enum MessageType {
  text,
  image,
  file,
  unknown;

  static MessageType fromString(String? type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      default:
        return MessageType.unknown;
    }
  }
}

class FileModel {
  final String name;
  final String path;
  final int size;
  final String url;

  FileModel({
    required this.name,
    required this.path,
    required this.size,
    required this.url,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      name: json['name']?.toString() ?? 'Attachment',
      path: json['path']?.toString() ?? '',
      size: (json['size'] as num?)?.toInt() ?? 0,
      url: json['url']?.toString() ?? '',
    );
  }
}

class UserModel {
  final int id;
  final String name;

  UserModel({
    required this.id,
    required this.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? 'User',
    );
  }
}

class MessageModel {
  final String type; // 'user' or 'support'
  final UserModel? user;
  final MessageType messageType;
  final String? textContent;
  final FileModel? fileContent;
  final String? date;
  final bool isSeen;
  final String? code;
  final String? time;
  final Map<String, dynamic> originalJson;

  MessageModel({
    required this.type,
    this.user,
    required this.messageType,
    this.textContent,
    this.fileContent,
    this.date,
    this.isSeen = false,
    this.code,
    this.time,
    required this.originalJson,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final msgTypeStr = json['messageType']?.toString();
    final messageType = MessageType.fromString(msgTypeStr);
    
    final rawMessage = json['message'];
    
    String? textContent;
    FileModel? fileContent;

    if (rawMessage != null) {
      if (messageType == MessageType.text) {
        textContent = rawMessage.toString();
      } else if (rawMessage is Map<String, dynamic>) {
        fileContent = FileModel.fromJson(rawMessage);
      }
    }

    UserModel? user;
    if (json['user'] is Map<String, dynamic>) {
      user = UserModel.fromJson(json['user']);
    }

    return MessageModel(
      type: json['type']?.toString() ?? 'user',
      user: user,
      messageType: messageType,
      textContent: textContent,
      fileContent: fileContent,
      date: json['date']?.toString(),
      isSeen: json['isSeen'] == true,
      code: json['code']?.toString(),
      time: json['time']?.toString(),
      originalJson: json,
    );
  }
}
