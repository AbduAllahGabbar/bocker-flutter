import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:res_reline/my_responsive.dart';
import '../../../../core/config/language/language_manager.dart';
import '../../../../core/config/routes/routes_manager.dart';
import '../cubit/accounts_cubit.dart';
import '../cubit/accounts_state.dart';
import '../widgets/account_card.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AccountsCubit>().fetchAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return const _AccountsView();
  }
}

class _AccountsView extends StatelessWidget {
  const _AccountsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Accounts'.tran,
            style: TextStyle(
              fontSize: 20.s,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: theme.primaryColor,
            labelColor: theme.primaryColor,
            unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
            tabs: [
              Tab(text: 'Real Accounts'.tran),
              Tab(text: 'Demo Accounts'.tran),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 90.h),
          child: FloatingActionButton(
            onPressed: () => context.pushNamed(RoutesNames.createAccount),
            backgroundColor: theme.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        body: BlocBuilder<AccountsCubit, AccountsState>(
          builder: (context, state) {
            if (state is AccountsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AccountsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    SizedBox(height: 16.s),
                    ElevatedButton(
                      onPressed: () => context.read<AccountsCubit>().fetchAccounts(),
                      child: Text('Retry'.tran),
                    ),
                  ],
                ),
              );
            } else if (state is AccountsLoaded) {
              final realAccounts = state.accounts.where((a) => a.type == 'real').toList();
              final demoAccounts = state.accounts.where((a) => a.type == 'demo').toList();

              return TabBarView(
                children: [
                  _buildAccountList(context,realAccounts),
                  _buildAccountList(context,demoAccounts),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildAccountList(BuildContext context,List accounts) {
    if (accounts.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => await context.read<AccountsCubit>().fetchAccounts(),
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            Center(
              child: Text(
                'No accounts found'.tran,
                style: TextStyle(
                  fontSize: 16.s,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AccountsCubit>().fetchAccounts(),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.s,0,16.s,90.s),
        itemCount: accounts.length,
        separatorBuilder: (context, index) => SizedBox(height: 3.s),
        itemBuilder: (context, index) {
          return AccountCard(account: accounts[index]);
        },
      ),
    );
  }
}
