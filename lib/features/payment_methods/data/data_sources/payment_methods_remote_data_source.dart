import 'package:dio/dio.dart';
import '../models/user_payment_method_model.dart';
import '../../../transactions/data/models/payment_method_model.dart';

abstract class PaymentMethodsRemoteDataSource {
  Future<List<UserPaymentMethodModel>> getPaymentMethods();
  Future<void> deletePaymentMethod(int code);
  Future<List<PaymentMethodModel>> getAvailablePaymentMethods();
  Future<UserPaymentMethodModel> addPaymentMethod(Map<String, dynamic> data);
}

class PaymentMethodsRemoteDataSourceImpl implements PaymentMethodsRemoteDataSource {
  final Dio dio;

  PaymentMethodsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<UserPaymentMethodModel>> getPaymentMethods() async {
    final response = await dio.post(
      'https://boker.egytag.com/api/user/getPaymentMethods',
      data: {},
    );

    if (response.statusCode == 200 && response.data['done'] == true) {
      final List<dynamic> list = response.data['list'] ?? [];
      return list.map((e) => UserPaymentMethodModel.fromJson(e)).toList();
    } else {
      throw response.data['error'] ?? response.data['message'] ?? 'Failed to fetch payment methods';
    }
  }

  @override
  Future<void> deletePaymentMethod(int code) async {
    final response = await dio.post(
      'https://boker.egytag.com/api/user/deletePaymentMethod',
      data: {'code': code},
    );

    if (response.statusCode == 200 && response.data['done'] == true) {
      return;
    } else {
      throw response.data['error'] ?? response.data['message'] ?? 'Failed to delete payment method';
    }
  }

  @override
  Future<List<PaymentMethodModel>> getAvailablePaymentMethods() async {
    final response = await dio.post(
      'https://boker.egytag.com/api/paymentMethodList',
      data: {},
    );

    if (response.statusCode == 200 && response.data['done'] == true) {
      final List<dynamic> list = response.data['list'] ?? [];
      return list.map((e) => PaymentMethodModel.fromJson(e)).toList();
    } else {
      throw response.data['error'] ?? response.data['message'] ?? 'Failed to fetch available payment methods';
    }
  }

  @override
  Future<UserPaymentMethodModel> addPaymentMethod(Map<String, dynamic> data) async {
    final response = await dio.post(
      'https://boker.egytag.com/api/user/addPaymentMethod',
      data: data,
    );

    if (response.statusCode == 200 && response.data['done'] == true) {
      return UserPaymentMethodModel.fromJson(response.data['doc']);
    } else {
      throw response.data['error'] ?? response.data['message'] ?? 'Failed to add payment method';
    }
  }
}
