import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:res_reline/my_responsive.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/config/routes/routes_manager.dart';
import '../../../../core/componants/toast.dart';
import '../../../transactions/data/models/payment_method_model.dart';
import '../cubit/add_payment_method_cubit.dart';
import '../cubit/add_payment_method_state.dart';

class AddCryptoPaymentPage extends StatelessWidget {
  final PaymentMethodModel method;
  
  const AddCryptoPaymentPage({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DI.initAddPaymentMethod(),
      child: _AddCryptoPaymentView(method: method),
    );
  }
}

class _AddCryptoPaymentView extends StatefulWidget {
  final PaymentMethodModel method;
  
  const _AddCryptoPaymentView({required this.method});

  @override
  State<_AddCryptoPaymentView> createState() => _AddCryptoPaymentViewState();
}

class _AddCryptoPaymentViewState extends State<_AddCryptoPaymentView> {
  final _addressController = TextEditingController();
  final _aliasController = TextEditingController(); // Optional, but in UI

  @override
  void dispose() {
    _addressController.dispose();
    _aliasController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_addressController.text.trim().isEmpty) {
      ToastState.error.snackBar(context, 'Please enter a wallet address');
      return;
    }

    final code = widget.method.code.toLowerCase();
    Map<String, dynamic> data = {
      "paymentMethod": {
        "code": widget.method.code,
        "name": widget.method.name,
      },
      "walletAddress": _addressController.text.trim(),
    };

    if (code == 'trc') {
      data["network"] = "TRC 20";
    } else if (code == 'erc') {
      data["network"] = "ERC 20";
    }

    context.read<AddPaymentMethodCubit>().submitPaymentMethod(data);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final code = widget.method.code.toLowerCase();
    
    String title = 'Add Crypto Wallet';
    String networkName = '';
    String warningMessage = '';

    if (code == 'btc') {
      title = 'Add BTC Payment Details';
      warningMessage = 'Please double-check your address. Transfers to incorrect addresses cannot be reversed.';
    } else if (code == 'erc') {
      title = 'Add USDT Wallet';
      networkName = 'ERC 20';
      warningMessage = 'Sending funds to an incompatible network address will result in permanent loss of assets.';
    } else if (code == 'trc') {
      title = 'USDT Wallet';
      networkName = 'TRC 20 (Tron)';
      warningMessage = 'Only send USDT to this address via the TRC20 network. Sending other assets or using a different network will result in permanent loss.';
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.method.name,
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
      body: BlocConsumer<AddPaymentMethodCubit, AddPaymentMethodState>(
        listener: (context, state) {
          if (state is AddPaymentSuccess) {
            context.pushReplacementNamed(RoutesNames.addPaymentSuccess);
          } else if (state is AddPaymentMethodError) {
            ToastState.error.snackBar(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AddPaymentMethodLoading;
          return Stack(
            children: [
              ListView(
                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h, bottom: 100.h),
                children: [
                  Text(
                    'ADD PAYMENT METHOD',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 12.s,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    code == 'btc' 
                        ? 'Enter your Bitcoin wallet address to receive withdrawals.'
                        : 'Securely link your wallet for seamless transfers.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  SizedBox(height: 32.h),
                  
                  if (networkName.isNotEmpty) ...[
                    _buildLabel('Network', context),
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLowest,
                        border: Border.all(color: colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.hub, color: colorScheme.primary),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              networkName,
                              style: TextStyle(
                                fontSize: 16.s,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Icon(Icons.check_circle, color: colorScheme.primary),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Please ensure your wallet supports the $networkName network.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13.s),
                    ),
                    SizedBox(height: 24.h),
                  ],

                  _buildLabel(code == 'btc' ? 'Bitcoin Wallet Address' : 'Wallet Address', context),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: code == 'btc' ? 'e.g. 1A1zP1eP...' : '0x...',
                      prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                      suffixIcon: const Icon(Icons.qr_code_scanner),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  
                  if (code == 'btc') ...[
                    Text(
                      'Please double-check your address. Transfers to incorrect addresses cannot be reversed.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13.s),
                    ),
                    SizedBox(height: 24.h),
                    _buildLabel('Alias (Optional)', context),
                    TextField(
                      controller: _aliasController,
                      decoration: InputDecoration(
                        hintText: 'e.g. My Ledger Nano S',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ] else ...[
                    SizedBox(height: 16.h),
                  ],

                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: colorScheme.tertiaryContainer),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: colorScheme.onTertiaryContainer),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Important Notice',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onTertiaryContainer,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                warningMessage,
                                style: TextStyle(
                                  fontSize: 13.s,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 20.w,
                right: 20.w,
                bottom: 24.h,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : () => _submit(context),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  icon: isLoading 
                      ? SizedBox(
                          width: 20.h, 
                          height: 20.h, 
                          child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2)
                        )
                      : Icon(Icons.save, color: colorScheme.onPrimary),
                  label: Text(
                    'Save Payment Details',
                    style: TextStyle(
                      fontSize: 16.s,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
