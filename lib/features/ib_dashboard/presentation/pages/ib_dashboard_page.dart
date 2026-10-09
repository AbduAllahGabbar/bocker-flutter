import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:res_reline/my_responsive.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/language/language_manager.dart';
import '../../../../core/config/routes/routes_manager.dart';
import '../cubit/ib_dashboard_cubit.dart';
import '../cubit/ib_dashboard_state.dart';
import '../../data/models/ib_dashboard_model.dart';

class IbDashboardPage extends StatefulWidget {
  const IbDashboardPage({super.key});

  @override
  State<IbDashboardPage> createState() => _IbDashboardPageState();
}

class _IbDashboardPageState extends State<IbDashboardPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<IbDashboardCubit>().fetchDashboardData();
    }
  }

  String _generateReferralUrl(String userId, String groupId) {
    // Basic fallback origin if needed
    String origin = 'https://boker.egytag.com'; 
    return '$origin/login?ref=$userId&accGroupId=$groupId';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: BlocBuilder<IbDashboardCubit, IbDashboardState>(
        builder: (context, state) {
          if (state.isLoading && state.dashboardData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.dashboardData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.error!, style: TextStyle(color: colorScheme.error)),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<IbDashboardCubit>().init(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final data = state.dashboardData;
          final user = state.user;

          return RefreshIndicator(
            onRefresh: () => context.read<IbDashboardCubit>().fetchDashboardData(isRefresh: true),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  title: Text('IB Dashboard'.tran),
                  floating: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => context.read<IbDashboardCubit>().fetchDashboardData(isRefresh: true),
                    ),
                  ],
                ),
                SliverPadding(
                  padding: EdgeInsets.all(16.r),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (user != null) ...[
                        _buildReferralLinks(context, user, colorScheme),
                        SizedBox(height: 16.h),
                        _buildIbWallet(context, user, colorScheme),
                        SizedBox(height: 16.h),
                      ],
                      if (data != null) ...[
                        _buildKpis(context, data.kpis, colorScheme),
                        SizedBox(height: 16.h),
                        _buildTotals(context, data.totals, colorScheme),
                        SizedBox(height: 24.h),
                        Text('Referrals'.tran, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 12.h),
                        TextField(
                          controller: _searchController,
                          onChanged: (val) => context.read<IbDashboardCubit>().onSearchChanged(val),
                          decoration: InputDecoration(
                            hintText: 'Search referrals...'.tran,
                            prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: colorScheme.outlineVariant),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],
                    ]),
                  ),
                ),
                if (data != null)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.r),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _buildReferralItem(context, data.list[index], colorScheme),
                          );
                        },
                        childCount: data.list.length,
                      ),
                    ),
                  ),
                if (data != null && state.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
                  ),
                if (data != null && state.hasReachedMax && data.list.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Center(child: Padding(padding: EdgeInsets.all(16.r), child: Text('No more referrals'.tran))),
                  ),
                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReferralLinks(BuildContext context, dynamic user, ColorScheme colorScheme) {
    final List<dynamic> campaigns = user.campaignsGroupList ?? [];
    if (campaigns.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Referral Links'.tran, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            ...campaigns.map((camp) {
              final String name = camp['name']?.toString() ?? 'Campaign';
              final String id = camp['id']?.toString() ?? '';
              final String link = _generateReferralUrl(user.sId ?? '', id);
              
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
                          SizedBox(height: 4.h),
                          Text(link, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      color: colorScheme.primary,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: link)).then((_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied to clipboard'.tran)));
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildIbWallet(BuildContext context, dynamic user, ColorScheme colorScheme) {
    final Map<String, dynamic>? wallet = user.ibWallet;
    if (wallet == null) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('IB Wallet'.tran, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                Text(wallet['name']?.toString() ?? '', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12.sp)),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(child: _buildMetricItem('Balance', '\$${wallet['balance']?.toString() ?? '0.00'}', colorScheme)),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetricItem('Rebate', '\$${wallet['rebate']?.toString() ?? '0.00'}', colorScheme),
                      SizedBox(height: 8.h),
                      TextButton.icon(
                        onPressed: () => context.pushNamed(RoutesNames.ibTransactions, extra: {'title': 'Rebate Info', 'typeCode': 'repate'}),
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('Rebate Info'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetricItem('Bonus', '\$${wallet['bonus']?.toString() ?? '0.00'}', colorScheme),
                      SizedBox(height: 8.h),
                      TextButton.icon(
                        onPressed: () => context.pushNamed(RoutesNames.ibTransactions, extra: {'title': 'Bonus Info', 'typeCode': 'bonus'}),
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('Bonus Info'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpis(BuildContext context, IbDashboardKpis kpis, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('KPIs'.tran, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            _buildMetricCard('Direct Referrals', kpis.directReferrals.toString(), colorScheme),
            _buildMetricCard('Total Referrals', kpis.totalReferrals.toString(), colorScheme),
            _buildMetricCard('Total Sub-IBs', kpis.totalSubIbs.toString(), colorScheme),
            _buildMetricCard('FTD Count', kpis.ftdCount.toString(), colorScheme),
            _buildMetricCard('FTD Percent', '${kpis.ftdPercent}%', colorScheme),
          ],
        ),
      ],
    );
  }

  Widget _buildTotals(BuildContext context, IbDashboardTotals totals, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aggregate Metrics'.tran, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            _buildMetricCard('Balance', '\$${totals.balance.toStringAsFixed(2)}', colorScheme),
            _buildMetricCard('Credit', '\$${totals.credit.toStringAsFixed(2)}', colorScheme),
            _buildMetricCard('Equity', '\$${totals.equity.toStringAsFixed(2)}', colorScheme),
            _buildMetricCard('Deposits', '\$${totals.deposits.toStringAsFixed(2)}', colorScheme),
            _buildMetricCard('Withdrawals', '\$${totals.withdrawals.toStringAsFixed(2)}', colorScheme),
            _buildMetricCard('Net Deposits', '\$${totals.netDeposits.toStringAsFixed(2)}', colorScheme),
            _buildMetricCard('Lots', totals.lots.toStringAsFixed(2), colorScheme),
            _buildMetricCard('PnL', '\$${totals.pnl.toStringAsFixed(2)}', colorScheme),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, ColorScheme colorScheme) {
    return Container(
      width: (MediaQuery.of(context).size.width - 44.w) / 2,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.tran, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12.sp)),
          SizedBox(height: 4.h),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.tran, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12.sp)),
        SizedBox(height: 2.h),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
      ],
    );
  }

  Widget _buildReferralItem(BuildContext context, IbReferralItem item, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    Text(item.email ?? '', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12.sp)),
                  ],
                ),
              ),
              if (item.isIb)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text('IB Level ${item.level}', style: TextStyle(color: colorScheme.onPrimaryContainer, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 8.h,
            children: [
              _buildSmallMetric('Direct', item.direct ? 'Yes' : 'No', colorScheme),
              _buildSmallMetric('Accounts', item.accountCount.toString(), colorScheme),
              _buildSmallMetric('Balance', '\$${item.balance.toStringAsFixed(2)}', colorScheme),
              _buildSmallMetric('Credit', '\$${item.credit.toStringAsFixed(2)}', colorScheme),
              _buildSmallMetric('Equity', '\$${item.equity.toStringAsFixed(2)}', colorScheme),
              _buildSmallMetric('Deposits', '\$${item.deposits.toStringAsFixed(2)}', colorScheme),
              _buildSmallMetric('Withdrawals', '\$${item.withdrawals.toStringAsFixed(2)}', colorScheme),
              _buildSmallMetric('Net Deposits', '\$${item.netDeposits.toStringAsFixed(2)}', colorScheme),
              _buildSmallMetric('Lots', item.lots.toStringAsFixed(2), colorScheme),
              _buildSmallMetric('PnL', '\$${item.pnl.toStringAsFixed(2)}', colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMetric(String label, String value, ColorScheme colorScheme) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 64.w) / 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.tran, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10.sp)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp)),
        ],
      ),
    );
  }
}
