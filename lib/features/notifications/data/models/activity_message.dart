import '../../../auth/data/repository/user_access.dart';

/// Reads a `message-new` payload from the activity stream.
///
/// The exact shape is decided by the backend: the message may sit inline or
/// nested under `message` / `doc`, and the sender may be named by `type`
/// (`user` / `support`, as in `MessageModel`), by `from`, or by a user object.
/// Every reader of the event goes through here so they all agree.
class ActivityMessage {
  const ActivityMessage._();

  static const Set<String> _ownSenders = {'user', 'client', 'customer', 'me'};
  static const Set<String> _otherSenders = {
    'support',
    'admin',
    'agent',
    'staff',
    'system',
  };

  /// The event data with any nested message object merged on top of it.
  static Map<String, dynamic> flatten(Map<String, dynamic> data) {
    final result = <String, dynamic>{...data};
    for (final key in const ['message', 'doc', 'data']) {
      final nested = data[key];
      if (nested is Map) result.addAll(Map<String, dynamic>.from(nested));
    }
    return result;
  }

  /// `true` when the event is the echo of a message the signed-in user just
  /// sent. Such an echo needs no notification and no re-read: the reply from
  /// `messages/add-user` already put the message in the conversation.
  ///
  /// An unrecognised sender counts as incoming — a redundant refresh is
  /// cheaper than a missed message.
  static bool isFromCurrentUser(Map<String, dynamic> data) {
    final payload = flatten(data);

    for (final key in const ['type', 'from', 'sender', 'direction']) {
      final value = payload[key]?.toString().trim().toLowerCase();
      if (value == null || value.isEmpty) continue;
      if (_otherSenders.contains(value)) return false;
      if (_ownSenders.contains(value)) return true;
    }

    final currentUserId = UserAccess.user?.userId;
    if (currentUserId == null || currentUserId.isEmpty) return false;

    for (final key in const ['userId', 'senderId', 'fromUserId']) {
      if (payload[key]?.toString() == currentUserId) return true;
    }
    final user = payload['user'];
    if (user is Map && user['id']?.toString() == currentUserId) return true;

    return false;
  }

  /// Text to show in a notification body, when the payload carries one.
  static String? previewText(Map<String, dynamic> data) {
    final payload = flatten(data);

    for (final key in const ['body', 'text', 'message', 'content']) {
      final value = payload[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      // A file message: `message` is an object, so name the attachment.
      if (value is Map) {
        final name = value['name']?.toString().trim();
        if (name != null && name.isNotEmpty) return name;
      }
    }
    return null;
  }
}
