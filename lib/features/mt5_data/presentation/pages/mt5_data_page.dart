import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:boker/core/packages/res_reline/my_responsive.dart';
import '../cubit/mt5_data_cubit.dart';
import '../cubit/mt5_data_state.dart';
import '../../../../features/accounts/data/models/account_model.dart';
import '../../data/models/mt5_item_model.dart';
import '../../data/models/mt5_order_type.dart';

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

  /// The symbol / order-type filters are also applied locally, so a page can
  /// come back fully filtered out: keep paging instead of showing "empty".
  bool _needsMorePages(Mt5DataState state) {
    final needsMore =
        state.hasMore && state.list.isNotEmpty && !state.isLoadingList;
    if (needsMore) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<Mt5DataCubit>().fetchList(isLoadMore: true);
      });
    }
    return state.hasMore && state.list.isNotEmpty;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<Mt5DataCubit>().fetchList(isLoadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Mt5DataCubit, Mt5DataState>(
      listener: (context, state) {
        if (state.error != null && state.error!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        final cubit = context.read<Mt5DataCubit>();
        final items = state.visibleList;

        return Scaffold(
          appBar: AppBar(
            title: const Text('MT5 Data'),
            actions: [
              if (state.isSyncing)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Center(
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.sync),
                  onPressed: state.selectedAccount != null
                      ? () => cubit.syncAccount()
                      : null,
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
                      SizedBox(height: 12.h),
                      _buildSearchBar(context, state),
                      SizedBox(height: 16.h),
                    ]),
                  ),
                ),
                if (state.isLoadingList && items.isEmpty)
                  const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (items.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: _needsMorePages(state)
                            ? const CircularProgressIndicator()
                            : const Text('No records found.'),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index >= items.length) {
                          return state.hasMore
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _Mt5ListItem(item: items[index]),
                        );
                      }, childCount: items.length + (state.hasMore ? 1 : 0)),
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
              child: Text('Account ${account.displayNumber}'),
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
            style: TextStyle(
              color: colorScheme.onPrimary.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '\$${summary.displayBalance.toStringAsFixed(2)}',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 28.sp,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                'EQUITY',
                '\$${summary.displayEquity.toStringAsFixed(2)}',
                colorScheme,
              ),
              _buildSummaryItem(
                'MARGIN',
                '\$${summary.displayMargin.toStringAsFixed(2)}',
                colorScheme,
              ),
              _buildSummaryItem(
                'PROFIT',
                '\$${summary.displayProfit.toStringAsFixed(2)}',
                colorScheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onPrimary.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
            fontSize: 10.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
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
                    initialDateRange:
                        state.dateFrom != null && state.dateTo != null
                        ? DateTimeRange(
                            start: state.dateFrom!,
                            end: state.dateTo!,
                          )
                        : null,
                  );
                  if (picked != null) {
                    cubit.setDateRange(picked.start, picked.end);
                  }
                },
                icon: const Icon(Icons.date_range, size: 18),
                label: Text(
                  state.dateFrom != null && state.dateTo != null
                      ? '${DateFormat('MMM d, y').format(state.dateFrom!)} - ${DateFormat('MMM d, y').format(state.dateTo!)}'
                      : 'Date Range',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            TextButton(
              onPressed: state.hasActiveFilters
                  ? () {
                      _searchController.clear();
                      FocusScope.of(context).unfocus();
                      cubit.clearFilters();
                    }
                  : null,
              child: const Text('Clear'),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildOptionsDropdown(
                context: context,
                label: 'Order type',
                icon: Icons.category_outlined,
                value: state.typeFilter,
                options: [
                  for (final type in Mt5OrderType.all)
                    (value: type.value, label: type.label),
                ],
                onChanged: cubit.setTypeFilter,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildOptionsDropdown(
                context: context,
                label: 'Symbol',
                icon: Icons.show_chart,
                value: state.symbolFilter,
                options: [
                  for (final symbol in state.availableSymbols)
                    (value: symbol, label: symbol),
                ],
                onChanged: cubit.setSymbolFilter,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionsDropdown({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String? value,
    required List<({String value, String label})> options,
    required ValueChanged<String?> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    // Keep a selected value usable even if it is not part of the options list.
    final items = [
      ...options,
      if (value != null && !options.any((o) => o.value == value))
        (value: value, label: value),
    ];
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return DropdownButtonFormField<String>(
      // FormField does not re-read initialValue on rebuild, so the key makes
      // the field follow the cubit (e.g. when filters are cleared).
      key: ValueKey('$label-${value ?? 'all'}'),
      initialValue: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      borderRadius: BorderRadius.circular(12.r),
      style: TextStyle(fontSize: 13.sp, color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13.sp,
          color: colorScheme.onSurfaceVariant,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(
          icon,
          size: 18.sp,
          color: colorScheme.onSurfaceVariant,
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 34.w),
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: colorScheme.primary),
        ),
      ),
      hint: Text(
        'All',
        style: TextStyle(fontSize: 13.sp, color: colorScheme.onSurfaceVariant),
      ),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text('All', style: TextStyle(fontSize: 13.sp)),
        ),
        ...items.map(
          (option) => DropdownMenuItem<String>(
            value: option.value,
            child: Text(
              option.label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.sp),
            ),
          ),
        ),
      ],
      onChanged: items.isEmpty ? null : onChanged,
    );
  }

  Widget _buildFilterChip(
    String kind,
    String label,
    Mt5DataState state,
    Mt5DataCubit cubit,
  ) {
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
          color: isSelected
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, Mt5DataState state) {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search order id, symbol...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: state.searchQuery.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _searchController.clear();
                  FocusScope.of(context).unfocus();
                  context.read<Mt5DataCubit>().setSearchQuery('');
                },
              ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
      onSubmitted: (val) {
        context.read<Mt5DataCubit>().setSearchQuery(val.trim());
      },
    );
  }
}

/// A single record, collapsed to the essentials and expandable for the rest.
class _Mt5ListItem extends StatefulWidget {
  const _Mt5ListItem({required this.item});

  final Mt5ItemModel item;

  @override
  State<_Mt5ListItem> createState() => _Mt5ListItemState();
}

class _Mt5ListItemState extends State<_Mt5ListItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final colorScheme = Theme.of(context).colorScheme;
    final amount = item.displayAmount;
    final isPositive = amount >= 0;
    final type = item.displayType.toLowerCase();

    final icon = switch (type) {
      'deposit' => Icons.arrow_downward,
      'withdrawal' || 'withdraw' => Icons.arrow_upward,
      'transfer' => Icons.swap_horiz,
      'balance' => Icons.account_balance_wallet_outlined,
      'credit' || 'bonus' => Icons.card_giftcard,
      'buy' => Icons.trending_up,
      'sell' => Icons.trending_down,
      _ => Icons.receipt_long_outlined,
    };

    final accent = isPositive ? colorScheme.primary : colorScheme.error;
    final accentContainer = isPositive
        ? colorScheme.primaryContainer
        : colorScheme.errorContainer;
    final onAccentContainer = isPositive
        ? colorScheme.onPrimaryContainer
        : colorScheme.onErrorContainer;

    final title = item.displaySymbol.isNotEmpty
        ? item.displaySymbol
        : (item.displayType.isNotEmpty ? item.displayType : 'Transaction');

    return Container(
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
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: accentContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: onAccentContainer, size: 20.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.displayTypeLabel.toUpperCase(),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                '#${item.displayTicket}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _money(amount, signed: true),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17.sp,
                            color: accent,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          item.displayOpenTime,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: _buildDetails(context, item, colorScheme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(
    BuildContext context,
    Mt5ItemModel item,
    ColorScheme colorScheme,
  ) {
    final details = <({String label, String value})>[
      (label: 'Order ID', value: item.displayTicket),
      (label: 'Type', value: item.displayTypeLabel),
      if (item.displaySymbol.isNotEmpty)
        (label: 'Symbol', value: item.displaySymbol),
      if (item.displayDirection.isNotEmpty)
        (label: 'Side', value: item.displayDirection.toUpperCase()),
      (label: 'Amount', value: _money(item.displayAmount, signed: true)),
      (label: 'Lots', value: _number(item.displayVolume)),
      (label: 'Bonus', value: _number(item.displayBonus)),
      if (item.displayCredit != 0)
        (label: 'Credit', value: _number(item.displayCredit)),
      if (item.displayOpenPrice != 0)
        (label: 'Open Price', value: _number(item.displayOpenPrice)),
      if (item.displayClosePrice != 0)
        (label: 'Close Price', value: _number(item.displayClosePrice)),
      if (item.displaySl != 0) (label: 'S/L', value: _number(item.displaySl)),
      if (item.displayTp != 0) (label: 'T/P', value: _number(item.displayTp)),
      (label: 'Commission', value: _number(item.displayCommission)),
      (label: 'Swap', value: _number(item.displaySwap)),
      (label: 'Floating P/L', value: item.displayProfit.toStringAsFixed(2)),
      (label: 'Open Time', value: item.displayOpenTime),
      (label: 'Close Time', value: item.displayCloseTime),
      if (item.displayPaymentMethod.isNotEmpty)
        (label: 'Payment Method', value: item.displayPaymentMethod),
      if (item.displaySource.isNotEmpty)
        (label: 'Source', value: item.displaySource),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 14.h),
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final spacing = 12.w;
              final itemWidth = (constraints.maxWidth - spacing) / 2;
              return Wrap(
                spacing: spacing,
                runSpacing: 12.h,
                children: details
                    .map(
                      (detail) => SizedBox(
                        width: itemWidth,
                        child: _buildDetailItem(
                          detail.label,
                          detail.value,
                          colorScheme,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
        if (item.displayComment.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Text(
            item.displayComment,
            style: TextStyle(
              fontSize: 11.sp,
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value.isEmpty ? '-' : value,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13.sp,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _money(num value, {bool signed = false}) {
    final sign = (!signed || value == 0) ? '' : (value > 0 ? '+' : '-');
    return '$sign\$${value.abs().toStringAsFixed(2)}';
  }

  String _number(num value) => value.toStringAsFixed(2);
}
