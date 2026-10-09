import 'package:flutter/material.dart';
import 'package:res_reline/my_responsive.dart';
import '../../../../core/config/language/language_manager.dart';
import '../../data/models/account_model.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/routes/routes_manager.dart';

class AccountCard extends StatelessWidget {
  final AccountModel account;

  const AccountCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.s, vertical: 8.s),
      padding: EdgeInsets.all(16.s),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                account.code,
                style: TextStyle(
                  fontSize: 16.s,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.s, vertical: 4.s),
                decoration: BoxDecoration(
                  color: account.active
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.s),
                ),
                child: Text(
                  account.active ? 'Active'.tran : 'Inactive'.tran,
                  style: TextStyle(
                    fontSize: 12.s,
                    fontWeight: FontWeight.w600,
                    color: account.active ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn('Balance'.tran, '\$${account.balance.toStringAsFixed(2)}', isDark),
              _buildInfoColumn('Equity'.tran, '\$${account.equity.toStringAsFixed(2)}', isDark),
              _buildInfoColumn('Leverage'.tran, account.leverage?['name'] ?? '-', isDark),
            ],
          ),
          SizedBox(height: 12.s),
          Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
          SizedBox(height: 8.s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status: ${account.status?['name'] ?? '-'}',
                style: TextStyle(
                  fontSize: 12.s,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                'Type: ${account.accountType?['name'] ?? '-'}',
                style: TextStyle(
                  fontSize: 12.s,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.s),
          Row(
            children: [
              Expanded(
                child: _buildActionBtn(
                  context, 
                  'Deposit'.tran, 
                  Icons.arrow_downward, 
                  Colors.green, 
                  isDark, 
                  () => context.pushNamed(
                    RoutesNames.addTransaction,
                    extra: {'type': 'deposit', 'account': account},
                  )
                ),
              ),
              SizedBox(width: 8.s),
              Expanded(
                child: _buildActionBtn(
                  context, 
                  'Withdraw'.tran, 
                  Icons.arrow_upward, 
                  Colors.red, 
                  isDark, 
                  () => context.pushNamed(
                    RoutesNames.addTransaction,
                    extra: {'type': 'withdrawal', 'account': account},
                  )
                ),
              ),
              if (account.type == 'real') ...[
                SizedBox(width: 8.s),
                Expanded(
                  child: _buildActionBtn(
                    context, 
                    'MT5 Data'.tran, 
                    Icons.analytics, 
                    Theme.of(context).colorScheme.primary, 
                    isDark, 
                    () => context.pushNamed(
                      RoutesNames.mt5Data,
                      extra: account,
                    )
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.s,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        SizedBox(height: 4.s),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.s,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn(BuildContext context, String label, IconData icon, Color color, bool isDark, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.s),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.s, horizontal: 4.s),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.s),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16.s),
            SizedBox(height: 4.s),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.s,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
