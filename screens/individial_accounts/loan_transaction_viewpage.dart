import 'package:bridgeapp/src/features/authentication/models/account_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/display_extensions/account_display_extensions.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/pull_to_refresh.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/account_balance_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/credit_transactions/creditloan_transaction_listview.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/recent_summary.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/statements/statements.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/reauthenticate_link_token.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/header_transaction.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/repositories/transactions_repository.dart';

class RecentLoanTransactionViewPage extends StatefulWidget {
  final AccountModel accountData;
  const RecentLoanTransactionViewPage({super.key, required this.accountData});

  @override
  State<RecentLoanTransactionViewPage> createState() =>
      _RecentLoanTransactionViewPageState();
}

class _RecentLoanTransactionViewPageState
    extends State<RecentLoanTransactionViewPage> {
  /// Type of account being displayed
  String accountGroup = 'Loans';

  /// Instantiate the Balance & Transactions Repositories
  final _balanceUpdatesController = Get.put(BalanceUpdatesController());
  final _repoTransactions = Get.put(TransactionsRepository());

  @override
  void initState() {
    super.initState();
    _balanceUpdatesController.sync(widget.accountData);
  }

  @override
  void dispose() {
    _balanceUpdatesController.manuallyDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 231, 245, 242),
        appBar: HeaderTransactions(
          institution: _balanceUpdatesController.data.value!.institution,
          accountID: _balanceUpdatesController.data.value!.accountId,
        ),
        body: PullToRefresh(
          onRefresh: () async => _repoTransactions.refreshData(
            _balanceUpdatesController.data.value!,
          ),
          child: Column(
            children: [
              ReauthenticateLinkToken(controllerTag: 'accountLevel'),
              const SizedBox(height: 50),
              RecentSummary(
                accountname: _balanceUpdatesController.data.value!.accountName,
                last4: _balanceUpdatesController.data.value!.accountMaskDisplay,
                balance:
                    _balanceUpdatesController.data.value!.balanceAmountDisplay,
              ),
              const SizedBox(height: 50),
              Statements(
                accountID: _balanceUpdatesController.data.value!.accountId,
                institution: _balanceUpdatesController.data.value!.institution,
              ),
              const SizedBox(height: 30),
              CreditLoanTransactionList(
                account: _balanceUpdatesController.data.value!,
              ),
              const SizedBox(height: 50)
            ],
          ),
        ),
      );
    });
  }
}
