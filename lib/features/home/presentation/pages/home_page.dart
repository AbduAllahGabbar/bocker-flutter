import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:res_reline/my_responsive.dart';
import '../../../../core/config/routes/routes_manager.dart';
import '../../../transactions/presentation/cubit/transactions_cubit.dart';
import '../../../transactions/presentation/cubit/transactions_state.dart';
import '../../../transactions/data/models/transaction_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> filters = [
    'All',
    'Deposit',
    'Transfer',
    'Withdraw',
    'Balance-Correction',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<TransactionsCubit>().fetchTransactions();
          },
          child: CustomScrollView(
            scrollCacheExtent: ScrollCacheExtent.pixels(100),
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(),
                    SizedBox(height: 24.h),
                    _buildWalletCard(),
                    SizedBox(height: 24.h),
                    _buildActionButtons(),
                    SizedBox(height: 24.h),
                    _buildMT5DataButton(),
                    SizedBox(height: 32.h),
                    _buildTransactionsHeader(),
                    SizedBox(height: 16.h),
                    _buildFilterChips(),
                    SizedBox(height: 16.h),
                  ]),
                ),
              ),
              _buildTransactionsList(),
              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Home',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(color: colorScheme.onSurface),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(8.r),
          child: Icon(Icons.notifications_none, color: colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildWalletCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MY WALLET\nAccount #7',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
              Icon(
                Icons.account_balance_wallet_outlined,
                color: colorScheme.secondary,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'Available Balance',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '\$12,450.00',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          Icons.arrow_downward,
          'Deposit',
          colorScheme.primaryContainer,
          colorScheme.primary,
          'deposit',
        ),
        _buildActionButton(
          Icons.swap_horiz,
          'Transfer',
          colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer,
          'transfer',
        ),
        _buildActionButton(
          Icons.arrow_upward,
          'Withdraw',
          colorScheme.errorContainer,
          colorScheme.error,
          'withdraw',
        ),
      ],
    );
  }



  Widget _buildMT5DataButton() {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          context.pushNamed(RoutesNames.mt5Data);
        },
        icon: Icon(Icons.analytics, color: colorScheme.onSurface),
        label: Text(
          'MT5 Data',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          backgroundColor: colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor,
    String type,
  ) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        elevation: 0,
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final result = await context.pushNamed(
              RoutesNames.addTransaction,
              extra: type,
            );
            if (result == true) {
              // Refresh transactions list
              if (mounted) {
                context.read<TransactionsCubit>().fetchTransactions();
              }
            }
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                SizedBox(height: 12.h),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Transactions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'See all',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected =
              context.watch<TransactionsCubit>().currentFilter ==
                  filter.toLowerCase() ||
              (filter == 'All' &&
                  context.watch<TransactionsCubit>().currentFilter == null);
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  context.read<TransactionsCubit>().fetchTransactions(
                    filterType: filter.toLowerCase(),
                  );
                }
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
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.outlineVariant
                      : Colors.transparent,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return BlocBuilder<TransactionsCubit, TransactionsState>(
      builder: (context, state) {
        if (state is TransactionsLoading) {
          return SliverToBoxAdapter(
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        } else if (state is TransactionsError) {
          return SliverToBoxAdapter(child: Center(child: Text(state.message)));
        } else if (state is TransactionsLoaded) {
          if (state.transactions.isEmpty) {
            return const SliverToBoxAdapter(
              child: Center(child: Text('No transactions found.')),
            );
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final transaction = state.transactions[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: _buildTransactionTile(transaction),
              );
            }, childCount: state.transactions.length),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildTransactionTile(TransactionModel transaction) {
    IconData icon;
    Color iconBgColor;
    Color iconColor;
    Color amountColor;
    String prefix;

    final colorScheme = Theme.of(context).colorScheme;

    if (transaction.type == 'deposit') {
      icon = Icons.arrow_downward;
      iconBgColor = colorScheme.primaryContainer;
      iconColor = colorScheme.primary;
      amountColor = colorScheme.primary;
      prefix = '+';
    } else if (transaction.type == 'withdraw') {
      icon = Icons.arrow_upward;
      iconBgColor = colorScheme.errorContainer;
      iconColor = colorScheme.error;
      amountColor = colorScheme.error;
      prefix = '-';
    } else if (transaction.type == 'balance-correction') {
      icon = Icons.account_balance_wallet;
      iconBgColor = colorScheme.tertiaryContainer;
      iconColor = colorScheme.onTertiaryContainer;
      amountColor = colorScheme.onSurface;
      prefix = '';
    } else {
      icon = Icons.swap_horiz;
      iconBgColor = colorScheme.secondaryContainer;
      iconColor = colorScheme.onSecondaryContainer;
      amountColor = colorScheme.onSurface;
      prefix = '';
    }

    String title = transaction.paymentMethod?.name ?? 'Unknown';
    if (transaction.type == 'transfer' && transaction.account != null) {
      title = 'Account -> #${transaction.account?.accountId ?? ''}';
    }

    String dateStr = '';
    if (transaction.date != null) {
      try {
        final date = DateTime.parse(transaction.date!);
        dateStr = DateFormat('MMM dd h:mm a').format(date);
      } catch (e) {
        dateStr = transaction.date!;
      }
    }

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$prefix${transaction.amount?.toStringAsFixed(2) ?? '0.00'}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateStr,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (transaction.transactionStatus?.name != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          transaction.transactionStatus!.name!,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
