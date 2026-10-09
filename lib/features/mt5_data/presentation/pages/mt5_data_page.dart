import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:res_reline/my_responsive.dart';
import '../cubit/mt5_data_cubit.dart';
import '../cubit/mt5_data_state.dart';
import '../../../../features/accounts/data/models/account_model.dart';
import '../../data/models/mt5_item_model.dart';

class Mt5DataPage extends StatefulWidget {
  const Mt5DataPage({super.key});

  @override
  State<Mt5DataPage> createState() => _Mt5DataPageState();
}

class _Mt5DataPageState extends State<Mt5DataPage> {
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
      context.read<Mt5DataCubit>().fetchList(isLoadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Mt5DataCubit, Mt5DataState>(
      listener: (context, state) {
        if (state.error != null && state.error!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        final cubit = context.read<Mt5DataCubit>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('MT5 Data'),
            actions: [
              if (state.isSyncing)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Center(child: SizedBox(width: 20.w, height: 20.w, child: CircularProgressIndicator(strokeWidth: 2))),
                )
              else
                IconButton(
                  icon: const Icon(Icons.sync),
                  onPressed: state.selectedAccount != null ? () => cubit.syncAccount() : null,
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => cubit.refresh(),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(16.r),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildAccountSelector(context, state),
                      SizedBox(height: 16.h),
                      if (state.isLoadingSummary && state.summary == null)
                        const Center(child: CircularProgressIndicator())
                      else if (state.summary != null)
                        _buildSummaryCard(context, state),
                      SizedBox(height: 24.h),
                      _buildFilterBar(context, state),
                      SizedBox(height: 16.h),
                      _buildSearchBar(context, state),
                      SizedBox(height: 16.h),
                    ]),
                  ),
                ),
                if (state.isLoadingList && state.list.isEmpty)
                  const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.list.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: Text('No records found.')),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= state.list.length) {
                            return state.hasMore
                                ? const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  )
                                : const SizedBox.shrink();
                          }
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _buildListItem(context, state.list[index]),
                          );
                        },
                        childCount: state.list.length + (state.hasMore ? 1 : 0),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(child: SizedBox(height: 40.h)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountSelector(BuildContext context, Mt5DataState state) {
    if (state.isLoadingAccounts && state.accounts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AccountModel>(
          isExpanded: true,
          value: state.selectedAccount,
          hint: const Text('Select Real Account'),
          items: state.accounts.map((account) {
            return DropdownMenuItem(
              value: account,
              child: Text('Account #${account.id} - ${account.code}'),
            );
          }).toList(),
          onChanged: (account) {
            if (account != null) {
              context.read<Mt5DataCubit>().selectAccount(account);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, Mt5DataState state) {
    final summary = state.summary!;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BALANCE',
            style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.7), fontWeight: FontWeight.bold, fontSize: 12.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            '\$${summary.displayBalance.toStringAsFixed(2)}',
            style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 28.sp),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('EQUITY', '\$${summary.displayEquity.toStringAsFixed(2)}', colorScheme),
              _buildSummaryItem('MARGIN', '\$${summary.displayMargin.toStringAsFixed(2)}', colorScheme),
              _buildSummaryItem('PROFIT', '\$${summary.displayProfit.toStringAsFixed(2)}', colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.7), fontWeight: FontWeight.w600, fontSize: 10.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context, Mt5DataState state) {
    final cubit = context.read<Mt5DataCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('history', 'All', state, cubit),
              _buildFilterChip('positions', 'Open', state, cubit),
              _buildFilterChip('orders', 'Pending', state, cubit),
              _buildFilterChip('closedTrades', 'Closed', state, cubit),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDateRange: state.dateFrom != null && state.dateTo != null
                        ? DateTimeRange(start: state.dateFrom!, end: state.dateTo!)
                        : null,
                  );
                  if (picked != null) {
                    cubit.setDateRange(picked.start, picked.end);
                  }
                },
                icon: const Icon(Icons.date_range, size: 18),
                label: Text(state.dateFrom != null && state.dateTo != null
                    ? '${DateFormat('MMM d').format(state.dateFrom!)} - ${DateFormat('MMM d').format(state.dateTo!)}'
                    : 'Date Range'),
              ),
            ),
            SizedBox(width: 8.w),
            TextButton(
              onPressed: () {
                _searchController.clear();
                cubit.clearFilters();
              },
              child: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String kind, String label, Mt5DataState state, Mt5DataCubit cubit) {
    final isSelected = state.filterKind == kind;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) cubit.setFilterKind(kind);
        },
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: TextStyle(
          color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, Mt5DataState state) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search ticket, symbol...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
      onSubmitted: (val) {
        context.read<Mt5DataCubit>().setSearchQuery(val);
      },
    );
  }

  Widget _buildListItem(BuildContext context, Mt5ItemModel item) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = item.displayProfit >= 0;
    
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: isPositive ? colorScheme.primaryContainer : colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.displayType.toLowerCase() == 'deposit' ? Icons.arrow_downward : 
                      item.displayType.toLowerCase() == 'withdrawal' ? Icons.arrow_upward : 
                      Icons.swap_horiz,
                      color: isPositive ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displaySymbol.isNotEmpty ? item.displaySymbol : 'Transaction',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                      ),
                      Text(
                        item.displayType.toUpperCase(),
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12.sp, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isPositive ? '+' : ''}\$${item.displayProfit.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18.sp,
                      color: isPositive ? colorScheme.primary : colorScheme.error,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 4.h),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '#${item.displayTicket}',
                      style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Data Grid
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
            ),
            child: Wrap(
              spacing: 16.s,
              runSpacing: 12.s,
              children: [
                _buildDetailItem(context, 'Lots', item.displayVolume.toString(), colorScheme),
                _buildDetailItem(context, 'Bonus', item.displayBonus.toString(), colorScheme),
                _buildDetailItem(context, 'Open Price', item.displayOpenPrice.toString(), colorScheme),
                if (item.displayClosePrice != 0)
                  _buildDetailItem(context, 'Close Price', item.displayClosePrice.toString(), colorScheme),
                _buildDetailItem(context, 'S/L', item.displaySl.toString(), colorScheme),
                _buildDetailItem(context, 'T/P', item.displayTp.toString(), colorScheme),
                _buildDetailItem(context, 'Commission', item.displayCommission.toString(), colorScheme),
                _buildDetailItem(context, 'Swap', item.displaySwap.toString(), colorScheme),
                _buildDetailItem(context, 'Floating P/L', item.displayProfit.toStringAsFixed(2), colorScheme),
              ],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Timeline Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeItem(context, 'Opened', item.displayOpenTime, colorScheme, Icons.play_circle_outline),
              if (item.displayCloseTime != '-' && item.displayCloseTime.isNotEmpty)
                _buildTimeItem(context, 'Closed', item.displayCloseTime, colorScheme, Icons.stop_circle_outlined, isEnd: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value, ColorScheme colorScheme) {
    return SizedBox(
      width: MediaQuery.widthOf(context)-16.s/2, // Adjusted for internal padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11.sp, fontWeight: FontWeight.w500)),
          SizedBox(height: 2.h),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp, color: colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildTimeItem(BuildContext context, String label, String timeStr, ColorScheme colorScheme, IconData icon, {bool isEnd = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isEnd) Icon(icon, size: 14.sp, color: colorScheme.primary),
        if (!isEnd) SizedBox(width: 4.w),
        Column(
          crossAxisAlignment: isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10.sp)),
            Text(timeStr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp)),
          ],
        ),
        if (isEnd) SizedBox(width: 4.w),
        if (isEnd) Icon(icon, size: 14.sp, color: colorScheme.error),
      ],
    );
  }
}
