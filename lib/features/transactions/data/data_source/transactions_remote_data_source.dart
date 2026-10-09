import 'package:dio/dio.dart';
import '../models/transaction_model.dart';
import '../../../../features/accounts/data/models/account_model.dart';
import '../models/payment_method_model.dart';

abstract class TransactionsRemoteDataSource {
  Future<List<TransactionModel>> getTransactions({String? type});
  Future<TransactionModel> addTransaction(Map<String, dynamic> data);
  Future<List<AccountModel>> getAccounts();
  Future<List<PaymentMethodModel>> getPaymentMethods({required String type});
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

    final response = await dio.post(
      'https://boker.egytag.com/api/accountsTransactions/all',
      data: data,
    );

    if (response.statusCode == 200 && response.data['done'] == true) {
      final List<dynamic> list = response.data['list'] ?? [];
      return list.map((e) => TransactionModel.fromJson(e)).toList();
    } else {
      throw response.data['error'] ?? response.data['message'] ?? 'Failed to fetch transactions';
    }
  }

  @override
  Future<TransactionModel> addTransaction(Map<String, dynamic> data) async {
    final response = await dio.post(
      'https://boker.egytag.com/api/accountsTransactions/add',
      data: data,
    );

    if (response.statusCode == 200 && response.data['done'] == true) {
      return TransactionModel.fromJson(response.data['doc']);
    } else {
      throw response.data['error'] ?? response.data['message'] ?? 'Failed to add transaction';
    }
  }

  @override
  Future<List<AccountModel>> getAccounts() async {
    final response = await dio.post(
      'https://boker.egytag.com/api/accounts/all',
      data: {"where": {"type": "real"}},
    );

    if (response.statusCode == 200 && response.data['done'] == true) {
      final List<dynamic> list = response.data['list'] ?? [];
      return list.map((e) => AccountModel.fromJson(e)).toList();
    } else {
      throw response.data['error'] ?? response.data['message'] ?? 'Failed to fetch accounts';
    }
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods({required String type}) async {
    final endpoint = type == 'deposit' 
        ? 'https://boker.egytag.com/api/paymentMethodList/admin'
        : 'https://boker.egytag.com/api/paymentMethodList/user';

    final response = await dio.post(
      endpoint,
      data: {},
    );

    if (response.statusCode == 200 && response.data['done'] == true) {
      final List<dynamic> list = response.data['list'] ?? [];
      return list.map((e) => PaymentMethodModel.fromJson(e)).toList();
    } else {
      throw response.data['error'] ?? response.data['message'] ?? 'Failed to fetch payment methods';
    }
  }
}
