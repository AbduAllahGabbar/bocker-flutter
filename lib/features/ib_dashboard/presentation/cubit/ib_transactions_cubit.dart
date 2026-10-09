import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/ib_repository.dart';
import 'ib_transactions_state.dart';
import '../../data/models/ib_transaction_model.dart';
import 'dart:async';

class IbTransactionsCubit extends Cubit<IbTransactionsState> {
  final IbRepository repository;
  static const int limit = 25;
  Timer? _debounce;

  IbTransactionsCubit({
    required this.repository,
    required String typeCode,
  }) : super(IbTransactionsState(typeCode: typeCode));

  Future<void> init() async {
    await fetchTransactions(isRefresh: true);
  }

  Future<void> fetchTransactions({bool isRefresh = false}) async {
    if (isRefresh) {
      emit(state.copyWith(isLoading: true, error: null, pageNumber: 0, hasReachedMax: false));
    } else {
      if (state.isLoadingMore || state.hasReachedMax) return;
      emit(state.copyWith(isLoadingMore: true, error: null));
    }

    final currentPage = isRefresh ? 0 : state.pageNumber;
    final skip = currentPage * limit;

    final result = await repository.getTransactions(
      typeCode: state.typeCode,
      search: state.searchQuery,
      limit: limit,
      pageNumber: currentPage,
      skip: skip,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: failure.message,
        ));
      },
      (data) {
        if (isRefresh) {
          emit(state.copyWith(
            isLoading: false,
            transactionData: data,
            pageNumber: 1,
            hasReachedMax: data.list.length < limit,
          ));
        } else {
          final currentData = state.transactionData;
          if (currentData != null) {
            final updatedList = List.of(currentData.list)..addAll(data.list);
            final updatedData = IbTransactionResponse(
              done: data.done,
              count: data.count,
              list: updatedList,
            );
            emit(state.copyWith(
              isLoadingMore: false,
              transactionData: updatedData,
              pageNumber: currentPage + 1,
              hasReachedMax: data.list.length < limit,
            ));
          }
        }
      },
    );
  }

  void onSearchChanged(String query) {
    if (state.searchQuery == query) return;
    
    emit(state.copyWith(searchQuery: query));
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchTransactions(isRefresh: true);
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
