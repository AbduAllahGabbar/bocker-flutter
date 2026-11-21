import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/notification_model.dart';
import '../../data/repositories/notifications_repository.dart';
import 'notification_counters_cubit.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;
  final NotificationCountersCubit? _counters;

  static const int pageSize = 15;

  Timer? _searchDebounce;

  NotificationsCubit({
    required NotificationsRepository repository,
    NotificationCountersCubit? counters,
  }) : _repository = repository,
       _counters = counters,
       super(const NotificationsState());

  Future<void> load({bool refresh = false}) async {
    if (!refresh) {
      emit(
        state.copyWith(status: NotificationsStatus.loading, clearError: true),
      );
    }

    final result = await _repository.list(
      limit: pageSize,
      skip: 0,
      search: state.search,
      unreadOnly: state.unreadOnly,
    );

    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NotificationsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (page) {
        emit(
          state.copyWith(
            status: NotificationsStatus.success,
            items: page.items,
            total: page.total,
            unread: page.unread,
            hasMore: page.hasMore,
            isLoadingMore: false,
            clearError: true,
          ),
        );
        _counters?.setUnreadNotifications(page.unread);
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));

    final result = await _repository.list(
      limit: pageSize,
      skip: state.items.length,
      search: state.search,
      unreadOnly: state.unreadOnly,
    );

    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingMore: false, errorMessage: failure.message),
      ),
      (page) {
        final merged = [...state.items, ...page.items];
        emit(
          state.copyWith(
            items: merged,
            total: page.total,
            unread: page.unread,
            hasMore: merged.length < page.total && page.items.isNotEmpty,
            isLoadingMore: false,
            clearError: true,
          ),
        );
        _counters?.setUnreadNotifications(page.unread);
      },
    );
  }

  void search(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (isClosed) return;
      emit(state.copyWith(search: value.trim()));
      load();
    });
  }

  void toggleUnreadOnly(bool value) {
    emit(state.copyWith(unreadOnly: value));
    load();
  }

  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.seen) return;

    // Optimistic: flip locally, roll back if the backend rejects it.
    final previous = state;
    _applyLocalSeen([notification.id]);

    final result = await _repository.markSeen([notification.id]);
    if (isClosed) return;
    result.fold((failure) {
      emit(previous.copyWith(errorMessage: failure.message));
    }, (_) => _counters?.setUnreadNotifications(state.unread));
  }

  Future<void> markAllAsRead() async {
    if (state.unread == 0) return;
    emit(state.copyWith(isMutating: true, clearError: true));

    final result = await _repository.markAllSeen();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(isMutating: false, errorMessage: failure.message),
      ),
      (_) {
        emit(
          state.copyWith(
            isMutating: false,
            items: state.items.map((e) => e.copyWith(seen: true)).toList(),
            unread: 0,
          ),
        );
        _counters?.setUnreadNotifications(0);
        // unreadOnly lists become empty once everything is read.
        if (state.unreadOnly) load();
      },
    );
  }

  Future<void> deleteOne(NotificationModel notification) async {
    emit(state.copyWith(isMutating: true, clearError: true));

    final result = await _repository.delete([notification.id]);
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(isMutating: false, errorMessage: failure.message),
      ),
      (_) {
        final remaining = state.items
            .where((e) => e.id != notification.id)
            .toList();
        final unread = notification.seen ? state.unread : state.unread - 1;
        emit(
          state.copyWith(
            isMutating: false,
            items: remaining,
            total: (state.total - 1).clamp(0, 1 << 30),
            unread: unread.clamp(0, 1 << 30),
          ),
        );
        _counters?.setUnreadNotifications(state.unread);
      },
    );
  }

  Future<void> deleteAll() async {
    if (state.items.isEmpty) return;
    emit(state.copyWith(isMutating: true, clearError: true));

    final result = await _repository.deleteAll();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(isMutating: false, errorMessage: failure.message),
      ),
      (_) {
        emit(
          state.copyWith(
            isMutating: false,
            items: const [],
            total: 0,
            unread: 0,
            hasMore: false,
          ),
        );
        _counters?.setUnreadNotifications(0);
      },
    );
  }

  void _applyLocalSeen(List<String> ids) {
    var unread = state.unread;
    final items = state.items.map((item) {
      if (ids.contains(item.id) && !item.seen) {
        unread -= 1;
        return item.copyWith(seen: true);
      }
      return item;
    }).toList();

    emit(
      state.copyWith(
        items: items,
        unread: unread.clamp(0, 1 << 30),
        clearError: true,
      ),
    );
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
