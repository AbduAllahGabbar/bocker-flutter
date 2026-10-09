import 'package:equatable/equatable.dart';
import '../../../../features/accounts/data/models/account_model.dart';
import '../../data/models/mt5_summary_model.dart';
import '../../data/models/mt5_item_model.dart';

class Mt5DataState extends Equatable {
  final List<AccountModel> accounts;
  final AccountModel? selectedAccount;
  final Mt5SummaryModel? summary;
  final List<Mt5ItemModel> list;
  final bool isLoadingAccounts;
  final bool isLoadingSummary;
  final bool isLoadingList;
  final bool isSyncing;
  final String filterKind;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String searchQuery;
  final int pageNumber;
  final int skip;
  final bool hasMore;
  final String? error;

  const Mt5DataState({
    this.accounts = const [],
    this.selectedAccount,
    this.summary,
    this.list = const [],
    this.isLoadingAccounts = false,
    this.isLoadingSummary = false,
    this.isLoadingList = false,
    this.isSyncing = false,
    this.filterKind = 'history',
    this.dateFrom,
    this.dateTo,
    this.searchQuery = '',
    this.pageNumber = 0,
    this.skip = 0,
    this.hasMore = true,
    this.error,
  });

  Mt5DataState copyWith({
    List<AccountModel>? accounts,
    AccountModel? selectedAccount,
    Mt5SummaryModel? summary,
    List<Mt5ItemModel>? list,
    bool? isLoadingAccounts,
    bool? isLoadingSummary,
    bool? isLoadingList,
    bool? isSyncing,
    String? filterKind,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? searchQuery,
    int? pageNumber,
    int? skip,
    bool? hasMore,
    String? error,
    bool clearDateRange = false,
  }) {
    return Mt5DataState(
      accounts: accounts ?? this.accounts,
      selectedAccount: selectedAccount ?? this.selectedAccount,
      summary: summary ?? this.summary,
      list: list ?? this.list,
      isLoadingAccounts: isLoadingAccounts ?? this.isLoadingAccounts,
      isLoadingSummary: isLoadingSummary ?? this.isLoadingSummary,
      isLoadingList: isLoadingList ?? this.isLoadingList,
      isSyncing: isSyncing ?? this.isSyncing,
      filterKind: filterKind ?? this.filterKind,
      dateFrom: clearDateRange ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateRange ? null : (dateTo ?? this.dateTo),
      searchQuery: searchQuery ?? this.searchQuery,
      pageNumber: pageNumber ?? this.pageNumber,
      skip: skip ?? this.skip,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        accounts,
        selectedAccount,
        summary,
        list,
        isLoadingAccounts,
        isLoadingSummary,
        isLoadingList,
        isSyncing,
        filterKind,
        dateFrom,
        dateTo,
        searchQuery,
        pageNumber,
        skip,
        hasMore,
        error,
      ];
}
