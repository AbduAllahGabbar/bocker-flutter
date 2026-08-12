import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/transactions_repository.dart';
import 'transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  final TransactionsRepository repository;
  String? currentFilter; // 'all', 'deposit', 'transfer', 'withdraw'

  TransactionsCubit({required this.repository}) : super(TransactionsInitial());

  Future<void> fetchTransactions({String? filterType}) async {
    currentFilter = filterType ?? currentFilter;
    emit(TransactionsLoading());
    final result = await repository.getTransactions(type: currentFilter == 'all' ? null : currentFilter);
    result.fold(
      (failure) => emit(TransactionsError(message: failure.message)),
      (transactions) => emit(TransactionsLoaded(transactions: transactions)),
    );
  }
}
