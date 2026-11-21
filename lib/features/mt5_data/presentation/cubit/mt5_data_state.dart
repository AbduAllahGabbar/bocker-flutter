import 'package:equatable/equatable.dart';
import '../../../../features/accounts/data/models/account_model.dart';
import '../../data/models/mt5_summary_model.dart';
import '../../data/models/mt5_item_model.dart';
import '../../data/models/mt5_order_type.dart';

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
  final String? symbolFilter;
  final String? typeFilter;
  final List<String> availableSymbols;
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
    this.symbolFilter,
    this.typeFilter,
    this.availableSymbols = const [],
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
    String? symbolFilter,
    String? typeFilter,
    List<String>? availableSymbols,
    int? pageNumber,
    int? skip,
    bool? hasMore,
    String? error,
    bool clearDateRange = false,
    bool clearSymbolFilter = false,
    bool clearTypeFilter = false,
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
      symbolFilter: clearSymbolFilter
          ? null
          : (symbolFilter ?? this.symbolFilter),
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
      availableSymbols: availableSymbols ?? this.availableSymbols,
      pageNumber: pageNumber ?? this.pageNumber,
      skip: skip ?? this.skip,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }

  bool get hasActiveFilters =>
      filterKind != 'history' ||
      dateFrom != null ||
      dateTo != null ||
      searchQuery.isNotEmpty ||
      symbolFilter != null ||
      typeFilter != null;

  /// Client side safety net: the same symbol / order-type filters are sent to
  /// the api, this keeps the ui consistent if the backend ignores them.
  List<Mt5ItemModel> get visibleList {
    if (symbolFilter == null && typeFilter == null) return list;
    return list.where((item) {
      if (symbolFilter != null &&
          item.displaySymbol.toLowerCase() != symbolFilter!.toLowerCase()) {
        return false;
      }
      if (typeFilter != null &&
          Mt5OrderType.normalizeKey(item.displayType) !=
              Mt5OrderType.normalizeKey(typeFilter!)) {
        return false;
      }
      return true;
    }).toList();
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
    symbolFilter,
    typeFilter,
    availableSymbols,
    pageNumber,
    skip,
    hasMore,
    error,
  ];
}
