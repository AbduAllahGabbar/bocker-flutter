/// A message the user tried to send that has not reached the server yet.
///
/// Failed sends stay in the conversation so the user can retry or discard
/// them instead of silently losing what they typed.
class OutgoingMessage {
  final String localId;

  /// Text body, for a text message.
  final String? text;

  /// Local path of the attachment, for a file/image message.
  final String? filePath;

  final bool isImage;

  /// Why the last attempt failed.
  final String? errorMessage;

  /// `true` while a send/retry is in flight.
  final bool isSending;

  const OutgoingMessage({
    required this.localId,
    this.text,
    this.filePath,
    this.isImage = false,
    this.errorMessage,
    this.isSending = false,
  });

  bool get isText => filePath == null;

  String get displayLabel {
    if (isText) return text ?? '';
    final path = filePath ?? '';
    return path.split(RegExp(r'[/\\]')).last;
  }

  OutgoingMessage copyWith({
    String? errorMessage,
    bool? isSending,
    bool clearError = false,
  }) {
    return OutgoingMessage(
      localId: localId,
      text: text,
      filePath: filePath,
      isImage: isImage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSending: isSending ?? this.isSending,
    );
  }
}
