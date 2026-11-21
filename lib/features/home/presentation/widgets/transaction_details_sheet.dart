import 'package:boker/core/packages/res_reline/my_responsive.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/language/language_manager.dart';
import '../../../transactions/data/models/transaction_model.dart';

/// Details of one transaction, built entirely from the record the backend
/// returned. Rows the backend did not send are not drawn.
class TransactionDetailsSheet extends StatelessWidget {
  const TransactionDetailsSheet({super.key, required this.transaction});

  final TransactionModel transaction;

  static Future<void> show(BuildContext context, TransactionModel transaction) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => TransactionDetailsSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final date = transaction.date == null
        ? null
        : DateTime.tryParse(transaction.date!);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.s, 4.s, 20.s, 24.s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Transaction details'.tran,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 20.s),

            if (transaction.code != null)
              _row(context, 'Reference'.tran, transaction.code!),
            if (transaction.type != null)
              _row(
                context,
                'Type'.tran,
                transaction.type![0].toUpperCase() +
                    transaction.type!.substring(1),
              ),
            if (transaction.amount != null)
              _row(
                context,
                'Amount'.tran,
                transaction.amount!.toStringAsFixed(2),
              ),
            if (transaction.account?.displayNumber.isNotEmpty ?? false)
              _row(context, 'Account'.tran, transaction.account!.displayNumber),
            if (transaction.accountTo?.displayNumber.isNotEmpty ?? false)
              _row(
                context,
                'To account'.tran,
                transaction.accountTo!.displayNumber,
              ),
            if (transaction.paymentMethod?.name != null)
              _row(context, 'Method'.tran, transaction.paymentMethod!.name!),
            if (date != null)
              _row(
                context,
                'Date'.tran,
                DateFormat('MMM dd, yyyy  •  hh:mm a').format(date.toLocal()),
              ),
            if (transaction.transactionStatus?.name != null)
              _row(
                context,
                'Status'.tran,
                transaction.transactionStatus!.name!,
              ),

            SizedBox(height: 20.s),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
              ),
              child: Text('Close'.tran),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(width: 12.s),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
