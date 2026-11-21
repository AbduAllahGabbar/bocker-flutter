import 'package:boker/core/packages/res_reline/my_responsive.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/language/language_manager.dart';
import '../cubit/add_transaction_state.dart';

/// Shows the MyFatoorah payment quote exactly as the backend returned it.
///
/// The app never calculates fees: whatever
/// `POST /api/accountsTransactions/myfatoorah-quote` sends back is what is
/// displayed, and values the backend omitted are not drawn at all.
class MyFatoorahQuoteCard extends StatelessWidget {
  const MyFatoorahQuoteCard({super.key, required this.state});

  final AddTransactionState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (state.quoteStatus) {
      case QuoteStatus.idle:
        return const SizedBox.shrink();

      case QuoteStatus.loading:
        return _shell(
          context,
          child: Row(
            children: [
              SizedBox(
                height: 18.r,
                width: 18.r,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12.w),
              Text('Calculating fees...'.tran),
            ],
          ),
        );

      case QuoteStatus.failure:
        return _shell(
          context,
          color: colorScheme.errorContainer,
          child: Text(
            state.quoteErrorMessage ?? 'Could not load the payment quote'.tran,
            style: TextStyle(color: colorScheme.onErrorContainer),
          ),
        );

      case QuoteStatus.loaded:
        final quote = state.quote;
        if (quote == null || !quote.hasBreakdown) {
          // The backend returned no breakdown - show nothing rather than a
          // number the app made up.
          return const SizedBox.shrink();
        }

        final currency = quote.currency ?? '';

        return _shell(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PAYMENT SUMMARY'.tran,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 12.h),
              if (quote.amount != null)
                _row(context, 'Amount'.tran, quote.amount!, currency),
              if (quote.fee != null)
                _row(
                  context,
                  quote.feeType == 'percent' && quote.feeValue != null
                      ? '${'Processing fee'.tran} (${quote.feeValue}%)'
                      : 'Processing fee'.tran,
                  quote.fee!,
                  currency,
                ),
              if (quote.total != null) ...[
                Divider(color: colorScheme.outlineVariant, height: 20.h),
                _row(
                  context,
                  'Total to pay'.tran,
                  quote.total!,
                  currency,
                  emphasised: true,
                ),
              ],
            ],
          ),
        );
    }
  }

  Widget _shell(BuildContext context, {required Widget child, Color? color}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: color ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: child,
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    num value,
    String currency, {
    bool emphasised = false,
  }) {
    final theme = Theme.of(context);
    final style = emphasised
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)
        : theme.textTheme.bodyMedium;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: emphasised
                ? style
                : theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              currency.isEmpty
                  ? value.toString()
                  : '$value ${currency.toUpperCase()}',
              textAlign: TextAlign.end,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}
