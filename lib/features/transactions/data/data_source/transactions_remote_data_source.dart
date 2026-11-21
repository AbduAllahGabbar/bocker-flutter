import 'package:dio/dio.dart';
import '../../../../core/data/constants/apis_constants.dart';
import '../models/transaction_model.dart';
import '../../../../features/accounts/data/models/account_model.dart';
import '../models/payment_method_model.dart';
import '../models/myfatoorah_quote_model.dart';

abstract class TransactionsRemoteDataSource {
  Future<List<TransactionModel>> getTransactions({String? type});
  Future<AddTransactionResult> addTransaction(Map<String, dynamic> data);
  Future<List<AccountModel>> getAccounts();
  Future<List<PaymentMethodModel>> getPaymentMethods({required String type});
  Future<MyFatoorahQuoteModel> getMyFatoorahQuote({
    required String accountId,
    required num amount,
  });
}

class TransactionsRemoteDataSourceImpl implements TransactionsRemoteDataSource {
  final Dio dio;

  TransactionsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TransactionModel>> getTransactions({String? type}) async {
    final Map<String, dynamic> data = {};
    if (type != null && type.isNotEmpty && type != 'all') {
      data['where'] = {'type': type};
    }

    final response = await dio.post(ApiConstants.transactionsAll, data: data);

    if (response.statusCode == 200 && response.data['done'] == true) {
      final List<dynamic> list = response.data['list'] ?? [];
      return list.map((e) => TransactionModel.fromJson(e)).toList();
    }
    throw response.data['error'] ??
        response.data['message'] ??
        'Failed to fetch transactions';
  }

  @override
  Future<AddTransactionResult> addTransaction(Map<String, dynamic> data) async {
    final response = await dio.post(ApiConstants.transactionsAdd, data: data);

    if (response.statusCode == 200 && response.data['done'] == true) {
      return AddTransactionResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }
    throw response.data['error'] ??
        response.data['message'] ??
        'Failed to add transaction';
  }

  @override
  Future<List<AccountModel>> getAccounts() async {
    // No type filter: the transaction form offers every account the client
    // has, demo accounts included.
    final response = await dio.post(ApiConstants.accountsAll, data: {});

    if (response.statusCode == 200 && response.data['done'] == true) {
      final List<dynamic> list = response.data['list'] ?? [];
      return list.map((e) => AccountModel.fromJson(e)).toList();
    }
    throw response.data['error'] ??
        response.data['message'] ??
        'Failed to fetch accounts';
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods({
    required String type,
  }) async {
    // Deposit methods come from the admin-configured list (they carry the
    // broker's own bank / wallet / MyFatoorah details). Withdrawal methods come
    // from the methods the client saved on their own profile.
    final isDeposit = type == 'deposit';
    final endpoint = isDeposit
        ? ApiConstants.paymentMethodListAdmin
        : ApiConstants.paymentMethodListUser;

    final response = await dio.post(
      endpoint,
      data: isDeposit ? {"type": "deposit"} : {},
    );

    if (response.statusCode == 200 && response.data['done'] == true) {
      final List<dynamic> list = response.data['list'] ?? [];
      // A method the broker has switched off must not be offered - that is
      // what gates MyFatoorah on and off for the whole app.
      return list
          .map((e) => PaymentMethodModel.fromJson(e))
          .where((method) => method.active && method.code.isNotEmpty)
          .toList();
    }
    throw response.data['error'] ??
        response.data['message'] ??
        'Failed to fetch payment methods';
  }

  @override
  Future<MyFatoorahQuoteModel> getMyFatoorahQuote({
    required String accountId,
    required num amount,
  }) async {
    final response = await dio.post(
      ApiConstants.myfatoorahQuote,
      data: {"accountId": accountId, "amount": amount},
    );

    if (response.statusCode == 200 && response.data['done'] == true) {
      return MyFatoorahQuoteModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }
    throw response.data['error'] ??
        response.data['message'] ??
        'Failed to get payment quote';
  }
}
