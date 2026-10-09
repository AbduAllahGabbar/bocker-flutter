import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:res_reline/my_responsive.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/config/routes/routes_manager.dart';
import '../../../../core/componants/toast.dart';
import '../../../../core/componants/async_dropdownmenu.dart';
import 'package:dio/dio.dart';
import '../../../transactions/data/models/payment_method_model.dart';
import '../cubit/add_payment_method_cubit.dart';
import '../cubit/add_payment_method_state.dart';

class AddBankPaymentPage extends StatelessWidget {
  final PaymentMethodModel method;
  
  const AddBankPaymentPage({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DI.initAddPaymentMethod(),
      child: _AddBankPaymentView(method: method),
    );
  }
}

class _AddBankPaymentView extends StatefulWidget {
  final PaymentMethodModel method;
  
  const _AddBankPaymentView({required this.method});

  @override
  State<_AddBankPaymentView> createState() => _AddBankPaymentViewState();
}

class _AddBankPaymentViewState extends State<_AddBankPaymentView> {
  final _beneficiaryController = TextEditingController();
  final _accountController = TextEditingController();
  final _swiftController = TextEditingController();
  final _notesController = TextEditingController();

  Map<String, dynamic>? _selectedCurrency;
  List<Map<String, dynamic>> _currencies = [];

  Future<List<Map<String, dynamic>>> _fetchCurrencies() async {
    if (_currencies.isNotEmpty) {
      return _currencies;
    }
    
    try {
      final response = await di<Dio>().post('https://boker.egytag.com/api/currencies/all', data: {});
      if (response.statusCode == 200) {
        final list = response.data['list'] as List;
        _currencies = list.cast<Map<String, dynamic>>();
        return _currencies;
      }
    } catch (e) {
      debugPrint('Error fetching currencies: $e');
    }
    return [];
  }

  @override
  void dispose() {
    _beneficiaryController.dispose();
    _accountController.dispose();
    _swiftController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_beneficiaryController.text.trim().isEmpty || 
        _accountController.text.trim().isEmpty || 
        _swiftController.text.trim().isEmpty ||
        _selectedCurrency == null) {
      ToastState.error.snackBar(context, 'Please fill required fields and select currency');
      return;
    }

    Map<String, dynamic> data = {
      "paymentMethod": {
        "code": widget.method.code,
        "name": widget.method.name,
      },
      "beneficiaryName": _beneficiaryController.text.trim(),
      "accountNumber": _accountController.text.trim(),
      "swiftCode": _swiftController.text.trim(),
      "currency": {
        "_id": _selectedCurrency!["_id"],
        "name": _selectedCurrency!["name"],
        "id": _selectedCurrency!["id"]
      },
      if (_notesController.text.trim().isNotEmpty)
        "notes": _notesController.text.trim()
    };

    context.read<AddPaymentMethodCubit>().submitPaymentMethod(data);
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
                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h, bottom: 100.h),
                children: [
                  Text(
                    'Add Bank Details',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Enter beneficiary information for wire transfer.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  SizedBox(height: 32.h),

                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Beneficiary Name', context),
                        _buildTextField(_beneficiaryController, 'e.g. John Doe', Icons.person_outline),
                        SizedBox(height: 16.h),
                        
                        _buildLabel('Account Number / IBAN', context),
                        _buildTextField(_accountController, 'Enter account number', Icons.account_balance_outlined),
                        SizedBox(height: 16.h),

                        _buildLabel('SWIFT / BIC Code', context),
                        _buildTextField(_swiftController, '8 OR 11 CHARACTERS', Icons.public),
                        SizedBox(height: 16.h),

                        _buildLabel('Currency', context),
                        DropdownButtonSearch<Map<String, dynamic>>(
                          value: _selectedCurrency,
                          onChanged: (val) {
                            setState(() {
                              _selectedCurrency = val;
                            });
                          },
                          asyncItems: () => _fetchCurrencies(),
                          onView: (item) => item?['name']?.toString() ?? '',
                          label: 'Select Currency',
                        ),
                        SizedBox(height: 16.h),

                        _buildLabel('Reference / Notes (Optional)', context),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add a note for this recipient...',
                              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(bottom: 40.h),
                                child: Icon(Icons.notes, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                            ),
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
                child: SizedBox(
                  width: double.infinity,
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
          fontSize: 12.s,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
          border: InputBorder.none,
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
        ),
      ),
    );
  }
}
