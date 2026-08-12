import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/accounts/data/models/account_model.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/repositories/transactions_repository.dart';
import 'add_transaction_state.dart';

class AddTransactionCubit extends Cubit<AddTransactionState> {
  final TransactionsRepository repository;

  List<AccountModel> _accounts = [];
  List<PaymentMethodModel> _paymentMethods = [];

  AddTransactionCubit({required this.repository}) : super(AddTransactionInitial());

  Future<List<AccountModel>> getAccounts() async {
    if (_accounts.isNotEmpty) return _accounts;
    final result = await repository.getAccounts();
    return result.fold((l) => [], (r) {
      _accounts = r;
      return r;
    });
  }

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    if (_paymentMethods.isNotEmpty) return _paymentMethods;
    final result = await repository.getPaymentMethods();
    return result.fold((l) => [], (r) {
      _paymentMethods = r;
      return r;
    });
  }

  Future<void> submitTransaction({
    required String type, // 'deposit', 'transfer', 'withdrawal'
    required double amount,
    required String accountId,
    required num accountIdNum,
    required String paymentMethodCode,
    required String paymentMethodName,
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
      "paymentMethod": {
        "code": paymentMethodCode,
        "name": paymentMethodName,
      },
      "amount": amount,
      "type": apiType,
    };

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
