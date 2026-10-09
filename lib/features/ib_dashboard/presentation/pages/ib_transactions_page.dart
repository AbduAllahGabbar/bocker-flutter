import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:res_reline/my_responsive.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/config/language/language_manager.dart';
import '../cubit/ib_transactions_cubit.dart';
import '../cubit/ib_transactions_state.dart';
import '../../data/models/ib_transaction_model.dart';
import 'package:intl/intl.dart';

class IbTransactionsPage extends StatefulWidget {
  final String title;

  const IbTransactionsPage({super.key, required this.title});

  @override
  State<IbTransactionsPage> createState() => _IbTransactionsPageState();
}

class _IbTransactionsPageState extends State<IbTransactionsPage> {
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
      context.read<IbTransactionsCubit>().fetchTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => context.read<IbTransactionsCubit>().onSearchChanged(val),
              decoration: InputDecoration(
                hintText: 'Search...'.tran,
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<IbTransactionsCubit, IbTransactionsState>(
              builder: (context, state) {
                if (state.isLoading && state.transactionData == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.error != null && state.transactionData == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.error!, style: TextStyle(color: colorScheme.error)),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () => context.read<IbTransactionsCubit>().fetchTransactions(isRefresh: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final items = state.transactionData?.list ?? [];

                if (items.isEmpty) {
                  return Center(child: Text('No transactions found'.tran));
                }

                return RefreshIndicator(
                  onRefresh: () => context.read<IbTransactionsCubit>().fetchTransactions(isRefresh: true),
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16.r),
                    itemCount: items.length + (state.isLoadingMore ? 1 : 0),
                    separatorBuilder: (context, index) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      if (index == items.length) {
                        return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                      }
                      
                      final item = items[index];
                      return _buildTransactionCard(context, item, colorScheme);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, IbTransaction item, ColorScheme colorScheme) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final dateStr = item.date != null ? dateFormat.format(DateTime.tryParse(item.date!) ?? DateTime.now()) : '';
    
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.operation?.name ?? 'Transaction',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
              Text(
                '\$${item.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (item.user != null) ...[
            Text('User: ${item.user!.name ?? item.user!.email ?? ''}', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13.sp)),
            SizedBox(height: 4.h),
          ],
          if (item.comment != null && item.comment!.isNotEmpty) ...[
            Text('Comment: ${item.comment}', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12.sp)),
            SizedBox(height: 4.h),
          ],
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12.sp),
              ),
              if (item.addUserInfo != null)
                Text(
                  'Added by: ${item.addUserInfo!.name ?? ''}',
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10.sp),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
