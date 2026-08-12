import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:res_reline/my_responsive.dart';
import '../../../../core/config/routes/routes_manager.dart';
import '../../../../core/di/di_container.dart';
import '../../data/models/user_payment_method_model.dart';
import '../cubit/payment_methods_cubit.dart';
import '../cubit/payment_methods_state.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DI.initPaymentMethods()..fetchPaymentMethods(),
      child: const _PaymentMethodsView(),
    );
  }
}

class _PaymentMethodsView extends StatelessWidget {
  const _PaymentMethodsView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<PaymentMethodsCubit, PaymentMethodsState>(
        builder: (context, state) {
          if (state is PaymentMethodsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PaymentMethodsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: TextStyle(color: colorScheme.error)),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<PaymentMethodsCubit>().fetchPaymentMethods(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is PaymentMethodsLoaded) {
            return _buildContent(context, state.paymentMethods);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<UserPaymentMethodModel> methods) {
    return RefreshIndicator(
      onRefresh: () => context.read<PaymentMethodsCubit>().fetchPaymentMethods(),
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h, bottom: 100.h),
            children: [
              Text(
                'Saved Payment Methods',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.s,
                    ),
              ),
              SizedBox(height: 16.h),
              if (methods.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Text(
                      'No saved payment methods',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ...methods.map((method) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _buildPaymentMethodCard(context, method),
                  )),
            ],
          ),
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 24.h,
            child: ElevatedButton.icon(
              onPressed: () async {
                await context.pushNamed(RoutesNames.selectPaymentMethod);
                // Refresh list after returning from add
                if (context.mounted) {
                  context.read<PaymentMethodsCubit>().fetchPaymentMethods();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
              label: Text(
                'Add Payment Method',
                style: TextStyle(
                  fontSize: 16.s,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(BuildContext context, UserPaymentMethodModel method) {
    final colorScheme = Theme.of(context).colorScheme;
    IconData iconData = Icons.payment;
    Color iconBgColor = colorScheme.surfaceContainerHighest;
    Color iconColor = colorScheme.onSurfaceVariant;
    
    final code = method.paymentMethod.code.toLowerCase();

    if (code == 'bank') {
      iconData = Icons.account_balance;
      iconBgColor = colorScheme.surfaceContainerHighest;
      iconColor = colorScheme.onSurfaceVariant;
    } else if (code == 'visa' || code == 'mastercard') {
      iconData = Icons.credit_card;
      iconBgColor = colorScheme.tertiaryContainer;
      iconColor = colorScheme.onTertiaryContainer;
    } else if (code == 'trc' || code == 'erc' || code == 'btc') {
      iconData = Icons.currency_bitcoin; // Or appropriate crypto icon
      iconBgColor = colorScheme.primaryContainer;
      iconColor = colorScheme.primary;
    }

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method.paymentMethod.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 4.h),
                if (code == 'bank') ...[
                  _buildDetailText('Beneficiary: ', method.beneficiaryName ?? '-', context),
                  _buildDetailText('Account: ', _maskAccount(method.accountNumber), context),
                  _buildDetailText('SWIFT: ', _maskSwift(method.swiftCode), context),
                ] else if (code == 'visa' || code == 'mastercard') ...[
                  Text(
                    _maskCard(method.cardNumber),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 2,
                    ),
                  ),
                ] else ...[
                  Text(
                    _maskWallet(method.walletAddress),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation(context, method);
              }
              // TODO: Handle edit actions
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UserPaymentMethodModel method) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Payment Method'),
          content: Text('Are you sure you want to delete ${method.paymentMethod.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<PaymentMethodsCubit>().deletePaymentMethod(method.code);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailText(String label, String value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13.s,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 13.s,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _maskCard(String? cardNumber) {
    if (cardNumber == null || cardNumber.isEmpty) return '.... .... .... ....';
    // Just a placeholder mask for visual matching if not a real format
    return '.... .... .... 1234';
  }

  String _maskAccount(String? account) {
    if (account == null || account.isEmpty) return '......';
    return '......1234'; 
  }

  String _maskSwift(String? swift) {
    if (swift == null || swift.isEmpty) return '...';
    return 'ABCD...';
  }

  String _maskWallet(String? wallet) {
    if (wallet == null || wallet.isEmpty) return '0x...';
    return '0x82.........92A';
  }
}
