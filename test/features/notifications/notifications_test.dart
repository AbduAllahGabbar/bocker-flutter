import 'package:boker/core/errors/failure.dart';
import 'package:boker/features/notifications/data/data_source/notifications_remote_data_source.dart';
import 'package:boker/features/notifications/data/models/notification_model.dart';
import 'package:boker/features/notifications/data/repositories/notifications_repository.dart';
import 'package:boker/features/notifications/presentation/cubit/notification_counters_cubit.dart';
import 'package:boker/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:boker/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:boker/features/notifications/presentation/notification_navigator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

Map<String, dynamic> _listResponse({
  int total = 2,
  int unread = 1,
  int skip = 0,
  int limit = 15,
}) {
  return {
    'done': true,
    'items': [
      {
        'id': 'n1',
        'type': 'transaction',
        'title': 'Deposit approved',
        'body': 'Your deposit was approved',
        'url': '/transactions/55',
        'meta': {'transactionId': 55},
        'seen': false,
        'createdAt': '2026-11-01T10:00:00.000Z',
      },
      {
        'id': 'n2',
        'type': 'system',
        'title': 'Welcome',
        'body': 'Welcome to Boker',
        'seen': true,
        'createdAt': '2026-10-01T10:00:00.000Z',
      },
    ],
    'total': total,
    'unread': unread,
    'limit': limit,
    'skip': skip,
  };
}

void main() {
  setUpAll(() => registerFallbackValue(<String>[]));

  group('NotificationsPage parsing', () {
    test('reads the documented list response', () {
      final page = NotificationsPage.fromJson(_listResponse());

      expect(page.items, hasLength(2));
      expect(page.total, 2);
      expect(page.unread, 1);
      expect(page.limit, 15);
      expect(page.skip, 0);
      expect(page.hasMore, isFalse);

      final first = page.items.first;
      expect(first.id, 'n1');
      expect(first.type, 'transaction');
      expect(first.seen, isFalse);
      expect(first.url, '/transactions/55');
      expect(first.meta['transactionId'], 55);
      expect(first.createdAt, isNotNull);
    });

    test('knows when another page is available', () {
      final page = NotificationsPage.fromJson(
        _listResponse(total: 40, skip: 0),
      );
      expect(page.hasMore, isTrue);
    });

    test('tolerates a response with no items', () {
      final page = NotificationsPage.fromJson({'done': true});
      expect(page.items, isEmpty);
      expect(page.total, 0);
    });
  });

  group('NotificationSummary parsing', () {
    test('reads both unread counters', () {
      final summary = NotificationSummary.fromJson({
        'done': true,
        'unreadNotifications': 4,
        'unreadMessages': 2,
      });

      expect(summary.unreadNotifications, 4);
      expect(summary.unreadMessages, 2);
      expect(summary.total, 6);
    });

    test('defaults to zero when counters are missing', () {
      final summary = NotificationSummary.fromJson({'done': true});
      expect(summary.unreadNotifications, 0);
      expect(summary.unreadMessages, 0);
    });
  });

  group('NotificationsCubit', () {
    late _MockNotificationsRepository repository;
    late NotificationsCubit cubit;

    setUp(() {
      repository = _MockNotificationsRepository();
      cubit = NotificationsCubit(repository: repository);

      when(
        () => repository.list(
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          search: any(named: 'search'),
          unreadOnly: any(named: 'unreadOnly'),
        ),
      ).thenAnswer(
        (_) async => Right(NotificationsPage.fromJson(_listResponse())),
      );
    });

    tearDown(() => cubit.close());

    test('loads the first page with the documented request', () async {
      await cubit.load();

      expect(cubit.state.status, NotificationsStatus.success);
      expect(cubit.state.items, hasLength(2));
      expect(cubit.state.unread, 1);

      verify(
        () =>
            repository.list(limit: 15, skip: 0, search: '', unreadOnly: false),
      ).called(1);
    });

    test('paginates with limit/skip', () async {
      when(
        () => repository.list(
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          search: any(named: 'search'),
          unreadOnly: any(named: 'unreadOnly'),
        ),
      ).thenAnswer(
        (_) async =>
            Right(NotificationsPage.fromJson(_listResponse(total: 40))),
      );

      await cubit.load();
      expect(cubit.state.hasMore, isTrue);

      await cubit.loadMore();

      verify(
        () =>
            repository.list(limit: 15, skip: 2, search: '', unreadOnly: false),
      ).called(1);
      expect(cubit.state.items, hasLength(4));
    });

    test('applies the unread-only filter', () async {
      await cubit.load();
      cubit.toggleUnreadOnly(true);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.unreadOnly, isTrue);
      verify(
        () => repository.list(limit: 15, skip: 0, search: '', unreadOnly: true),
      ).called(1);
    });

    test('marks one notification as read and decrements the counter', () async {
      when(
        () => repository.markSeen(any()),
      ).thenAnswer((_) async => const Right(null));

      await cubit.load();
      final unreadItem = cubit.state.items.first;
      await cubit.markAsRead(unreadItem);

      expect(cubit.state.items.first.seen, isTrue);
      expect(cubit.state.unread, 0);
      verify(() => repository.markSeen(['n1'])).called(1);
    });

    test('does not call the API for an already-read notification', () async {
      await cubit.load();

      await cubit.markAsRead(cubit.state.items.last);

      verifyNever(() => repository.markSeen(any()));
    });

    test('rolls back an optimistic read when the API rejects it', () async {
      when(
        () => repository.markSeen(any()),
      ).thenAnswer((_) async => const Left(ServerFailure(message: 'nope')));

      await cubit.load();
      await cubit.markAsRead(cubit.state.items.first);

      expect(cubit.state.items.first.seen, isFalse);
      expect(cubit.state.unread, 1);
      expect(cubit.state.errorMessage, 'nope');
    });

    test('marks everything as read', () async {
      when(repository.markAllSeen).thenAnswer((_) async => const Right(null));

      await cubit.load();
      await cubit.markAllAsRead();

      expect(cubit.state.items.every((item) => item.seen), isTrue);
      expect(cubit.state.unread, 0);
      verify(repository.markAllSeen).called(1);
    });

    test('deletes one notification', () async {
      when(
        () => repository.delete(any()),
      ).thenAnswer((_) async => const Right(null));

      await cubit.load();
      await cubit.deleteOne(cubit.state.items.first);

      expect(cubit.state.items, hasLength(1));
      expect(cubit.state.items.single.id, 'n2');
      expect(cubit.state.unread, 0);
      verify(() => repository.delete(['n1'])).called(1);
    });

    test('deletes everything', () async {
      when(repository.deleteAll).thenAnswer((_) async => const Right(null));

      await cubit.load();
      await cubit.deleteAll();

      expect(cubit.state.items, isEmpty);
      expect(cubit.state.total, 0);
      expect(cubit.state.unread, 0);
    });

    test('surfaces a load failure with a retryable state', () async {
      when(
        () => repository.list(
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          search: any(named: 'search'),
          unreadOnly: any(named: 'unreadOnly'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure(message: 'offline')));

      await cubit.load();

      expect(cubit.state.status, NotificationsStatus.failure);
      expect(cubit.state.errorMessage, 'offline');
    });
  });

  group('NotificationCountersCubit', () {
    late _MockNotificationsRepository repository;
    late NotificationCountersCubit cubit;

    setUp(() {
      repository = _MockNotificationsRepository();
      cubit = NotificationCountersCubit(repository: repository);
      when(
        () => repository.activityStream(cancelToken: any(named: 'cancelToken')),
      ).thenAnswer((_) => const Stream<ActivityEvent>.empty());
    });

    tearDown(() => cubit.close());

    test('starts at zero', () {
      expect(cubit.state.unreadNotifications, 0);
      expect(cubit.state.unreadMessages, 0);
    });

    test('refreshes from the summary endpoint', () async {
      when(repository.summary).thenAnswer(
        (_) async => const Right(
          NotificationSummary(unreadNotifications: 3, unreadMessages: 7),
        ),
      );

      await cubit.refresh();

      expect(cubit.state.unreadNotifications, 3);
      expect(cubit.state.unreadMessages, 7);
    });

    test('leaves the counters untouched when the summary fails', () async {
      when(
        repository.summary,
      ).thenAnswer((_) async => const Left(ServerFailure(message: 'offline')));

      await cubit.refresh();

      expect(cubit.state.unreadNotifications, 0);
    });

    test('clears the counters on sign-out', () async {
      when(repository.summary).thenAnswer(
        (_) async => const Right(
          NotificationSummary(unreadNotifications: 3, unreadMessages: 2),
        ),
      );
      await cubit.refresh();

      cubit.clear();

      expect(cubit.state, const NotificationSummary());
    });

    test('message counters never go negative', () {
      cubit.setUnreadMessages(-5);
      expect(cubit.state.unreadMessages, 0);
    });
  });

  group('NotificationNavigator', () {
    NotificationModel notification(String? url) =>
        NotificationModel(id: 'n', url: url);

    test('maps known web routes onto app routes', () {
      expect(
        NotificationNavigator.resolveRouteName(notification('/transactions/5')),
        'home',
      );
      expect(
        NotificationNavigator.resolveRouteName(notification('/accounts')),
        'accounts',
      );
      expect(
        NotificationNavigator.resolveRouteName(
          notification('/payment-methods'),
        ),
        'payment-details',
      );
      expect(
        NotificationNavigator.resolveRouteName(notification('/tickets/12')),
        'help-center',
      );
    });

    test('maps an absolute backend URL by its path', () {
      expect(
        NotificationNavigator.resolveRouteName(
          notification('https://atm-crm.egytag.com/accounts'),
        ),
        'accounts',
      );
    });

    test('refuses to resolve unknown or missing destinations', () {
      expect(
        NotificationNavigator.resolveRouteName(notification(null)),
        isNull,
      );
      expect(NotificationNavigator.resolveRouteName(notification('')), isNull);
      expect(
        NotificationNavigator.resolveRouteName(
          notification('https://evil.example.com/phish'),
        ),
        isNull,
      );
    });
  });
}
