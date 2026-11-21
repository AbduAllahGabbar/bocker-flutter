/// A single entry from `POST /api/notifications/list`.
///
/// Shape (per the Boker backend contract):
/// `{ id, type, title, body, url, meta, seen, createdAt }`
class NotificationModel {
  final String id;
  final String? type;
  final String? title;
  final String? body;

  /// Web route the notification points at, e.g. `/transactions/123`.
  /// Validated before it is acted upon — see `NotificationNavigator`.
  final String? url;

  final Map<String, dynamic> meta;
  final bool seen;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    this.type,
    this.title,
    this.body,
    this.url,
    this.meta = const {},
    this.seen = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      type: json['type']?.toString(),
      title: json['title']?.toString(),
      body: json['body']?.toString(),
      url: json['url']?.toString(),
      meta: json['meta'] is Map
          ? Map<String, dynamic>.from(json['meta'] as Map)
          : const {},
      seen: json['seen'] == true,
      createdAt: _parseDate(json['createdAt'] ?? json['date']),
    );
  }

  NotificationModel copyWith({bool? seen}) {
    return NotificationModel(
      id: id,
      type: type,
      title: title,
      body: body,
      url: url,
      meta: meta,
      seen: seen ?? this.seen,
      createdAt: createdAt,
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return DateTime.tryParse(value.toString());
  }
}

/// Page returned by `POST /api/notifications/list`.
class NotificationsPage {
  final List<NotificationModel> items;
  final int total;
  final int unread;
  final int limit;
  final int skip;

  const NotificationsPage({
    required this.items,
    required this.total,
    required this.unread,
    required this.limit,
    required this.skip,
  });

  factory NotificationsPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return NotificationsPage(
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (e) =>
                      NotificationModel.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
      total: _int(json['total']),
      unread: _int(json['unread']),
      limit: _int(json['limit']),
      skip: _int(json['skip']),
    );
  }

  bool get hasMore => skip + items.length < total;

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

/// Counters returned by `POST /api/notifications/summary`.
class NotificationSummary {
  final int unreadNotifications;
  final int unreadMessages;

  const NotificationSummary({
    this.unreadNotifications = 0,
    this.unreadMessages = 0,
  });

  factory NotificationSummary.fromJson(Map<String, dynamic> json) {
    return NotificationSummary(
      unreadNotifications: NotificationsPage._int(
        json['unreadNotifications'] ?? 0,
      ),
      unreadMessages: NotificationsPage._int(json['unreadMessages'] ?? 0),
    );
  }

  NotificationSummary copyWith({
    int? unreadNotifications,
    int? unreadMessages,
  }) {
    return NotificationSummary(
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      unreadMessages: unreadMessages ?? this.unreadMessages,
    );
  }

  int get total => unreadNotifications + unreadMessages;

  @override
  bool operator ==(Object other) =>
      other is NotificationSummary &&
      other.unreadNotifications == unreadNotifications &&
      other.unreadMessages == unreadMessages;

  @override
  int get hashCode => Object.hash(unreadNotifications, unreadMessages);
}
