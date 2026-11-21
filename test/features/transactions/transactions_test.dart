import 'package:boker/core/errors/failure.dart';
import 'package:boker/features/accounts/data/models/account_model.dart';
import 'package:boker/features/transactions/data/models/myfatoorah_quote_model.dart';
import 'package:boker/features/transactions/data/models/payment_method_model.dart';
import 'package:boker/features/transactions/data/models/transaction_model.dart';
import 'package:boker/features/transactions/data/repositories/transactions_repository.dart';
import 'package:boker/features/transactions/presentation/cubit/add_transaction_cubit.dart';
import 'package:boker/features/transactions/presentation/cubit/add_transaction_state.dart';
import 'package:boker/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:boker/features/transactions/presentation/cubit/transactions_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockTransactionsRepository extends Mock
    implements TransactionsRepository {}

AccountModel _account({String id = '12', String code = '100345'}) {
  return AccountModel.fromJson({
    '_id': 'mongo-$id',
    'id': int.parse(id),
    'code': code,
    'type': 'real',
    'balance': 500,
    'equity': 500,
    'credit': 0,
    'active': true,
    'date': '2026-10-02T03:20:23.000Z',
  });
}

TransactionModel _transaction({
  String id = 'tx-1',
  String code = 'TRX-1001',
  String status = 'pending',
}) {
  return TransactionModel.fromJson({
    '_id': id,
    'code': code,
    'amount': 100,
    'type': 'deposit',
    'date': '2026-11-01T10:00:00.000Z',
    'account': {'_id': 'mongo-12', 'id': 12, 'code': '100345'},
    'paymentMethod': {'code': 'myfatoorah', 'name': 'MyFatoorah'},
    'transactionStatus': {'code': status, 'name': status},
  });
}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('TransactionModel', () {
    test('shows account codes, not internal ids', () {
      final transaction = TransactionModel.fromJson({
        '_id': 'tx-9',
        'type': 'transfer',
        'amount': 50,
        'account': {'_id': 'a', 'id': 12, 'code': '100345'},
        'accountTo': {'_id': 'b', 'id': 13, 'code': '100346'},
      });

      expect(transaction.account!.displayNumber, '100345');
      expect(transaction.accountTo!.displayNumber, '100346');
    });

    test('falls back to the numeric id when no code is embedded', () {
      final transaction = TransactionModel.fromJson({
        '_id': 'tx-9',
        'account': {'_id': 'a', 'id': 12},
      });

      expect(transaction.account!.displayNumber, '12');
    });
  });

  group('TransactionModel payment outcome', () {
    TransactionModel build({
      String? crmStatus,
      Object? gateway,
      String? ticket,
    }) {
      return TransactionModel.fromJson({
        '_id': 'tx-1',
        'type': 'deposit',
        'amount': 100,
        if (crmStatus != null)
          'transactionStatus': {'code': crmStatus, 'name': crmStatus},
        if (gateway != null) 'paymentGateway': gateway,
        if (ticket != null) 'mt5DealTicket': ticket,
      });
    }

    test('a paid gateway payment is not success on its own', () {
      final transaction = build(
        crmStatus: 'pending',
        gateway: {'status': 'paid'},
      );

      expect(transaction.outcome, TransactionOutcome.awaitingConfirmation);
    });

    test('only an approved CRM transaction counts as completed', () {
      final transaction = build(
        crmStatus: 'approved',
        gateway: {'status': 'paid'},
        ticket: '123456',
      );

      expect(transaction.outcome, TransactionOutcome.completed);
      expect(transaction.isMt5Credited, isTrue);
    });

    test('a failed MT5 credit is neither success nor plain failure', () {
      final transaction = build(
        crmStatus: 'approved',
        gateway: {'status': 'paid-mt5-failed'},
      );

      expect(transaction.outcome, TransactionOutcome.creditFailed);
    });

    test('a gateway that could not verify the payment is reported as such', () {
      final transaction = build(
        crmStatus: 'pending',
        gateway: {'status': 'verification-failed'},
      );

      expect(transaction.outcome, TransactionOutcome.verificationFailed);
    });

    test('a rejected transaction stays rejected', () {
      expect(build(crmStatus: 'rejected').outcome, TransactionOutcome.rejected);
      expect(build(crmStatus: 'failed').outcome, TransactionOutcome.failed);
      expect(
        build(crmStatus: 'processing').outcome,
        TransactionOutcome.processing,
      );
      expect(build(crmStatus: 'pending').outcome, TransactionOutcome.pending);
    });

    test('reads a gateway status sent as a bare string', () {
      final transaction = build(crmStatus: 'pending', gateway: 'processing');

      expect(transaction.gatewayStatus, 'processing');
      expect(transaction.usedPaymentGateway, isTrue);
    });

    test('a manual deposit has no gateway block', () {
      expect(build(crmStatus: 'approved').usedPaymentGateway, isFalse);
      expect(
        build(crmStatus: 'approved').outcome,
        TransactionOutcome.completed,
      );
    });
  });

  group('PaymentMethodModel', () {
    test('matches the MyFatoorah code whatever its spelling', () {
      for (final code in const ['myfatoorah', 'MyFatoorah', 'my-fatoorah']) {
        final method = PaymentMethodModel.fromJson({
          'code': code,
          'name': 'MyFatoorah',
        });
        expect(AddTransactionCubit.isMyFatoorah(method), isTrue, reason: code);
      }

      expect(
        AddTransactionCubit.isMyFatoorah(
          PaymentMethodModel.fromJson({'code': 'bank', 'name': 'Wire'}),
        ),
        isFalse,
      );
    });

    test('a method is enabled unless the backend says otherwise', () {
      expect(
        PaymentMethodModel.fromJson({'code': 'bank', 'name': 'Wire'}).active,
        isTrue,
      );
      expect(
        PaymentMethodModel.fromJson({
          'code': 'bank',
          'name': 'Wire',
          'active': false,
        }).active,
        isFalse,
      );
    });
  });

  group('MyFatoorahQuoteModel', () {
    test('reads the fee breakdown the backend returned', () {
      final quote = MyFatoorahQuoteModel.fromJson({
        'done': true,
        'amount': 100,
        'fee': 5,
        'total': 105,
        'currency': 'KWD',
        'feeType': 'percent',
        'feeValue': 5,
      });

      expect(quote.amount, 100);
      expect(quote.fee, 5);
      expect(quote.total, 105);
      expect(quote.currency, 'KWD');
      expect(quote.hasBreakdown, isTrue);
    });

    test('reads a quote nested under a wrapper key', () {
      final quote = MyFatoorahQuoteModel.fromJson({
        'done': true,
        'quote': {'amount': 200, 'fees': 10, 'totalAmount': 210},
      });

      expect(quote.amount, 200);
      expect(quote.fee, 10);
      expect(quote.total, 210);
    });

    test('reports no breakdown rather than inventing numbers', () {
      final quote = MyFatoorahQuoteModel.fromJson({'done': true});

      expect(quote.hasBreakdown, isFalse);
      expect(quote.amount, isNull);
      expect(quote.fee, isNull);
      expect(quote.total, isNull);
    });
  });

  group('AddTransactionResult', () {
    test('picks up the gateway redirect URL', () {
      final result = AddTransactionResult.fromJson({
        'done': true,
        'doc': {'_id': 'tx-1', 'code': 'TRX-1', 'amount': 100},
        'payment': {'InvoiceURL': 'https://pay.example.com/i/1'},
      });

      expect(result.paymentUrl, 'https://pay.example.com/i/1');
      expect(result.requiresGatewayRedirect, isTrue);
      expect(result.transaction.code, 'TRX-1');
    });

    test('has no redirect for a manual deposit', () {
      final result = AddTransactionResult.fromJson({
        'done': true,
        'doc': {'_id': 'tx-2', 'code': 'TRX-2'},
      });

      expect(result.paymentUrl, isNull);
      expect(result.requiresGatewayRedirect, isFalse);
    });

    test('ignores a non-http value in a URL-shaped field', () {
      final result = AddTransactionResult.fromJson({
        'done': true,
        'doc': {'_id': 'tx-3'},
        'paymentUrl': 'javascript:alert(1)',
      });

      expect(result.paymentUrl, isNull);
    });
  });

  group('AddTransactionCubit', () {
    late _MockTransactionsRepository repository;
    late AddTransactionCubit cubit;

    setUp(() {
      repository = _MockTransactionsRepository();
      cubit = AddTransactionCubit(repository: repository);
    });

    tearDown(() => cubit.close());

    test('sends the deposit payload the backend expects', () async {
      when(() => repository.addTransaction(any())).thenAnswer(
        (_) async => Right(
          AddTransactionResult.fromJson({
            'done': true,
            'doc': {'_id': 'tx-1', 'code': 'TRX-1'},
          }),
        ),
      );

      await cubit.submitTransaction(
        type: 'deposit',
        amount: 250,
        account: _account(),
        paymentMethod: PaymentMethodModel(code: 'bank', name: 'Wire Bank'),
      );

      final payload =
          verify(() => repository.addTransaction(captureAny())).captured.single
              as Map<String, dynamic>;

      expect(payload['type'], 'deposit');
      expect(payload['amount'], 250);
      // Internal identifiers are still used in API payloads; the account
      // code goes with them, since that is the MT5 login the backend keys on.
      expect(payload['account'], {
        '_id': 'mongo-12',
        'id': 12,
        'code': '100345',
      });
      expect(payload['paymentMethod'], {'code': 'bank', 'name': 'Wire Bank'});
      expect(cubit.state.status, AddTransactionStatus.success);
    });

    test('maps a withdrawal to the backend "withdrawal" type', () async {
      when(() => repository.addTransaction(any())).thenAnswer(
        (_) async => Right(
          AddTransactionResult.fromJson({
            'done': true,
            'doc': {'_id': 'tx-1'},
          }),
        ),
      );

      await cubit.submitTransaction(
        type: 'withdrawal',
        amount: 10,
        account: _account(),
        paymentMethod: PaymentMethodModel(code: 'bank', name: 'Wire Bank'),
      );

      final payload =
          verify(() => repository.addTransaction(captureAny())).captured.single
              as Map<String, dynamic>;
      expect(payload['type'], 'withdrawal');
    });

    test('includes the destination account for a transfer', () async {
      when(() => repository.addTransaction(any())).thenAnswer(
        (_) async => Right(
          AddTransactionResult.fromJson({
            'done': true,
            'doc': {'_id': 'tx-1'},
          }),
        ),
      );

      await cubit.submitTransaction(
        type: 'transfer',
        amount: 25,
        account: _account(id: '12'),
        accountTo: _account(id: '13', code: '100346'),
      );

      final payload =
          verify(() => repository.addTransaction(captureAny())).captured.single
              as Map<String, dynamic>;

      expect(payload['accountTo'], {
        '_id': 'mongo-13',
        'id': 13,
        'code': '100346',
      });
      expect(payload.containsKey('paymentMethod'), isFalse);
    });

    test('surfaces a submission failure', () async {
      when(() => repository.addTransaction(any())).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'insufficient funds')),
      );

      await cubit.submitTransaction(
        type: 'deposit',
        amount: 1,
        account: _account(),
        paymentMethod: PaymentMethodModel(code: 'bank', name: 'Wire Bank'),
      );

      expect(cubit.state.status, AddTransactionStatus.failure);
      expect(cubit.state.errorMessage, 'insufficient funds');
    });

    test('rejects an attachment with an unsupported extension', () async {
      await cubit.attachProof('/tmp/receipt.exe', isImage: false);

      expect(cubit.state.attachmentStatus, AttachmentStatus.failure);
      expect(cubit.state.attachmentErrorMessage, contains('Unsupported'));
      expect(cubit.state.hasAttachment, isFalse);
    });

    test('declares the deposit-proof rules', () {
      expect(
        AddTransactionCubit.allowedAttachmentExtensions,
        containsAll(<String>['jpg', 'png', 'pdf']),
      );
      expect(AddTransactionCubit.maxAttachmentBytes, 10 * 1024 * 1024);
      expect(AddTransactionCubit.methodsRequiringProof, contains('bank'));
    });

    test('loads deposit methods from the admin list', () async {
      when(
        () => repository.getPaymentMethods(type: any(named: 'type')),
      ).thenAnswer(
        (_) async =>
            Right([PaymentMethodModel(code: 'myfatoorah', name: 'MyFatoorah')]),
      );

      final methods = await cubit.getPaymentMethods(type: 'deposit');

      expect(methods.single.code, 'myfatoorah');
      verify(() => repository.getPaymentMethods(type: 'deposit')).called(1);
    });

    test('loads withdrawal methods from the user list', () async {
      when(
        () => repository.getPaymentMethods(type: any(named: 'type')),
      ).thenAnswer((_) async => const Right([]));

      await cubit.getPaymentMethods(type: 'withdrawal');

      verify(() => repository.getPaymentMethods(type: 'withdrawal')).called(1);
    });

    test(
      're-reads the created transaction instead of assuming success',
      () async {
        when(() => repository.addTransaction(any())).thenAnswer(
          (_) async => Right(
            AddTransactionResult.fromJson({
              'done': true,
              'doc': {'_id': 'tx-1', 'code': 'TRX-1001'},
              'paymentUrl': 'https://pay.example.com/i/1',
            }),
          ),
        );
        when(
          () => repository.getTransactions(type: any(named: 'type')),
        ).thenAnswer((_) async => Right([_transaction(status: 'approved')]));

        await cubit.submitTransaction(
          type: 'deposit',
          amount: 100,
          account: _account(),
          paymentMethod: PaymentMethodModel(
            code: 'myfatoorah',
            name: 'MyFatoorah',
          ),
        );
        expect(cubit.state.transaction!.transactionStatus?.code, isNull);

        final refreshed = await cubit.refreshCreatedTransaction();

        expect(refreshed!.transactionStatus!.code, 'approved');
        expect(cubit.state.transaction!.transactionStatus!.code, 'approved');
      },
    );
  });

  group('TransactionsCubit', () {
    late _MockTransactionsRepository repository;
    late TransactionsCubit cubit;

    setUp(() {
      repository = _MockTransactionsRepository();
      cubit = TransactionsCubit(repository: repository);
    });

    tearDown(() => cubit.close());

    test('loads the unfiltered history', () async {
      when(
        () => repository.getTransactions(type: any(named: 'type')),
      ).thenAnswer((_) async => Right([_transaction()]));

      await cubit.fetchTransactions();

      expect(cubit.state, isA<TransactionsLoaded>());
      expect((cubit.state as TransactionsLoaded).transactions, hasLength(1));
      verify(() => repository.getTransactions(type: null)).called(1);
    });

    test('passes the chosen type as the filter', () async {
      when(
        () => repository.getTransactions(type: any(named: 'type')),
      ).thenAnswer((_) async => const Right([]));

      await cubit.fetchTransactions(filterType: 'withdrawal');

      verify(() => repository.getTransactions(type: 'withdrawal')).called(1);
    });

    test('treats "all" as no filter', () async {
      when(
        () => repository.getTransactions(type: any(named: 'type')),
      ).thenAnswer((_) async => const Right([]));

      await cubit.fetchTransactions(filterType: 'all');

      verify(() => repository.getTransactions(type: null)).called(1);
    });

    test('reports an empty history as an empty list, not an error', () async {
      when(
        () => repository.getTransactions(type: any(named: 'type')),
      ).thenAnswer((_) async => const Right([]));

      await cubit.fetchTransactions();

      expect((cubit.state as TransactionsLoaded).transactions, isEmpty);
    });

    test('surfaces a load failure', () async {
      when(
        () => repository.getTransactions(type: any(named: 'type')),
      ).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'network down')),
      );

      await cubit.fetchTransactions();

      expect(cubit.state, isA<TransactionsError>());
      expect((cubit.state as TransactionsError).message, 'network down');
    });
  });
}
