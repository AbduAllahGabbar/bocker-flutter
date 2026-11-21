import 'package:boker/core/packages/res_reline/my_responsive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/language/language_manager.dart';
import '../../../../core/packages/dropdown_search/dropdown_search.dart';
import '../../../../features/accounts/data/models/account_model.dart';
import '../../data/models/payment_method_model.dart';
import '../cubit/add_transaction_cubit.dart';
import '../cubit/add_transaction_state.dart';
import '../widgets/deposit_proof_field.dart';
import '../widgets/myfatoorah_quote_card.dart';
import '../widgets/payment_details_widget.dart';
import '../widgets/transaction_result_sheet.dart';

class AddTransactionPage extends StatefulWidget {
  final String initialType; // 'deposit', 'transfer', 'withdrawal'
  final AccountModel? initialAccount;

  const AddTransactionPage({
    super.key,
    required this.initialType,
    this.initialAccount,
  });

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
    if (_selectedType == 'withdrawal') {
      _selectedType = 'withdrawal'; // Match segmented control label
    }
    _selectedAccount = widget.initialAccount;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // --- Derived form facts ---------------------------------------------------

  bool get _isDeposit => _selectedType == 'deposit';

  bool get _isTransfer => _selectedType == 'transfer';

  bool get _isMyFatoorah =>
      _isDeposit && AddTransactionCubit.isMyFatoorah(_selectedPaymentMethod);

  /// Proof of payment applies to manual deposits only - a gateway deposit is
  /// confirmed by the gateway itself.
  bool get _supportsProof =>
      _isDeposit && _selectedPaymentMethod != null && !_isMyFatoorah;

  bool get _proofRequired =>
      _supportsProof &&
      AddTransactionCubit.methodsRequiringProof.contains(
        _selectedPaymentMethod!.code.toLowerCase(),
      );

  double get _amount => double.tryParse(_amountController.text.trim()) ?? 0;

  // --- Actions --------------------------------------------------------------

  void _onAmountChanged(String _) {
    setState(() {});
    final account = _selectedAccount;
    if (_isMyFatoorah && account != null) {
      context.read<AddTransactionCubit>().requestQuote(
        account: account,
        amount: _amount,
      );
    }
  }

  void _onPaymentMethodChanged(PaymentMethodModel? method) {
    setState(() => _selectedPaymentMethod = method);

    final cubit = context.read<AddTransactionCubit>();
    cubit.clearQuote();
    cubit.removeAttachment();

    final account = _selectedAccount;
    if (_isMyFatoorah && account != null && _amount > 0) {
      cubit.requestQuote(account: account, amount: _amount);
    }
  }

  void _onAccountChanged(AccountModel? account) {
    setState(() => _selectedAccount = account);
    if (_isMyFatoorah && account != null && _amount > 0) {
      context.read<AddTransactionCubit>().requestQuote(
        account: account,
        amount: _amount,
      );
    }
  }

  Future<void> _pickProof({required bool fromCamera}) async {
    final cubit = context.read<AddTransactionCubit>();

    if (fromCamera) {
      final picked = await ImagePicker().pickImage(source: ImageSource.camera);
      if (picked == null) return;
      await cubit.attachProof(picked.path, isImage: true);
      return;
    }

    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: AddTransactionCubit.allowedAttachmentExtensions
          .toList(),
    );
    if (files.isEmpty) return;
    final path = files.first.path;
    if (path == null) return;

    final extension = path.split('.').last.toLowerCase();
    await cubit.attachProof(path, isImage: extension != 'pdf');
  }

  String? _validate(AddTransactionState state) {
    if (_amount <= 0) return 'Please enter a valid amount'.tran;
    if (_selectedAccount == null) return 'Please select an account'.tran;
    if (!_isTransfer && _selectedPaymentMethod == null) {
      return 'Please select a payment method'.tran;
    }
    if (_isTransfer && _selectedAccountTo == null) {
      return 'Please select a destination account'.tran;
    }
    if (_isTransfer && _selectedAccountTo?.id == _selectedAccount?.id) {
      return 'Choose a different destination account'.tran;
    }
    // Caught here so the client is told before a deposit is created and
    // rejected. The backend remains the authority on both rules.
    final account = _selectedAccount;
    if (_isDeposit && account != null) {
      if (account.isRejected || account.isPending) {
        return 'This account is not approved for deposits yet'.tran;
      }
      final minimum = account.minimumDeposit;
      if (minimum != null && minimum > 0 && _amount < minimum) {
        return '${'Minimum deposit is'.tran} ${minimum.toStringAsFixed(2)}';
      }
    }
    if (_proofRequired && !state.hasAttachment) {
      return 'Please attach your transfer receipt'.tran;
    }
    if (state.isUploadingAttachment) {
      return 'Please wait for the attachment to finish uploading'.tran;
    }
    return null;
  }

  void _submit(AddTransactionState state) {
    final error = _validate(state);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    context.read<AddTransactionCubit>().submitTransaction(
      type: _selectedType,
      amount: _amount,
      account: _selectedAccount!,
      paymentMethod: _isTransfer ? null : _selectedPaymentMethod,
      accountTo: _isTransfer ? _selectedAccountTo : null,
    );
  }

  Future<void> _onSubmitted(AddTransactionState state) async {
    final cubit = context.read<AddTransactionCubit>();
    final paymentUrl = state.paymentUrl;

    var openedPaymentPage = false;

    if (paymentUrl != null) {
      final uri = Uri.tryParse(paymentUrl);
      openedPaymentPage =
          uri != null &&
          await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!mounted) return;
      if (!openedPaymentPage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the payment page'.tran)),
        );
      }
    }

    if (!mounted) return;
    // The status is not re-read here: `launchUrl` returns as soon as the
    // browser opens, so anything read now is from before the user has even
    // seen the payment page. The sheet re-reads it when the app comes back
    // and keeps checking while the backend confirms.
    await TransactionResultSheet.show(
      context,
      transaction: cubit.state.transaction,
      openedPaymentPage: openedPaymentPage,
      onRefreshStatus: cubit.refreshCreatedTransaction,
    );

    if (!mounted) return;
    context.pop(true); // tell the caller to reload its list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Add Transaction'.tran),
        centerTitle: true,
      ),
      body: BlocConsumer<AddTransactionCubit, AddTransactionState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == AddTransactionStatus.success) {
            _onSubmitted(state);
          } else if (state.status == AddTransactionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? 'Something went wrong'.tran,
                ),
              ),
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
                  onSelected: _onAccountChanged,
                  itemAsString: (item) => '${item.displayNumber}',
                  dropdownBuilder: _buildAccountDropdownBuilder,
                  decoratorProps: _bareDecoration,
                  suffixProps: _noSuffix,
                  popupProps: PopupProps.menu(
                    showSearchBox: false,
                    showSelectedItems: true,
                    itemBuilder: _buildAccountPopupItem,
                  ),
                ),
                if (_isTransfer) ...[
                  SizedBox(height: 16.h),
                  _buildLabel('ACCOUNT TO'),
                  DropdownSearch<AccountModel>(
                    selectedItem: _selectedAccountTo,
                    items: (filter, loadProps) => cubit.getAccounts(),
                    compareFn: (item1, item2) => item1.id == item2.id,
                    onSelected: (val) =>
                        setState(() => _selectedAccountTo = val),
                    itemAsString: (item) => '${item.displayNumber}',
                    dropdownBuilder: _buildAccountDropdownBuilder,
                    decoratorProps: _bareDecoration,
                    suffixProps: _noSuffix,
                    popupProps: PopupProps.menu(
                      showSearchBox: false,
                      showSelectedItems: true,
                      itemBuilder: _buildAccountPopupItem,
                    ),
                  ),
                ],
                if (!_isTransfer) ...[
                  SizedBox(height: 24.h),
                  _buildLabel('PAYMENT METHOD'),
                  DropdownSearch<PaymentMethodModel>(
                    key: Key('payment_method_$_selectedType'),
                    selectedItem: _selectedPaymentMethod,
                    items: (filter, loadProps) =>
                        cubit.getPaymentMethods(type: _selectedType),
                    compareFn: (item1, item2) => item1.code == item2.code,
                    onSelected: _onPaymentMethodChanged,
                    itemAsString: (item) => item.name,
                    dropdownBuilder: _buildPaymentMethodDropdownBuilder,
                    decoratorProps: _bareDecoration,
                    suffixProps: _noSuffix,
                    popupProps: const PopupProps.menu(showSearchBox: false),
                  ),
                  PaymentDetailsWidget(paymentMethod: _selectedPaymentMethod),
                ],
                SizedBox(height: 24.h),
                _buildAmountInput(),
                if (_isMyFatoorah) ...[
                  SizedBox(height: 16.h),
                  MyFatoorahQuoteCard(state: state),
                ],
                if (_supportsProof) ...[
                  SizedBox(height: 24.h),
                  _buildLabel(
                    _proofRequired
                        ? 'TRANSFER RECEIPT (REQUIRED)'
                        : 'TRANSFER RECEIPT (OPTIONAL)',
                  ),
                  DepositProofField(
                    state: state,
                    onPickFile: () => _pickProof(fromCamera: false),
                    onPickCamera: () => _pickProof(fromCamera: true),
                    onRemove: cubit.removeAttachment,
                  ),
                ],
                SizedBox(height: 24.h),
                _buildSummaryCard(state),
                SizedBox(height: 32.h),
                _buildSubmitButton(state),
              ],
            ),
          );
        },
      ),
    );
  }

  static const DropDownDecoratorProps _bareDecoration = DropDownDecoratorProps(
    decoration: InputDecoration(
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
      isDense: true,
      filled: false,
    ),
  );

  static const DropdownSuffixProps _noSuffix = DropdownSuffixProps(
    dropdownButtonProps: DropdownButtonProps(isVisible: false),
  );

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
                if (_selectedType == type) return;
                setState(() {
                  _selectedType = type;
                  _selectedPaymentMethod = null;
                });
                context.read<AddTransactionCubit>()
                  ..clearQuote()
                  ..removeAttachment();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: isSelected
                      ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                      : [],
                ),
                child: Center(
                  child: Text(
                    type[0].toUpperCase() + type.substring(1),
                    style: TextStyle(
                      color: isSelected
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
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

  /// `Demo · 300.00` - same wording as the account switcher on the home page.
  String _accountSubtitle(AccountModel account) =>
      '${account.isDemo ? 'Demo'.tran : 'Real'.tran} · '
      '${account.balance.toStringAsFixed(2)}';

  /// One row of the account popup: number, demo/real + balance, and a check
  /// mark on the selected one.
  Widget _buildAccountPopupItem(
    BuildContext context,
    AccountModel item,
    bool isDisabled,
    bool isSelected,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.displayNumber,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDisabled
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _accountSubtitle(item),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(Icons.check, size: 18.r, color: colorScheme.primary),
        ],
      ),
    );
  }

  Widget _buildAccountDropdownBuilder(
    BuildContext context,
    AccountModel? item,
  ) {
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
                  item == null
                      ? 'Select Account'.tran
                      : '${item.displayNumber}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: item == null
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                  ),
                ),
                if (item != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    _accountSubtitle(item),
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

  Widget _buildPaymentMethodDropdownBuilder(
    BuildContext context,
    PaymentMethodModel? item,
  ) {
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
            child: Icon(
              Icons.currency_exchange,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              item == null ? 'Select Payment Method'.tran : item.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: item == null
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface,
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
        onChanged: _onAmountChanged,
      ),
    );
  }

  Widget _buildSummaryCard(AddTransactionState state) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Type'.tran,
            _selectedType[0].toUpperCase() + _selectedType.substring(1),
          ),
          Divider(color: colorScheme.outlineVariant, height: 24.h),
          _buildSummaryRow(
            'To'.tran,
            _isTransfer
                ? (_selectedAccountTo != null
                      ? '${_selectedAccountTo!.displayNumber}'
                      : '-')
                : (_selectedAccount != null
                      ? '${_selectedAccount!.displayNumber}'
                      : '-'),
          ),
          if (!_isTransfer) ...[
            Divider(color: colorScheme.outlineVariant, height: 24.h),
            _buildSummaryRow(
              'Method'.tran,
              _selectedPaymentMethod?.name ?? '-',
            ),
          ],
          if (state.hasAttachment) ...[
            Divider(color: colorScheme.outlineVariant, height: 24.h),
            _buildSummaryRow(
              'Receipt'.tran,
              state.attachmentName ?? 'Attached'.tran,
            ),
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
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AddTransactionState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final isBusy = state.isSubmitting || state.isUploadingAttachment;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isBusy ? null : () => _submit(state),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: state.isSubmitting
            ? SizedBox(
                height: 24.h,
                width: 24.h,
                child: CircularProgressIndicator(
                  color: colorScheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : Text(
                _isMyFatoorah
                    ? 'Continue to payment'.tran
                    : '${'Confirm'.tran} ${_selectedType[0].toUpperCase()}${_selectedType.substring(1)}',
                style: TextStyle(fontSize: 16, color: colorScheme.onPrimary),
              ),
      ),
    );
  }
}
