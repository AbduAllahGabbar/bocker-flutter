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
import 'package:flutter_credit_card/flutter_credit_card.dart';

class AddCardPaymentPage extends StatelessWidget {
  final PaymentMethodModel method;
  
  const AddCardPaymentPage({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DI.initAddPaymentMethod(),
      child: _AddCardPaymentView(method: method),
    );
  }
}

class _AddCardPaymentView extends StatefulWidget {
  final PaymentMethodModel method;
  
  const _AddCardPaymentView({required this.method});

  @override
  State<_AddCardPaymentView> createState() => _AddCardPaymentViewState();
}

class _AddCardPaymentViewState extends State<_AddCardPaymentView> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void _submit(BuildContext context) {
    if (formKey.currentState?.validate() ?? false) {
      // In a real app, parse the MM/YY into a proper ISO date
      final dateStr = "2026-12-31T23:59:59.000Z"; // Placeholder for API format

      Map<String, dynamic> data = {
        "paymentMethod": {
          "code": widget.method.code,
          "name": widget.method.name,
        },
        "cardNumber": cardNumber,
        "cardholderName": cardHolderName,
        "cardExpiryDate": dateStr, 
        "cvvCode": cvvCode,
      };

      context.read<AddPaymentMethodCubit>().submitPaymentMethod(data);
    } else {
      ToastState.error.snackBar(context, 'Please fill all fields correctly');
    }
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    if (creditCardModel != null) {
      setState(() {
        cardNumber = creditCardModel.cardNumber;
        expiryDate = creditCardModel.expiryDate;
        cardHolderName = creditCardModel.cardHolderName;
        cvvCode = creditCardModel.cvvCode;
        isCvvFocused = creditCardModel.isCvvFocused;
      });
    }
  }

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
                padding: EdgeInsets.only(top: 20.h, bottom: 100.h),
                children: [
                  Center(
                    child: Text(
                      'Add New Card',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Center(
                    child: Text(
                      'Securely link your Visa or Mastercard',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  
                  CreditCardWidget(
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    cvvCode: cvvCode,
                    bankName: 'BrokerPro',
                    showBackView: isCvvFocused,
                    obscureCardNumber: true,
                    obscureCardCvv: true,
                    isHolderNameVisible: true,
                    cardBgColor: colorScheme.primary,
                    onCreditCardWidgetChange: (CreditCardBrand brand) {},
                    customCardTypeIcons: <CustomCardTypeIcon>[
                      CustomCardTypeIcon(
                        cardType: CardType.mastercard,
                        cardImage: Image.asset(
                          'assets/mastercard.png', // Fallback, usually handles defaults
                          height: 48,
                          width: 48,
                        ),
                      ),
                    ],
                  ),
                  
                  CreditCardForm(
                    formKey: formKey,
                    obscureCvv: true,
                    obscureNumber: true,
                    cardNumber: cardNumber,
                    cvvCode: cvvCode,
                    isHolderNameVisible: true,
                    isCardNumberVisible: true,
                    isExpiryDateVisible: true,
                    cardHolderName: cardHolderName,
                    expiryDate: expiryDate,
                    onCreditCardModelChange: onCreditCardModelChange,
                    inputConfiguration: InputConfiguration(
                      cardNumberDecoration: InputDecoration(
                        labelText: 'Number',
                        hintText: 'XXXX XXXX XXXX XXXX',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      expiryDateDecoration: InputDecoration(
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        labelText: 'Expired Date',
                        hintText: 'XX/XX',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      cvvCodeDecoration: InputDecoration(
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        labelText: 'CVV',
                        hintText: 'XXX',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      cardHolderDecoration: InputDecoration(
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        labelText: 'Card Holder',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 20.w,
                right: 20.w,
                bottom: 24.h,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_outlined, size: 16.s, color: colorScheme.onSurfaceVariant),
                        SizedBox(width: 8.w),
                        Text(
                          'Your connection is secure and encrypted',
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12.s),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : () => _submit(context),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        icon: isLoading 
                            ? SizedBox(
                                width: 20.h, 
                                height: 20.h, 
                                child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2)
                              )
                            : Icon(Icons.check_circle_outline, color: colorScheme.onPrimary),
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
