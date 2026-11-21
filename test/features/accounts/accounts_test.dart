import 'package:boker/core/errors/failure.dart';
import 'package:boker/features/accounts/data/models/account_model.dart';
import 'package:boker/features/accounts/data/models/create_account_models.dart';
import 'package:boker/features/accounts/data/repositories/accounts_repository.dart';
import 'package:boker/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:boker/features/accounts/presentation/cubit/accounts_state.dart';
import 'package:boker/features/accounts/presentation/cubit/create_account_cubit.dart';
import 'package:boker/features/accounts/presentation/cubit/create_account_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAccountsRepository extends Mock implements AccountsRepository {}

/// A real account document as the backend returns it from `/accounts/all`.
Map<String, dynamic> _accountJson({
  String id = '12',
  String code = '100345',
  String type = 'real',
  Map<String, dynamic>? status,
  Map<String, dynamic>? mt5,
}) {
  return {
    '_id': '65f1c0ffee0000000000000$id',
    'id': int.parse(id),
    'code': code,
    'type': type,
    'balance': 1250.5,
    'equity': 1300,
    'credit': 0,
    'accountType': {'code': 'std', 'name': 'Standard', 'min': 100},
    'leverage': {'code': 'l100', 'name': '1:100'},
    'active': true,
    'date': '2026-10-02T03:20:23.000Z',
    if (status != null) 'status': status,
    if (mt5 != null) ...mt5,
  };
}

void main() {
  group('AccountModel', () {
    test('parses the backend document', () {
      final account = AccountModel.fromJson(_accountJson());

      expect(account.id, '12');
      expect(account.code, '100345');
      expect(account.balance, 1250.5);
      expect(account.isDemo, isFalse);
    });

    test('displayNumber shows the account CODE, never the internal id', () {
      final account = AccountModel.fromJson(
        _accountJson(id: '7', code: '100345'),
      );

      expect(account.displayNumber, '100345');
      expect(account.displayNumber, isNot('7'));
    });

    test('falls back to the id only when no code was returned', () {
      final account = AccountModel.fromJson(_accountJson(id: '7', code: ''));
      expect(account.displayNumber, '7');
    });

    test('reads the approval status', () {
      final pending = AccountModel.fromJson(
        _accountJson(status: {'code': 'pending', 'name': 'Pending'}),
      );
      expect(pending.isPending, isTrue);
      expect(pending.isApproved, isFalse);
      expect(pending.statusName, 'Pending');

      final approved = AccountModel.fromJson(
        _accountJson(status: {'code': 'approved', 'name': 'Approved'}),
      );
      expect(approved.isApproved, isTrue);
      expect(approved.isPending, isFalse);
    });

    test('exposes MT5 details when the backend sends them', () {
      final nested = AccountModel.fromJson(
        _accountJson(
          mt5: {
            'mt5': {
              'login': '500123',
              'server': 'Boker-Live',
              'group': 'real\\\\standard',
            },
          },
        ),
      );

      expect(nested.hasMt5Details, isTrue);
      expect(nested.mt5Login, '500123');
      expect(nested.mt5Server, 'Boker-Live');

      final flattened = AccountModel.fromJson(
        _accountJson(mt5: {'mt5Login': '500999'}),
      );
      expect(flattened.mt5Login, '500999');
    });

    test('reports no MT5 details when none were returned', () {
      final account = AccountModel.fromJson(_accountJson());
      expect(account.hasMt5Details, isFalse);
      expect(account.mt5Login, isNull);
    });
  });

  group('AccountsCubit', () {
    late _MockAccountsRepository repository;
    late AccountsCubit cubit;

    setUp(() {
      repository = _MockAccountsRepository();
      cubit = AccountsCubit(accountsRepository: repository);
    });

    tearDown(() => cubit.close());

    test('emits the real and demo accounts returned by the API', () async {
      final accounts = [
        AccountModel.fromJson(_accountJson(id: '1', code: '100001')),
        AccountModel.fromJson(
          _accountJson(id: '2', code: '900002', type: 'demo'),
        ),
      ];
      when(repository.getAccounts).thenAnswer((_) async => Right(accounts));

      await cubit.fetchAccounts();

      final state = cubit.state;
      expect(state, isA<AccountsLoaded>());
      expect((state as AccountsLoaded).accounts, hasLength(2));
      expect(
        state.accounts.where((a) => a.type == 'real').single.code,
        '100001',
      );
      expect(
        state.accounts.where((a) => a.type == 'demo').single.code,
        '900002',
      );
    });

    test('surfaces a failure message', () async {
      when(
        repository.getAccounts,
      ).thenAnswer((_) async => const Left(ServerFailure(message: 'boom')));

      await cubit.fetchAccounts();

      expect(cubit.state, isA<AccountsError>());
      expect((cubit.state as AccountsError).message, 'boom');
    });
  });

  group('CreateAccountCubit', () {
    late _MockAccountsRepository repository;
    late CreateAccountCubit cubit;

    setUp(() {
      repository = _MockAccountsRepository();
      cubit = CreateAccountCubit(repository: repository);
    });

    tearDown(() => cubit.close());

    test('keeps the created account instead of discarding it', () async {
      final created = AccountModel.fromJson(
        _accountJson(
          id: '42',
          code: '100042',
          status: {'code': 'pending', 'name': 'Pending'},
        ),
      );
      when(
        () => repository.createAccount(any()),
      ).thenAnswer((_) async => Right(created));

      cubit
        ..toggleAccountMode(true)
        ..setAccountType(
          AccountTypeModel(code: 'std', min: 100, name: 'Standard'),
        )
        ..setLeverage(LeverageModel(code: 'l100', name: '1:100'));

      await cubit.submit();

      expect(cubit.state, isA<CreateAccountSuccess>());
      final success = cubit.state as CreateAccountSuccess;
      expect(success.account.displayNumber, '100042');
      expect(success.account.isPending, isTrue);
      expect(cubit.createdAccount, isNotNull);
    });

    test('sends the real-account payload the backend expects', () async {
      when(
        () => repository.createAccount(any()),
      ).thenAnswer((_) async => Right(AccountModel.fromJson(_accountJson())));

      cubit
        ..toggleAccountMode(true)
        ..setAccountType(
          AccountTypeModel(code: 'std', min: 100, name: 'Standard'),
        )
        ..setLeverage(LeverageModel(code: 'l100', name: '1:100'));
      await cubit.submit();

      final payload =
          verify(() => repository.createAccount(captureAny())).captured.single
              as Map<String, dynamic>;

      expect(payload['type'], 'real');
      expect(payload['leverage'], {'code': 'l100', 'name': '1:100'});
      expect(payload['accountType'], {
        'code': 'std',
        'min': 100,
        'name': 'Standard',
      });
      expect(payload.containsKey('initialBalance'), isFalse);
    });

    test('sends the demo-account payload with an opening balance', () async {
      when(() => repository.createAccount(any())).thenAnswer(
        (_) async => Right(AccountModel.fromJson(_accountJson(type: 'demo'))),
      );

      cubit
        ..toggleAccountMode(false)
        ..setLeverage(LeverageModel(code: 'l50', name: '1:50'))
        ..setOpeningBalance(OpeningBalanceModel(code: 'b1k', name: '1000'));
      await cubit.submit();

      final payload =
          verify(() => repository.createAccount(captureAny())).captured.single
              as Map<String, dynamic>;

      expect(payload['type'], 'demo');
      expect(payload['initialBalance'], {'code': 'b1k', 'name': '1000'});
      expect(payload.containsKey('accountType'), isFalse);
    });

    test('refuses to submit an incomplete form', () async {
      cubit.toggleAccountMode(true);

      await cubit.submit();

      verifyNever(() => repository.createAccount(any()));
    });
  });
}
