import 'package:bridgeapp/src/features/authentication/models/account_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/display_extensions/account_display_extensions.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/pull_to_refresh.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/account_balance_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/deposit_account_transactions/deposit_transaction_listview.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/recent_summary.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/statements/statements.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/reauthenticate_link_token.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/header_transaction.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/repositories/transactions_repository.dart';

class RecentCheckingsTransactionViewPage extends StatefulWidget {
  final AccountModel accountData;

  const RecentCheckingsTransactionViewPage({
    super.key,
    required this.accountData,
  });

  @override
  State<RecentCheckingsTransactionViewPage> createState() =>
      _RecentCheckingsTransactionViewPageState();
}

class _RecentCheckingsTransactionViewPageState
    extends State<RecentCheckingsTransactionViewPage> {
  /// Instantiate the Transactions Repositories
  final _controllerBalanceUpdates = Get.put(BalanceUpdatesController());
  final _repoTransactions = Get.put(TransactionsRepository());

  @override
  void initState() {
    super.initState();
    _controllerBalanceUpdates.sync(widget.accountData);
  }

  @override
  void dispose() {
    _controllerBalanceUpdates.manuallyDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 231, 245, 242),
        appBar: HeaderTransactions(
          institution: _controllerBalanceUpdates.data.value!.institution,
          accountID: _controllerBalanceUpdates.data.value!.accountId,
        ),
        body: PullToRefresh(
          onRefresh: () async => _repoTransactions.refreshData(
            _controllerBalanceUpdates.data.value!,
          ),
          child: Column(
            children: [
              ReauthenticateLinkToken(controllerTag: 'accountLevel'),
              const SizedBox(height: 50),
              RecentSummary(
                  accountname:
                      _controllerBalanceUpdates.data.value!.accountName,
                  last4:
                      _controllerBalanceUpdates.data.value!.accountMaskDisplay,
                  balance: _controllerBalanceUpdates
                      .data.value!.balanceAmountDisplay),
              const SizedBox(height: 50),
              Statements(
                accountID: _controllerBalanceUpdates.data.value!.accountId,
                institution: _controllerBalanceUpdates.data.value!.institution,
              ),
              const SizedBox(height: 30),
              DepositRecentTransactionList(
                account: _controllerBalanceUpdates.data.value!,
              ),
              const SizedBox(height: 50)
            ],
          ),
        ),
      );
    });
  }
}
