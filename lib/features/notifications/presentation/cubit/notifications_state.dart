import 'package:equatable/equatable.dart';

import '../../data/models/notification_model.dart';

enum NotificationsStatus { initial, loading, success, failure }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<NotificationModel> items;
  final int total;
  final int unread;
  final String search;
  final bool unreadOnly;
  final bool hasMore;
  final bool isLoadingMore;

  /// Set while a mark-as-read / delete call is in flight.
  final bool isMutating;
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.items = const [],
    this.total = 0,
    this.unread = 0,
    this.search = '',
    this.unreadOnly = false,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isMutating = false,
    this.errorMessage,
  });

  bool get isEmpty => status == NotificationsStatus.success && items.isEmpty;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationModel>? items,
    int? total,
    int? unread,
    String? search,
    bool? unreadOnly,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isMutating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      total: total ?? this.total,
      unread: unread ?? this.unread,
      search: search ?? this.search,
      unreadOnly: unreadOnly ?? this.unreadOnly,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    total,
    unread,
    search,
    unreadOnly,
    hasMore,
    isLoadingMore,
    isMutating,
    errorMessage,
  ];
}
