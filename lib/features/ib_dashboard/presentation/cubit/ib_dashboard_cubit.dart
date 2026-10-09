import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/ib_repository.dart';
import 'ib_dashboard_state.dart';
import '../../../../features/auth/cubit/auth_cubit.dart';
import '../../../../features/auth/cubit/auth_state.dart';
import '../../data/models/ib_dashboard_model.dart';
import 'dart:async';

class IbDashboardCubit extends Cubit<IbDashboardState> {
  final IbRepository repository;
  final AuthCubit authCubit;
  static const int limit = 25;
  Timer? _debounce;

  IbDashboardCubit({
    required this.repository,
    required this.authCubit,
  }) : super(const IbDashboardState());

  Future<void> init() async {
    emit(state.copyWith(isLoading: true, error: null));
    
    // First refresh user data
    await authCubit.getCurrentUser();
    
    final userState = authCubit.state;
    final user = userState.mapOrNull(authenticated: (value) => value.user);
    
    if (user == null || user.isIb != true) {
      emit(state.copyWith(
        isLoading: false, 
        error: "User is not an IB or not authenticated",
      ));
      return;
    }
    
    emit(state.copyWith(user: user));
    await fetchDashboardData(isRefresh: true);
  }

  Future<void> fetchDashboardData({bool isRefresh = false}) async {
    if (isRefresh) {
      emit(state.copyWith(isLoading: true, error: null, pageNumber: 0, hasReachedMax: false));
    } else {
      if (state.isLoadingMore || state.hasReachedMax) return;
      emit(state.copyWith(isLoadingMore: true, error: null));
    }

    final currentPage = isRefresh ? 0 : state.pageNumber;
    final skip = currentPage * limit;

    final result = await repository.getDashboardData(
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
            dashboardData: data,
            pageNumber: 1,
            hasReachedMax: data.list.length < limit,
          ));
        } else {
          final currentData = state.dashboardData;
          if (currentData != null) {
            final updatedList = List.of(currentData.list)..addAll(data.list);
            final updatedData = IbDashboardResponse(
              done: data.done,
              count: data.count,
              totals: data.totals,
              kpis: data.kpis,
              list: updatedList,
            );
            emit(state.copyWith(
              isLoadingMore: false,
              dashboardData: updatedData,
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
      fetchDashboardData(isRefresh: true);
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
