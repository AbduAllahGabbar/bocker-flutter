import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:res_reline/my_responsive.dart';
import '../../../../core/packages/dropdown_search/dropdown_search.dart';
import '../../../../features/accounts/data/models/account_model.dart';
import '../../data/models/payment_method_model.dart';
import '../cubit/add_transaction_cubit.dart';
import '../cubit/add_transaction_state.dart';
import '../widgets/payment_details_widget.dart';

class AddTransactionPage extends StatefulWidget {
  final String initialType; // 'deposit', 'transfer', 'withdraw'
  final AccountModel? initialAccount;

  const AddTransactionPage({super.key, required this.initialType, this.initialAccount});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  late String _selectedType;
  final TextEditingController _amountController = TextEditingController();

  AccountModel? _selectedAccount;
  AccountModel? _selectedAccountTo;
  PaymentMethodModel? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType.toLowerCase();
    if (_selectedType == 'withdraw') {
      _selectedType = 'withdrawal'; // Match segmented control label
    }
    _selectedAccount = widget.initialAccount;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account')),
      );
      return;
    }
    if (_selectedType != 'transfer' && _selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }
    if (_selectedType == 'transfer' && _selectedAccountTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a destination account')),
      );
      return;
    }

    context.read<AddTransactionCubit>().submitTransaction(
          type: _selectedType,
          amount: amount,
          accountId: _selectedAccount!.mongoId,
          accountIdNum: num.tryParse(_selectedAccount!.id) ?? 0,
          paymentMethodCode: _selectedPaymentMethod?.code,
          paymentMethodName: _selectedPaymentMethod?.name,
          accountToId: _selectedType == 'transfer' ? _selectedAccountTo?.mongoId : null,
          accountToIdNum: _selectedType == 'transfer' ? (num.tryParse(_selectedAccountTo?.id ?? '') ?? 0) : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Add Transaction'),
        centerTitle: true,
      ),
      body: BlocConsumer<AddTransactionCubit, AddTransactionState>(
        listener: (context, state) {
          if (state is AddTransactionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction added successfully!')),
            );
            context.pop(true); // Return true to signal success
          } else if (state is AddTransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<AddTransactionCubit>();

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSegmentedControl(),
                SizedBox(height: 24.h),
                _buildLabel('ACCOUNT'),
                DropdownSearch<AccountModel>(
                  selectedItem: _selectedAccount,
                  items: (filter, loadProps) => cubit.getAccounts(),
                  compareFn: (item1, item2) => item1.id == item2.id,
                  onSelected: (val) => setState(() => _selectedAccount = val),
                  itemAsString: (item) => 'Account #${item.id}',
                  dropdownBuilder: _buildAccountDropdownBuilder,
                  decoratorProps: const DropDownDecoratorProps(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      filled: false,
                    ),
                  ),
                  suffixProps: const DropdownSuffixProps(
                    dropdownButtonProps: DropdownButtonProps(isVisible: false),
                  ),
                  popupProps: const PopupProps.menu(showSearchBox: false),
                ),
                if (_selectedType == 'transfer') ...[
                  SizedBox(height: 16.h),
                  _buildLabel('ACCOUNT TO'),
                  DropdownSearch<AccountModel>(
                    selectedItem: _selectedAccountTo,
                    items: (filter, loadProps) => cubit.getAccounts(),
                    compareFn: (item1, item2) => item1.id == item2.id,
                    onSelected: (val) => setState(() => _selectedAccountTo = val),
                    itemAsString: (item) => 'Account #${item.id}',
                    dropdownBuilder: _buildAccountDropdownBuilder,
                    decoratorProps: const DropDownDecoratorProps(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        filled: false,
                      ),
                    ),
                    suffixProps: const DropdownSuffixProps(
                      dropdownButtonProps: DropdownButtonProps(isVisible: false),
                    ),
                    popupProps: const PopupProps.menu(showSearchBox: false),
                  ),
                ],
                if (_selectedType != 'transfer') ...[
                  SizedBox(height: 24.h),
                  _buildLabel('PAYMENT METHOD'),
                  DropdownSearch<PaymentMethodModel>(
                    key: Key('payment_method_$_selectedType'),
                    selectedItem: _selectedPaymentMethod,
                    items: (filter, loadProps) => cubit.getPaymentMethods(type: _selectedType),
                    compareFn: (item1, item2) => item1.code == item2.code,
                    onSelected: (val) => setState(() {
                      _selectedPaymentMethod = val;
                    }),
                    itemAsString: (item) => item.name,
                    dropdownBuilder: _buildPaymentMethodDropdownBuilder,
                    decoratorProps: const DropDownDecoratorProps(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        filled: false,
                      ),
                    ),
                    suffixProps: const DropdownSuffixProps(
                      dropdownButtonProps: DropdownButtonProps(isVisible: false),
                    ),
                    popupProps: const PopupProps.menu(showSearchBox: false),
                  ),
                  PaymentDetailsWidget(paymentMethod: _selectedPaymentMethod),
                ],
                SizedBox(height: 24.h),
                _buildAmountInput(),
                SizedBox(height: 24.h),
                _buildSummaryCard(),
                SizedBox(height: 32.h),
                _buildSubmitButton(state is AddTransactionLoading),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSegmentedControl() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(4.r),
      child: Row(
        children: ['deposit', 'transfer', 'withdrawal'].map((type) {
          final isSelected = _selectedType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedType != type) {
                  setState(() {
                    _selectedType = type;
                    _selectedPaymentMethod = null;
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.surfaceContainerLowest : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: isSelected
                      ? [BoxShadow(color: Colors.black12, blurRadius: 4)]
                      : [],
                ),
                child: Center(
                  child: Text(
                    type[0].toUpperCase() + type.substring(1),
                    style: TextStyle(
                      color: isSelected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLabel(String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }


  Widget _buildAccountDropdownBuilder(BuildContext context, AccountModel? item) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_balance, color: colorScheme.primary),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item == null ? 'Select Account' : 'Account #${item.id}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: item == null ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                      ),
                ),
                if (item != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Available: ${item.balance} USDT',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodDropdownBuilder(BuildContext context, PaymentMethodModel? item) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.currency_exchange, color: colorScheme.onSecondaryContainer),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              item == null ? 'Select Payment Method' : item.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: item == null ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                  ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                    ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Text(
            'USDT',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Type', _selectedType[0].toUpperCase() + _selectedType.substring(1)),
          Divider(color: colorScheme.outlineVariant, height: 24.h),
          _buildSummaryRow('To', _selectedType == 'transfer' ? (_selectedAccountTo != null ? 'Account #${_selectedAccountTo?.id}' : '-') : (_selectedAccount != null ? 'Account #${_selectedAccount?.id}' : '-')),
          if (_selectedType != 'transfer') ...[
            Divider(color: colorScheme.outlineVariant, height: 24.h),
            _buildSummaryRow('Method', _selectedPaymentMethod?.name ?? '-'),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24.h,
                width: 24.h,
                child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2),
              )
            : Text(
                'Confirm ${_selectedType[0].toUpperCase() + _selectedType.substring(1)}',
                style: TextStyle(fontSize: 16, color: colorScheme.onPrimary),
              ),
      ),
    );
  }
}
