import 'package:boker/core/packages/res_reline/my_responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/language/language_manager.dart';
import '../../../../core/config/routes/routes_manager.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../accounts/presentation/cubit/accounts_cubit.dart';
import '../../../accounts/presentation/cubit/accounts_state.dart';
import '../../../accounts/presentation/cubit/default_account_cubit.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/presentation/cubit/transactions_cubit.dart';
import '../../../transactions/presentation/cubit/transactions_state.dart';
import '../widgets/notification_bell.dart';
import '../widgets/transaction_details_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Filter chip label -> backend transaction type.
  static const Map<String, String?> _filters = {
    'All': null,
    'Deposit': 'deposit',
    'Transfer': 'transfer',
    'Withdrawal': 'withdrawal',
    'Balance-Correction': 'balance-correction',
  };

  @override
  void initState() {
    super.initState();
    context.read<AccountsCubit>().fetchAccounts();
  }

  Future<void> _refresh() async {
    context.read<TransactionsCubit>().fetchTransactions();
    await context.read<AccountsCubit>().fetchAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            scrollCacheExtent: ScrollCacheExtent.pixels(100),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(),
                    SizedBox(height: 24.h),
                    _buildWalletSection(),
                    SizedBox(height: 24.h),
                    _buildActionButtons(),
                    SizedBox(height: 24.h),
                    _buildMT5DataButton(),
                    SizedBox(height: 32.h),
                    Text(
                      'Transactions'.tran,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildAccountSelector()),
        const NotificationBell(),
      ],
    );
  }

  /// The page title is the default account: tapping it opens a popup menu that
  /// switches the account the whole app works with.
  Widget _buildAccountSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(color: colorScheme.onSurface);

    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, state) {
        final accounts = state is AccountsLoaded
            ? state.accounts
            : const <AccountModel>[];

        return BlocBuilder<DefaultAccountCubit, AccountModel?>(
          builder: (context, selected) {
            final current =
                selected ?? (accounts.isEmpty ? null : accounts.first);

            // Nothing to show until the accounts land - keep the old title so
            // the header never collapses.
            if (current == null) {
              return Text(
                'Home'.tran,
                style: titleStyle,
                overflow: TextOverflow.ellipsis,
              );
            }

            final label = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    current.displayNumber,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle,
                  ),
                ),
                if (accounts.length > 1)
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: colorScheme.onSurface,
                    size: 22.r,
                  ),
              ],
            );

            if (accounts.length < 2) return label;

            return PopupMenuButton<AccountModel>(
              tooltip: '',
              padding: EdgeInsets.zero,
              position: PopupMenuPosition.under,
              onSelected: (account) =>
                  context.read<DefaultAccountCubit>().select(account),
              itemBuilder: (context) => accounts
                  .map(
                    (account) => PopupMenuItem<AccountModel>(
                      value: account,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  account.displayNumber,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${account.isDemo ? 'Demo'.tran : 'Real'.tran} · '
                                  '${account.balance.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (account.id == current.id)
                            Icon(
                              Icons.check,
                              size: 18.r,
                              color: colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              child: label,
            );
          },
        );
      },
    );
  }

  // --- Wallet ---------------------------------------------------------------

  Widget _buildWalletSection() {
    return BlocConsumer<AccountsCubit, AccountsState>(
      listener: (context, state) {
        if (state is AccountsLoaded) {
          // Keeps the default account valid and refreshed against the list the
          // backend just returned.
          context.read<DefaultAccountCubit>().syncWith(state.accounts);
        }
      },
      builder: (context, state) {
        if (state is AccountsLoading || state is AccountsInitial) {
          return _walletShell(
            child: SizedBox(
              height: 92.h,
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          );
        }

        if (state is AccountsError) {
          return _walletShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                TextButton(
                  onPressed: () =>
                      context.read<AccountsCubit>().fetchAccounts(),
                  child: Text('Retry'.tran),
                ),
              ],
            ),
          );
        }

        final accounts = state is AccountsLoaded
            ? state.accounts
            : const <AccountModel>[];

        if (accounts.isEmpty) return _buildNoAccountsCard();

        return BlocBuilder<DefaultAccountCubit, AccountModel?>(
          builder: (context, selected) =>
              _buildWalletCard(selected ?? accounts.first),
        );
      },
    );
  }

  Widget _walletShell({required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: child,
    );
  }

  Widget _buildNoAccountsCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return _walletShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MY WALLET'.tran,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'You do not have a trading account yet.'.tran,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.pushNamed(RoutesNames.createAccount),
            child: Text('Create Account'.tran),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(AccountModel account) {
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimary = colorScheme.onPrimary;

    return _walletShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MY WALLET'.tran,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: onPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // Plain text - the account is switched from the page
                    // header now, never from inside the wallet card. Shows the
                    // account CODE, never the id.
                    Text(
                      account.displayNumber,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
            'Available Balance'.tran,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: onPrimary.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 8.h),
          // Real balance from the backend.
          Text(
            account.balance.toStringAsFixed(2),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _walletStat('Equity'.tran, account.equity),
              SizedBox(width: 24.w),
              _walletStat('Credit'.tran, account.credit),
            ],
          ),
          if (account.statusName != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: onPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                account.statusName!,
                style: TextStyle(
                  color: onPrimary,
                  fontSize: 11.s,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _walletStat(String label, num value) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: onPrimary.withValues(alpha: 0.7),
            fontSize: 11.s,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(
            color: onPrimary,
            fontSize: 14.s,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // --- Actions --------------------------------------------------------------

  Widget _buildActionButtons() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          Icons.arrow_downward,
          'Deposit'.tran,
          colorScheme.primaryContainer,
          colorScheme.primary,
          'deposit',
        ),
        _buildActionButton(
          Icons.swap_horiz,
          'Transfer'.tran,
          colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer,
          'transfer',
        ),
        _buildActionButton(
          Icons.arrow_upward,
          'Withdrawal'.tran,
          colorScheme.errorContainer,
          colorScheme.error,
          'withdrawal',
        ),
      ],
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
              // Carry the selected account so the form opens on it.
              extra: {
                'type': type,
                'account': context.read<DefaultAccountCubit>().state,
              },
            );
            if (result == true && mounted) {
              await _refresh();
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

  Widget _buildMT5DataButton() {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.pushNamed(
          RoutesNames.mt5Data,
          extra: context.read<DefaultAccountCubit>().state,
        ),
        icon: Icon(Icons.analytics, color: colorScheme.onSurface),
        label: Text(
          'MT5 Data'.tran,
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

  // --- Transactions ---------------------------------------------------------

  Widget _buildFilterChips() {
    final colorScheme = Theme.of(context).colorScheme;
    final currentFilter = context.watch<TransactionsCubit>().currentFilter;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.entries.map((entry) {
          final isSelected =
              currentFilter == entry.value ||
              (entry.value == null &&
                  (currentFilter == null || currentFilter == 'all'));

          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(entry.key.tran),
              selected: isSelected,
              onSelected: (selected) {
                if (!selected) return;
                context.read<TransactionsCubit>().fetchTransactions(
                  filterType: entry.value ?? 'all',
                );
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

  /// `true` when [transaction] moves money into or out of [account].
  ///
  /// A transfer is kept on both sides, so the selected account still sees the
  /// money it received.
  bool _belongsToAccount(TransactionModel transaction, AccountModel account) {
    return _isSameAccount(transaction.account, account) ||
        _isSameAccount(transaction.accountTo, account);
  }

  /// Matches the account a transaction carries against a full account, on
  /// whichever identifier the backend embedded.
  bool _isSameAccount(Account? embedded, AccountModel account) {
    if (embedded == null) return false;

    final mongoId = embedded.id?.trim();
    if (mongoId != null &&
        mongoId.isNotEmpty &&
        account.mongoId.isNotEmpty &&
        mongoId == account.mongoId) {
      return true;
    }

    final numericId = embedded.accountId?.toString();
    if (numericId != null && account.id.isNotEmpty && numericId == account.id) {
      return true;
    }

    final code = embedded.code?.trim();
    if (code != null && code.isNotEmpty && code == account.code) return true;

    return false;
  }

  Widget _buildTransactionsList() {
    return BlocBuilder<TransactionsCubit, TransactionsState>(
      builder: (context, state) {
        if (state is TransactionsLoading) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.h),
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          );
        }

        if (state is TransactionsError) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                children: [
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<TransactionsCubit>().fetchTransactions(),
                    child: Text('Retry'.tran),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is TransactionsLoaded) {
          // The list follows the default account: only its own movements are
          // shown. With no account selected yet, nothing is filtered out.
          final selected = context.watch<DefaultAccountCubit>().state;
          final transactions = selected == null
              ? state.transactions
              : state.transactions
                    .where((t) => _belongsToAccount(t, selected))
                    .toList();

          if (transactions.isEmpty) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32.h),
                child: Center(child: Text('No transactions found.'.tran)),
              ),
            );
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final transaction = transactions[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: _buildTransactionTile(transaction),
              );
            }, childCount: transactions.length),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildTransactionTile(TransactionModel transaction) {
    final colorScheme = Theme.of(context).colorScheme;

    final IconData icon;
    final Color iconBgColor;
    final Color iconColor;
    final Color amountColor;
    final String prefix;

    switch (transaction.type) {
      case 'deposit':
        icon = Icons.arrow_downward;
        iconBgColor = colorScheme.primaryContainer;
        iconColor = colorScheme.primary;
        amountColor = colorScheme.primary;
        prefix = '+';
      case 'withdrawal':
        icon = Icons.arrow_upward;
        iconBgColor = colorScheme.errorContainer;
        iconColor = colorScheme.error;
        amountColor = colorScheme.error;
        prefix = '-';
      case 'balance-correction':
        icon = Icons.account_balance_wallet;
        iconBgColor = colorScheme.tertiaryContainer;
        iconColor = colorScheme.onTertiaryContainer;
        amountColor = colorScheme.onSurface;
        prefix = '';
      default:
        icon = Icons.swap_horiz;
        iconBgColor = colorScheme.secondaryContainer;
        iconColor = colorScheme.onSecondaryContainer;
        amountColor = colorScheme.onSurface;
        prefix = '';
    }

    String title = transaction.paymentMethod?.name ?? 'Transaction'.tran;
    if (transaction.type == 'transfer') {
      // User-facing account numbers, never internal ids.
      final from = transaction.account?.displayNumber ?? '';
      final to = transaction.accountTo?.displayNumber ?? '';
      title = to.isNotEmpty ? 'Account $from → $to' : 'Account $from';
    }

    String dateStr = '';
    if (transaction.date != null) {
      final date = DateTime.tryParse(transaction.date!);
      dateStr = date != null
          ? DateFormat('MMM dd, h:mm a').format(date.toLocal())
          : transaction.date!;
    }

    return InkWell(
      onTap: () => TransactionDetailsSheet.show(context, transaction),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
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
                      Expanded(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '$prefix${transaction.amount?.toStringAsFixed(2) ?? '0.00'}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
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
      ),
    );
  }
}
