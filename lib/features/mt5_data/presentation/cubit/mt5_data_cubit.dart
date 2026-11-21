import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/accounts/data/models/account_model.dart';
import '../../../../features/accounts/data/repositories/accounts_repository.dart';
import '../../../../features/auth/data/repository/user_access.dart';
import '../../data/repositories/mt5_repository.dart';
import 'mt5_data_state.dart';

class Mt5DataCubit extends Cubit<Mt5DataState> {
  final AccountsRepository accountsRepository;
  final Mt5Repository mt5Repository;

  Mt5DataCubit({required this.accountsRepository, required this.mt5Repository})
    : super(const Mt5DataState());

  Future<void> init({AccountModel? initialAccount}) async {
    emit(state.copyWith(isLoadingAccounts: true, error: null));
    final accountsResult = await accountsRepository.getAccounts();
    accountsResult.fold(
      (failure) => emit(
        state.copyWith(isLoadingAccounts: false, error: failure.message),
      ),
      (allAccounts) {
        // Filter only 'real' accounts as per requirements
        final realAccounts = allAccounts
            .where((a) => a.type == 'real')
            .toList();

        AccountModel? selected;
        if (initialAccount != null) {
          selected = realAccounts.firstWhere(
            (a) => a.id == initialAccount.id,
            orElse: () =>
                realAccounts.isNotEmpty ? realAccounts.first : initialAccount,
          );
        } else {
          selected = realAccounts.isNotEmpty ? realAccounts.first : null;
        }

        emit(
          state.copyWith(
            isLoadingAccounts: false,
            accounts: realAccounts,
            selectedAccount: selected,
          ),
        );
        if (selected != null) {
          fetchSummaryAndList();
        }
      },
    );
  }

  void selectAccount(AccountModel account) {
    if (state.selectedAccount?.id == account.id) return;
    emit(
      state.copyWith(
        selectedAccount: account,
        pageNumber: 0,
        skip: 0,
        hasMore: true,
        list: [],
        summary: null,
        availableSymbols: const [],
        clearSymbolFilter: true,
        clearTypeFilter: true,
      ),
    );
    fetchSummaryAndList();
  }

  void setFilterKind(String kind) {
    if (state.filterKind == kind) return;
    emit(
      state.copyWith(
        filterKind: kind,
        pageNumber: 0,
        skip: 0,
        hasMore: true,
        list: [],
      ),
    );
    fetchList();
  }

  void setDateRange(DateTime? from, DateTime? to) {
    // the range picker returns midnight for both ends, widen `to` to the end
    // of the day so records of that day are not dropped.
    final normalizedTo = to == null
        ? null
        : DateTime(to.year, to.month, to.day, 23, 59, 59, 999);
    final normalizedFrom = from == null
        ? null
        : DateTime(from.year, from.month, from.day);
    emit(
      state.copyWith(
        dateFrom: normalizedFrom,
        dateTo: normalizedTo,
        clearDateRange: from == null && to == null,
        pageNumber: 0,
        skip: 0,
        hasMore: true,
        list: [],
      ),
    );
    fetchList();
  }

  void setSymbolFilter(String? symbol) {
    if (state.symbolFilter == symbol) return;
    emit(
      state.copyWith(
        symbolFilter: symbol,
        clearSymbolFilter: symbol == null,
        pageNumber: 0,
        skip: 0,
        hasMore: true,
        list: [],
      ),
    );
    fetchList();
  }

  void setTypeFilter(String? type) {
    if (state.typeFilter == type) return;
    emit(
      state.copyWith(
        typeFilter: type,
        clearTypeFilter: type == null,
        pageNumber: 0,
        skip: 0,
        hasMore: true,
        list: [],
      ),
    );
    fetchList();
  }

  void clearFilters() {
    emit(
      state.copyWith(
        filterKind: 'history',
        clearDateRange: true,
        clearSymbolFilter: true,
        clearTypeFilter: true,
        searchQuery: '',
        pageNumber: 0,
        skip: 0,
        hasMore: true,
        list: [],
      ),
    );
    fetchList();
  }

  void setSearchQuery(String query) {
    emit(
      state.copyWith(
        searchQuery: query,
        pageNumber: 0,
        skip: 0,
        hasMore: true,
        list: [],
      ),
    );
    fetchList();
  }

  Future<void> fetchSummaryAndList() async {
    fetchSummary();
    fetchList();
  }

  Future<void> fetchSummary() async {
    if (state.selectedAccount == null) return;
    emit(state.copyWith(isLoadingSummary: true, error: null));
    final result = await mt5Repository.getSummary(state.selectedAccount!.id);
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoadingSummary: false, error: failure.message)),
      (summary) =>
          emit(state.copyWith(isLoadingSummary: false, summary: summary)),
    );
  }

  Future<void> fetchList({bool isLoadMore = false}) async {
    if (state.selectedAccount == null) return;
    if (isLoadMore && (!state.hasMore || state.isLoadingList)) return;

    final limit = 50;
    final newSkip = isLoadMore ? state.skip + limit : 0;
    final newPageNumber = isLoadMore ? state.pageNumber + 1 : 0;

    if (!isLoadMore) {
      emit(
        state.copyWith(
          isLoadingList: true,
          error: null,
          skip: 0,
          pageNumber: 0,
        ),
      );
    } else {
      emit(state.copyWith(isLoadingList: true, error: null));
    }

    final user = UserAccess.user;
    final userId = user != null ? int.tryParse(user.userId) ?? 0 : 0;
    final accountId = int.tryParse(state.selectedAccount!.id) ?? 0;
    final login = state.selectedAccount!.code;

    final requestBody = {
      "kind": state.filterKind,
      "userId": userId,
      "accountId": accountId,
      "login": login,
      "where": {
        if (state.dateFrom != null)
          "dateFrom": state.dateFrom!.toUtc().toIso8601String(),
        if (state.dateTo != null)
          "dateTo": state.dateTo!.toUtc().toIso8601String(),
        if (state.symbolFilter != null) "symbol": state.symbolFilter,
        if (state.typeFilter != null) "type": state.typeFilter,
      },
      "search": state.searchQuery,
      "limit": limit,
      "pageNumber": newPageNumber,
      "skip": newSkip,
    };

    final result = await mt5Repository.getList(requestBody);
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoadingList: false, error: failure.message)),
      (newList) {
        final mergedList = isLoadMore ? [...state.list, ...newList] : newList;
        emit(
          state.copyWith(
            isLoadingList: false,
            list: mergedList,
            availableSymbols: _mergeOptions(
              state.availableSymbols,
              newList.map((e) => e.displaySymbol),
            ),
            hasMore: newList.length == limit,
            skip: newSkip,
            pageNumber: newPageNumber,
          ),
        );
      },
    );
  }

  Future<void> syncAccount() async {
    if (state.selectedAccount == null || state.isSyncing) return;
    emit(state.copyWith(isSyncing: true, error: null));
    final result = await mt5Repository.syncAccount(state.selectedAccount!.id);
    result.fold(
      (failure) =>
          emit(state.copyWith(isSyncing: false, error: failure.message)),
      (_) {
        emit(state.copyWith(isSyncing: false));
        fetchSummaryAndList();
      },
    );
  }

  /// Keeps the dropdown options stable while paging / filtering.
  List<String> _mergeOptions(List<String> current, Iterable<String> incoming) {
    final merged = {...current};
    for (final value in incoming) {
      final clean = value.trim();
      if (clean.isNotEmpty && clean != '-') merged.add(clean);
    }
    final result = merged.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return result;
  }

  Future<void> refresh() async {
    await fetchSummaryAndList();
  }
}
