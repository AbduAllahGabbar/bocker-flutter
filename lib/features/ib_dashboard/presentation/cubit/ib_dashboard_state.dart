import 'package:equatable/equatable.dart';
import '../../data/models/ib_dashboard_model.dart';
import '../../../../features/auth/data/models/user_model.dart';

class IbDashboardState extends Equatable {
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  
  final IbDashboardResponse? dashboardData;
  final UserModel? user;
  
  final String searchQuery;
  final int pageNumber;
  final bool hasReachedMax;

  const IbDashboardState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.dashboardData,
    this.user,
    this.searchQuery = '',
    this.pageNumber = 0,
    this.hasReachedMax = false,
  });

  IbDashboardState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    IbDashboardResponse? dashboardData,
    UserModel? user,
    String? searchQuery,
    int? pageNumber,
    bool? hasReachedMax,
  }) {
    return IbDashboardState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      dashboardData: dashboardData ?? this.dashboardData,
      user: user ?? this.user,
      searchQuery: searchQuery ?? this.searchQuery,
      pageNumber: pageNumber ?? this.pageNumber,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isLoadingMore,
        error,
        dashboardData,
        user,
        searchQuery,
        pageNumber,
        hasReachedMax,
      ];
}
