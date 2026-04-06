import 'dart:async';
import 'package:bridgeapp/src/features/authentication/models/account_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/account_balance_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/display_extensions/account_display_extensions.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/repositories/transactions_repository.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/services/liability_service.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/pull_to_refresh.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/recent_summary.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/liabilities/mortgages/mortgage_calculator_container.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/liabilities/mortgages/mortgage_loan_container.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/liabilities/mortgages/mortgage_payment_container.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/header_transaction.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/reauthenticate_link_token.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/statements/statements.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MortgageViewPage extends StatefulWidget {
  final AccountModel accountData;
  const MortgageViewPage({super.key, required this.accountData});

  @override
  State<MortgageViewPage> createState() => _MortgageViewPageState();
}

class _MortgageViewPageState extends State<MortgageViewPage> {
  /// Match the AccountGroup used in BalanceRepository for mortgages.
  final _balanceUpdatesController =
      Get.put(BalanceUpdatesController(), permanent: false);
  final _repoTransactions = Get.put(TransactionsRepository());

  @override
  void initState() {
    _balanceUpdatesController.sync(widget.accountData);
    super.initState();
  }

  @override
  void dispose() {
    _balanceUpdatesController.manuallyDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Future<void> refreshPull() async {
        _repoTransactions.refreshData(_balanceUpdatesController.data.value!);
        LiabilityService(
                refreshAccountID:
                    _balanceUpdatesController.data.value!.accountId)
            .plaidRequest();
      }

      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 231, 245, 242),
          appBar: HeaderTransactions(
            institution: _balanceUpdatesController.data.value!.institution,
            accountID: _balanceUpdatesController.data.value!.accountId,
          ),
          body: PullToRefresh(
            onRefresh: refreshPull,
            child: Column(
              children: [
                ReauthenticateLinkToken(controllerTag: 'accountLevel'),
                SizedBox(height: Scale.x(50)),
                RecentSummary(
                  accountname:
                      _balanceUpdatesController.data.value!.accountName,
                  last4:
                      _balanceUpdatesController.data.value!.accountMaskDisplay,
                  balance: _balanceUpdatesController
                      .data.value!.balanceAmountDisplay,
                ),
                SizedBox(height: Scale.x(30)),
                MortgagePaymentContainer(
                    accountData: _balanceUpdatesController.data.value!),
                SizedBox(height: Scale.x(30)),
                MortgageLoanContainer(
                    accountData: _balanceUpdatesController.data.value!),
                SizedBox(height: Scale.x(30)),
                Statements(
                  accountID: _balanceUpdatesController.data.value!.accountId,
                  institution:
                      _balanceUpdatesController.data.value!.institution,
                ),
                SizedBox(height: Scale.x(30)),
                MortgageCalculatorContainer(
                  accountData: widget.accountData,
                ) // Add calculator widget here
              ],
            ),
          ),
        ),
      );
    });
  }
}
