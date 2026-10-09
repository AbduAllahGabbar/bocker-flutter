import 'package:dio/dio.dart';
import '../models/ib_dashboard_model.dart';
import '../models/ib_transaction_model.dart';

abstract class IbRemoteDataSource {
  Future<IbDashboardResponse> getDashboardData({
    required String search,
    required int limit,
    required int pageNumber,
    required int skip,
  });

  Future<IbTransactionResponse> getTransactions({
    required String typeCode,
    required String search,
    required int limit,
    required int pageNumber,
    required int skip,
  });
}

class IbRemoteDataSourceImpl implements IbRemoteDataSource {
  final Dio dio;

  IbRemoteDataSourceImpl({required this.dio});

  @override
  Future<IbDashboardResponse> getDashboardData({
    required String search,
    required int limit,
    required int pageNumber,
    required int skip,
  }) async {
    final response = await dio.post(
      '/ibInfo/dashboard',
      data: {
        "search": search,
        "limit": limit,
        "pageNumber": pageNumber,
        "skip": skip
      },
    );
    return IbDashboardResponse.fromJson(response.data);
  }

  @override
  Future<IbTransactionResponse> getTransactions({
    required String typeCode,
    required String search,
    required int limit,
    required int pageNumber,
    required int skip,
  }) async {
    final response = await dio.post(
      '/ibTransactions/all',
      data: {
        "where": {
          "type.code": typeCode
        },
        "search": search,
        "limit": limit,
        "skip": skip,
        "pageNumber": pageNumber
      },
    );
    return IbTransactionResponse.fromJson(response.data);
  }
}
