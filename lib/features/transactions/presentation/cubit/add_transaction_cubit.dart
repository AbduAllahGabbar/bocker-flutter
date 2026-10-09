import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/accounts/data/models/account_model.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/repositories/transactions_repository.dart';
import 'add_transaction_state.dart';

class AddTransactionCubit extends Cubit<AddTransactionState> {
  final TransactionsRepository repository;

  List<AccountModel> _accounts = [];
  final Map<String, List<PaymentMethodModel>> _paymentMethodsCache = {};

  AddTransactionCubit({required this.repository}) : super(AddTransactionInitial());

  Future<List<AccountModel>> getAccounts() async {
    if (_accounts.isNotEmpty) return _accounts;
    final result = await repository.getAccounts();
    return result.fold((l) => [], (r) {
      _accounts = r;
      return r;
    });
  }

  Future<List<PaymentMethodModel>> getPaymentMethods({required String type}) async {
    // API uses 'withdraw' instead of 'withdrawal' internally, but the prompt says 
    // endpoint is /api/paymentMethodList/user and it takes empty data. 
    // Wait, the repository passes `type` to the data source which maps 'deposit' -> '/admin' and anything else -> '/user' (for withdrawal).
    // Let's pass the raw type and let data source handle the endpoint.
    final normalizedType = type.toLowerCase() == 'withdrawal' ? 'withdraw' : type.toLowerCase();
    
    if (_paymentMethodsCache.containsKey(normalizedType) && _paymentMethodsCache[normalizedType]!.isNotEmpty) {
      return _paymentMethodsCache[normalizedType]!;
    }
    
    final result = await repository.getPaymentMethods(type: normalizedType == 'withdraw' ? 'withdrawal' : 'deposit');
    return result.fold((l) => [], (r) {
      _paymentMethodsCache[normalizedType] = r;
      return r;
    });
  }

  Future<void> submitTransaction({
    required String type, // 'deposit', 'transfer', 'withdrawal'
    required double amount,
    required String accountId,
    required num accountIdNum,
    String? paymentMethodCode,
    String? paymentMethodName,
    String? accountToId,
    num? accountToIdNum,
  }) async {
    emit(AddTransactionLoading());
    
    // According to API, withdrawal type might be 'withdraw' instead of 'withdrawal'
    String apiType = type.toLowerCase() == 'withdrawal' ? 'withdraw' : type.toLowerCase();

    final data = {
      "account": {
        "_id": accountId,
        "id": accountIdNum,
      },
      "amount": amount,
      "type": apiType,
    };
    
    if (paymentMethodCode != null && paymentMethodName != null) {
      data["paymentMethod"] = {
        "code": paymentMethodCode,
        "name": paymentMethodName,
      };
    }

    if (apiType == 'transfer' && accountToId != null && accountToIdNum != null) {
      data["accountTo"] = {
        "_id": accountToId,
        "id": accountToIdNum,
      };
    }

    final result = await repository.addTransaction(data);
    result.fold(
      (failure) => emit(AddTransactionError(message: failure.message)),
      (transaction) => emit(AddTransactionSuccess()),
    );
  }
}
