import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:boker/core/packages/res_reline/my_responsive.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/config/routes/routes_manager.dart';
import '../../../../core/componants/toast.dart';
import '../../../transactions/data/models/payment_method_model.dart';
import '../../data/models/user_payment_method_model.dart';
import '../cubit/add_payment_method_cubit.dart';
import '../cubit/add_payment_method_state.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class AddCardPaymentPage extends StatelessWidget {
  final PaymentMethodModel method;

  /// When set, saving replaces this existing method (the backend has no
  /// update endpoint - see PaymentMethodsRepository.replacePaymentMethod).
  final UserPaymentMethodModel? replacing;

  const AddCardPaymentPage({super.key, required this.method, this.replacing});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DI.initAddPaymentMethod(),
      child: _AddCardPaymentView(method: method, replacing: replacing),
    );
  }
}

class _AddCardPaymentView extends StatefulWidget {
  final PaymentMethodModel method;
  final UserPaymentMethodModel? replacing;

  const _AddCardPaymentView({required this.method, this.replacing});

  @override
  State<_AddCardPaymentView> createState() => _AddCardPaymentViewState();
}

class _AddCardPaymentViewState extends State<_AddCardPaymentView> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';

  @override
  void initState() {
    super.initState();
    // Edit flow: prefill with the method being replaced.
    final existing = widget.replacing;
    if (existing != null) {
      cardNumber = existing.cardNumber ?? '';
      cardHolderName = existing.cardholderName ?? '';
      final expiry = DateTime.tryParse(existing.cardExpiryDate ?? '');
      if (expiry != null) {
        expiryDate =
            '${expiry.month.toString().padLeft(2, '0')}/'
            '${(expiry.year % 100).toString().padLeft(2, '0')}';
      }
    }
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Converts the `MM/YY` input into the ISO timestamp the API stores.
  /// Returns `null` when the input is not a usable expiry date.
  String? _expiryToIso(String value) {
    final match = RegExp(r'^\s*(\d{2})\s*/\s*(\d{2})\s*$').firstMatch(value);
    if (match == null) return null;

    final month = int.parse(match.group(1)!);
    if (month < 1 || month > 12) return null;
    final year = 2000 + int.parse(match.group(2)!);

    // A card is valid through the last moment of its expiry month.
    final lastDay = DateTime.utc(year, month + 1, 0).day;
    return DateTime.utc(year, month, lastDay, 23, 59, 59).toIso8601String();
  }

  void _submit(BuildContext context) {
    if (formKey.currentState?.validate() ?? false) {
      final dateStr = _expiryToIso(expiryDate);
      if (dateStr == null) {
        ToastState.error.snackBar(
          context,
          'Please enter a valid expiry date (MM/YY)',
        );
        return;
      }

      Map<String, dynamic> data = {
        "paymentMethod": {
          "code": widget.method.code,
          "name": widget.method.name,
        },
        "cardNumber": cardNumber,
        "cardholderName": cardHolderName,
        "cardExpiryDate": dateStr,
      };

      context.read<AddPaymentMethodCubit>().submitPaymentMethod(
        data,
        replacingCode: widget.replacing?.code,
      );
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
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
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
                    // No CVV is collected or stored: the back of the card has
                    // nothing to show, so it is never flipped into view.
                    cvvCode: '',
                    bankName: 'BrokerPro',
                    showBackView: false,
                    isSwipeGestureEnabled: false,
                    obscureCardNumber: true,
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
                    obscureNumber: true,
                    cardNumber: cardNumber,
                    isHolderNameVisible: true,
                    isCardNumberVisible: true,
                    isExpiryDateVisible: true,
                    // Hides the field and keeps it out of the form, so its
                    // validator never runs.
                    enableCvv: false,
                    cvvCode: '',
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
                        Icon(
                          Icons.shield_outlined,
                          size: 16.s,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Your connection is secure and encrypted',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12.s,
                          ),
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
                                child: CircularProgressIndicator(
                                  color: colorScheme.onPrimary,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.check_circle_outline,
                                color: colorScheme.onPrimary,
                              ),
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
