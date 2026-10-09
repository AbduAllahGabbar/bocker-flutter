import 'package:dio/dio.dart';
import '../models/mt5_summary_model.dart';
import '../models/mt5_item_model.dart';
import '../../../../core/data/constants/apis_constants.dart';

abstract class Mt5RemoteDataSource {
  Future<Mt5SummaryModel> getSummary(String accountId);
  Future<List<Mt5ItemModel>> getList(Map<String, dynamic> requestBody);
  Future<void> syncAccount(String accountId);
}

class Mt5RemoteDataSourceImpl implements Mt5RemoteDataSource {
  final Dio dio;

  Mt5RemoteDataSourceImpl({required this.dio});

  @override
  Future<Mt5SummaryModel> getSummary(String accountId) async {
    final response = await dio.post(
      '${ApiConstants.apiBaseUrl}/mt5-data/summary',
      data: {'accountId': int.tryParse(accountId) ?? accountId},
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['doc'] ?? response.data['data'] ?? response.data;
      return Mt5SummaryModel.fromJson(data);
    } else {
      throw response.data?['error'] ?? response.data?['message'] ?? 'Failed to fetch MT5 summary';
    }
  }

  @override
  Future<List<Mt5ItemModel>> getList(Map<String, dynamic> requestBody) async {
    final response = await dio.post(
      '${ApiConstants.apiBaseUrl}/mt5-data/list',
      data: requestBody,
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = response.data['list'] ?? response.data['data'] ?? [];
      return list.map((e) => Mt5ItemModel.fromJson(e)).toList();
    } else {
      throw response.data?['error'] ?? response.data?['message'] ?? 'Failed to fetch MT5 list';
    }
  }

  @override
  Future<void> syncAccount(String accountId) async {
    final response = await dio.post(
      '${ApiConstants.apiBaseUrl}/mt5-data/sync',
      data: {'accountId': int.tryParse(accountId) ?? accountId},
    );

    if (response.statusCode != 200 || response.data['done'] == false) {
      throw response.data?['error'] ?? response.data?['message'] ?? 'Failed to sync MT5 data';
    }
  }
}
