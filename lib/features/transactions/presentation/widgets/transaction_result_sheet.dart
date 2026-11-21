import 'dart:async';

import 'package:boker/core/packages/res_reline/my_responsive.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/language/language_manager.dart';
import '../../data/models/transaction_model.dart';

/// Shows the status the backend reports for a freshly created transaction.
///
/// Returning from a hosted payment page is never treated as proof of payment:
/// the only thing displayed here is the transaction's own `transactionStatus`
/// as the server reports it, and the user can re-read it on demand.
class TransactionResultSheet extends StatefulWidget {
  const TransactionResultSheet({
    super.key,
    required this.transaction,
    required this.openedPaymentPage,
    required this.onRefreshStatus,
  });

  final TransactionModel? transaction;
  final bool openedPaymentPage;
  final Future<TransactionModel?> Function() onRefreshStatus;

  static Future<void> show(
    BuildContext context, {
    required TransactionModel? transaction,
    required bool openedPaymentPage,
    required Future<TransactionModel?> Function() onRefreshStatus,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => TransactionResultSheet(
        transaction: transaction,
        openedPaymentPage: openedPaymentPage,
        onRefreshStatus: onRefreshStatus,
      ),
    );
  }

  @override
  State<TransactionResultSheet> createState() => _TransactionResultSheetState();
}

class _TransactionResultSheetState extends State<TransactionResultSheet> {
  /// How long to keep re-reading a transaction that is not settled yet, and
  /// how long to wait between tries. The backend confirms a gateway payment
  /// through its own webhook, which can land a few seconds after the user is
  /// back in the app.
  static const List<Duration> _pollSchedule = <Duration>[
    Duration(seconds: 3),
    Duration(seconds: 5),
    Duration(seconds: 8),
    Duration(seconds: 13),
  ];

  late TransactionModel? _transaction = widget.transaction;
  bool _isRefreshing = false;

  AppLifecycleListener? _lifecycleListener;
  Timer? _pollTimer;
  int _pollAttempt = 0;

  @override
  void initState() {
    super.initState();
    if (!widget.openedPaymentPage) return;

    // Coming back from the hosted page is the moment the status may have
    // changed - re-read it then, and keep trying while it is unsettled.
    _lifecycleListener = AppLifecycleListener(onResume: _onResumed);
    _schedulePoll();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _lifecycleListener?.dispose();
    super.dispose();
  }

  void _onResumed() {
    _pollAttempt = 0;
    if (!_isSettled) unawaited(_refresh());
  }

  bool get _isSettled => switch (_transaction?.outcome) {
    TransactionOutcome.completed ||
    TransactionOutcome.rejected ||
    TransactionOutcome.failed ||
    TransactionOutcome.verificationFailed ||
    TransactionOutcome.creditFailed => true,
    _ => false,
  };

  void _schedulePoll() {
    _pollTimer?.cancel();
    if (_isSettled || _pollAttempt >= _pollSchedule.length) return;

    _pollTimer = Timer(_pollSchedule[_pollAttempt++], () async {
      if (!mounted) return;
      await _refresh();
      if (mounted) _schedulePoll();
    });
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    final updated = await widget.onRefreshStatus();
    if (!mounted) return;
    setState(() {
      _transaction = updated ?? _transaction;
      _isRefreshing = false;
    });
  }

  Future<void> _manualRefresh() async {
    _pollAttempt = 0;
    await _refresh();
    if (mounted) _schedulePoll();
  }

  _StatusVisual get _visual {
    final error = Theme.of(context).colorScheme.error;
    return switch (_transaction?.outcome) {
      // Only an approved CRM transaction counts as money in the account.
      TransactionOutcome.completed => const _StatusVisual(
        Icons.check_circle,
        Colors.green,
      ),
      TransactionOutcome.rejected ||
      TransactionOutcome.failed ||
      TransactionOutcome.verificationFailed => _StatusVisual(
        Icons.cancel,
        error,
      ),
      // Paid, but not credited: neither success nor plain failure.
      TransactionOutcome.creditFailed => _StatusVisual(
        Icons.error_outline,
        error,
      ),
      _ => const _StatusVisual(Icons.schedule, Colors.orange),
    };
  }

  /// What the state actually means for the user, in one line.
  String get _explanation {
    return switch (_transaction?.outcome) {
      TransactionOutcome.completed =>
        'Your deposit was approved and credited to your trading account.'.tran,
      TransactionOutcome.awaitingConfirmation =>
        'The payment provider received your payment. Boker still has to confirm it before the balance is updated.'
            .tran,
      TransactionOutcome.creditFailed =>
        'Your payment went through, but the balance could not be updated. Please contact support with the reference above.'
            .tran,
      TransactionOutcome.verificationFailed =>
        'The payment could not be verified. If you were charged, contact support with the reference above.'
            .tran,
      TransactionOutcome.rejected =>
        'This transaction was rejected. Nothing was credited to your account.'
            .tran,
      TransactionOutcome.failed =>
        'The payment did not go through. Nothing was credited to your account.'
            .tran,
      TransactionOutcome.processing =>
        'Your transaction is being processed. This screen updates as soon as Boker confirms it.'
            .tran,
      _ =>
        'Your transaction was created and is waiting to be processed. Closing the payment page does not confirm a payment.'
            .tran,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final transaction = _transaction;
    final statusName = transaction?.transactionStatus?.name;
    final visual = _visual;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.s, 4.s, 20.s, 20.s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(visual.icon, size: 48.r, color: visual.color),
            SizedBox(height: 12.s),
            Text(
              'Transaction submitted'.tran,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 16.s),

            if (transaction?.code != null)
              _row(context, 'Reference'.tran, transaction!.code!),
            if (transaction?.amount != null)
              _row(
                context,
                'Amount'.tran,
                transaction!.amount!.toStringAsFixed(2),
              ),
            if (transaction?.account != null)
              _row(
                context,
                'Account'.tran,
                transaction!.account!.displayNumber,
              ),
            if (transaction?.paymentMethod?.name != null)
              _row(context, 'Method'.tran, transaction!.paymentMethod!.name!),
            if (transaction?.paymentGateway?.status != null)
              _row(
                context,
                'Payment'.tran,
                transaction!.paymentGateway!.status!,
              ),

            SizedBox(height: 8.s),
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: visual.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status'.tran,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 2.s),
                        Text(
                          // Only the backend's own status is shown; when it
                          // sent none, say so instead of guessing.
                          statusName ?? 'Awaiting confirmation'.tran,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: visual.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh status'.tran,
                    onPressed: _isRefreshing ? null : _manualRefresh,
                    icon: _isRefreshing
                        ? SizedBox(
                            height: 18.r,
                            width: 18.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.s),
            Text(
              _explanation,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            SizedBox(height: 20.s),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Done'.tran),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.s),
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

class _StatusVisual {
  final IconData icon;
  final Color color;

  const _StatusVisual(this.icon, this.color);
}
