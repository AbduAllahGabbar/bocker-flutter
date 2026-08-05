import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:res_reline/my_responsive.dart';
import '../../../../core/config/language/language_manager.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/componants/async_dropdownmenu.dart';
import '../cubit/create_account_cubit.dart';
import '../cubit/create_account_state.dart';
import '../../data/models/create_account_models.dart';
import '../cubit/accounts_cubit.dart';

class CreateAccountPage extends StatelessWidget {
  const CreateAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DI.initCreateAccount(),
      child: const _CreateAccountView(),
    );
  }
}

class _CreateAccountView extends StatelessWidget {
  const _CreateAccountView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Account'.tran,
          style: TextStyle(fontSize: 20.s, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<CreateAccountCubit, CreateAccountState>(
        listener: (context, state) {
          if (state is CreateAccountSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Account Created Successfully'.tr())),
            );
            context.read<AccountsCubit>().fetchAccounts();
            Navigator.of(context).pop();
          } else if (state is CreateAccountError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CreateAccountLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          bool isReal = true;
          AccountTypeModel? selectedAccountType;
          LeverageModel? selectedLeverage;
          OpeningBalanceModel? selectedOpeningBalance;
          
          if (state is CreateAccountFormUpdated) {
            isReal = state.isReal;
            selectedAccountType = state.selectedAccountType;
            selectedLeverage = state.selectedLeverage;
            selectedOpeningBalance = state.selectedOpeningBalance;
          }

          final cubit = context.read<CreateAccountCubit>();

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildToggle(context, isReal, cubit),
                SizedBox(height: 24.s),
                
                if (isReal) ...[
                  Text('Account Type'.tran, style: _labelStyle(theme)),
                  SizedBox(height: 8.s),
                  DropdownButtonSearch<AccountTypeModel>(
                    label: 'Select Account Type'.tran,
                    value: selectedAccountType,
                    asyncItems: () => cubit.getAccountTypes(),
                    onView: (item) => item?.name,
                    onChanged: (val) => cubit.setAccountType(val),
                  ),
                  
                  if (selectedAccountType != null) ...[
                    SizedBox(height: 8.s),
                    Text(
                      'Minimum deposit: \$${selectedAccountType.min}'.tran,
                      style: TextStyle(
                        fontSize: 12.s,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  SizedBox(height: 16.s),
                  Text('Leverage'.tran, style: _labelStyle(theme)),
                  SizedBox(height: 8.s),
                  DropdownButtonSearch<LeverageModel>(
                    label: 'Select Leverage'.tran,
                    value: selectedLeverage,
                    asyncItems: () => cubit.getLeverages(),
                    onView: (item) => item?.name,
                    onChanged: (val) => cubit.setLeverage(val),
                  ),
                ] else ...[
                  Text('Leverage'.tran, style: _labelStyle(theme)),
                  SizedBox(height: 8.s),
                  DropdownButtonSearch<LeverageModel>(
                    label: 'Select Leverage'.tran,
                    value: selectedLeverage,
                    asyncItems: () => cubit.getLeverages(),
                    onView: (item) => item?.name,
                    onChanged: (val) => cubit.setLeverage(val),
                  ),

                  SizedBox(height: 16.s),
                  Text('Opening Balance'.tran, style: _labelStyle(theme)),
                  SizedBox(height: 8.s),
                  DropdownButtonSearch<OpeningBalanceModel>(
                    label: 'Select Opening Balance'.tran,
                    value: selectedOpeningBalance,
                    asyncItems: () => cubit.getOpeningBalances(),
                    onView: (item) => item?.name,
                    onChanged: (val) => cubit.setOpeningBalance(val),
                  ),
                ],

                SizedBox(height: 32.s),
                ElevatedButton(
                  onPressed: () {
                    cubit.submit();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.s),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.s),
                    ),
                  ),
                  child: Text(
                    'Create'.tran,
                    style: TextStyle(fontSize: 16.s, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  TextStyle _labelStyle(ThemeData theme) {
    return TextStyle(
      fontSize: 14.s,
      fontWeight: FontWeight.w600,
    );
  }

  Widget _buildToggle(BuildContext context, bool isReal, CreateAccountCubit cubit) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12.s),
      ),
      padding: EdgeInsets.all(4.s),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => cubit.toggleAccountMode(true),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.s),
                decoration: BoxDecoration(
                  color: isReal ? theme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.s),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Real'.tran,
                  style: TextStyle(
                    color: isReal ? Colors.white : (theme.brightness == Brightness.dark ? Colors.white : Colors.black),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => cubit.toggleAccountMode(false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.s),
                decoration: BoxDecoration(
                  color: !isReal ? theme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.s),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Demo'.tran,
                  style: TextStyle(
                    color: !isReal ? Colors.white : (theme.brightness == Brightness.dark ? Colors.white : Colors.black),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
