import 'package:equatable/equatable.dart';
import '../../data/models/ib_transaction_model.dart';

class IbTransactionsState extends Equatable {
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  
  final IbTransactionResponse? transactionData;
  
  final String typeCode; // 'repate' or 'bonus'
  final String searchQuery;
  final int pageNumber;
  final bool hasReachedMax;

  const IbTransactionsState({
    required this.typeCode,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.transactionData,
    this.searchQuery = '',
    this.pageNumber = 0,
    this.hasReachedMax = false,
  });

  IbTransactionsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    IbTransactionResponse? transactionData,
    String? searchQuery,
    int? pageNumber,
    bool? hasReachedMax,
  }) {
    return IbTransactionsState(
      typeCode: typeCode,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      transactionData: transactionData ?? this.transactionData,
      searchQuery: searchQuery ?? this.searchQuery,
      pageNumber: pageNumber ?? this.pageNumber,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
        typeCode,
        isLoading,
        isLoadingMore,
        error,
        transactionData,
        searchQuery,
        pageNumber,
        hasReachedMax,
      ];
}
