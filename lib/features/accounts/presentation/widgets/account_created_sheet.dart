import 'package:boker/core/packages/res_reline/my_responsive.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/language/language_manager.dart';
import '../../../../core/config/routes/routes_manager.dart';
import '../../data/models/account_model.dart';

/// Shows the account the backend actually created.
///
/// Every value comes from the API response — nothing is fabricated, and rows
/// the backend did not return are simply not drawn.
class AccountCreatedSheet extends StatelessWidget {
  const AccountCreatedSheet({super.key, required this.account});

  final AccountModel account;

  static Future<void> show(BuildContext context, AccountModel account) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => AccountCreatedSheet(account: account),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.s, 4.s, 20.s, 20.s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.check_circle, size: 48.r, color: colorScheme.primary),
            SizedBox(height: 12.s),
            Text(
              'Account Created Successfully'.tran,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 20.s),

            // The account number the user will quote to support.
            _Row(
              label: 'Account Number'.tran,
              value: account.displayNumber,
              emphasised: true,
            ),
            _Row(
              label: 'Type'.tran,
              value: account.isDemo ? 'Demo'.tran : 'Real'.tran,
            ),
            if (account.accountType?['name'] != null)
              _Row(
                label: 'Account Type'.tran,
                value: account.accountType!['name'].toString(),
              ),
            if (account.leverage?['name'] != null)
              _Row(
                label: 'Leverage'.tran,
                value: account.leverage!['name'].toString(),
              ),
            if (account.initialBalance?['name'] != null)
              _Row(
                label: 'Opening Balance'.tran,
                value: account.initialBalance!['name'].toString(),
              ),
            if (account.statusName != null) _StatusRow(account: account),

            if (account.hasMt5Details) ...[
              SizedBox(height: 16.s),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'MT5 DETAILS'.tran,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              SizedBox(height: 8.s),
              if (account.mt5Login != null)
                _Row(label: 'MT5 Login'.tran, value: account.mt5Login!),
              if (account.mt5Server != null)
                _Row(label: 'Server'.tran, value: account.mt5Server!),
              if (account.mt5Group != null)
                _Row(label: 'Group'.tran, value: account.mt5Group!),
            ],

            if (account.isPending) ...[
              SizedBox(height: 16.s),
              Container(
                padding: EdgeInsets.all(12.s),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Your account is awaiting approval. You will be notified once it is approved.'
                      .tran,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ],

            SizedBox(height: 24.s),
            // MT5 data is only meaningful for an approved real account.
            if (!account.isDemo && !account.isPending)
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pushNamed(RoutesNames.mt5Data, extra: account);
                },
                icon: const Icon(Icons.analytics_outlined),
                label: Text('View MT5 Data'.tran),
              ),
            SizedBox(height: 8.s),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Done'.tran),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.emphasised = false,
  });

  final String label;
  final String value;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
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
              style:
                  (emphasised
                          ? theme.textTheme.titleMedium
                          : theme.textTheme.bodyMedium)
                      ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.account});

  final AccountModel account;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color color;
    if (account.isApproved) {
      color = Colors.green;
    } else if (account.isRejected) {
      color = colorScheme.error;
    } else {
      color = Colors.orange;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Status'.tran,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.s, vertical: 4.s),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              account.statusName!,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12.s,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
