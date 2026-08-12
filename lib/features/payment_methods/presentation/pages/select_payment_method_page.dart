import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:res_reline/my_responsive.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/config/routes/routes_manager.dart';
import '../../../transactions/data/models/payment_method_model.dart';
import '../cubit/add_payment_method_cubit.dart';
import '../cubit/add_payment_method_state.dart';

class SelectPaymentMethodPage extends StatelessWidget {
  const SelectPaymentMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DI.initAddPaymentMethod()..fetchAvailableMethods(),
      child: const _SelectPaymentMethodView(),
    );
  }
}

class _SelectPaymentMethodView extends StatefulWidget {
  const _SelectPaymentMethodView();

  @override
  State<_SelectPaymentMethodView> createState() => _SelectPaymentMethodViewState();
}

class _SelectPaymentMethodViewState extends State<_SelectPaymentMethodView> {
  PaymentMethodModel? _selectedMethod;

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
          'Add Payment Method',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
            onPressed: () {},
          )
        ],
      ),
      body: BlocBuilder<AddPaymentMethodCubit, AddPaymentMethodState>(
        builder: (context, state) {
          if (state is AddPaymentMethodLoading || state is AddPaymentMethodInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AddPaymentMethodError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: TextStyle(color: colorScheme.error)),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<AddPaymentMethodCubit>().fetchAvailableMethods(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is AvailableMethodsLoaded) {
            return _buildContent(context, state.methods);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<PaymentMethodModel> methods) {
    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h, bottom: 100.h),
          children: [
            Center(
              child: Text(
                'Add Payment Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            SizedBox(height: 8.h),
            Center(
              child: Text(
                'Choose a payment method to add your payment details.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
            SizedBox(height: 32.h),
            ...methods.map((method) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _buildMethodOption(context, method),
                )),
          ],
        ),
        Positioned(
          left: 20.w,
          right: 20.w,
          bottom: 24.h,
          child: ElevatedButton(
            onPressed: _selectedMethod == null
                ? null
                : () {
                    final code = _selectedMethod!.code.toLowerCase();
                    if (code == 'trc' || code == 'erc' || code == 'btc') {
                      context.pushNamed(RoutesNames.addCryptoPayment, extra: _selectedMethod);
                    } else if (code == 'visa' || code == 'mastercard') {
                      context.pushNamed(RoutesNames.addCardPayment, extra: _selectedMethod);
                    } else if (code == 'bank' || code == 'localpay') {
                      context.pushNamed(RoutesNames.addBankPayment, extra: _selectedMethod);
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            child: Text(
              'Continue',
              style: TextStyle(
                fontSize: 16.s,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodOption(BuildContext context, PaymentMethodModel method) {
    final isSelected = _selectedMethod?.code == method.code;
    final colorScheme = Theme.of(context).colorScheme;
    final code = method.code.toLowerCase();

    IconData iconData = Icons.payment;
    if (code == 'bank' || code == 'localpay') iconData = Icons.account_balance;
    if (code == 'visa' || code == 'mastercard') iconData = Icons.credit_card;
    if (code == 'trc' || code == 'erc' || code == 'btc') iconData = Icons.currency_bitcoin;

    String subtitle = '';
    if (code == 'trc') subtitle = 'Tether (Tron Network)';
    if (code == 'erc') subtitle = 'Tether (Ethereum Network)';
    if (code == 'btc') subtitle = 'Bitcoin Network';
    if (code == 'visa') subtitle = 'Credit or Debit Card';
    if (code == 'bank') subtitle = 'International or Local';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer.withOpacity(0.3) : colorScheme.surfaceContainerLowest,
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant.withOpacity(0.5),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: colorScheme.onSurfaceVariant),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13.s,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary)
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
