import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/accounts_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/profile/manage_accounts_page.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/aggregation_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/account_aggregation/acc_summary.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/widgets/white_container.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/account_aggregation/add_account.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/account_aggregation/banner_summary.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/account_aggregation/loading_container.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/try_again.dart';
import 'package:get/get.dart';

class AccountSummaryWidget extends StatefulWidget {
  const AccountSummaryWidget({super.key});

  @override
  State<AccountSummaryWidget> createState() => _AccountSummaryWidgetState();
}

class _AccountSummaryWidgetState extends State<AccountSummaryWidget> {
  final _accController = Get.find<AccountsController>();
  final _aggController = Get.put(AggregationController());

  @override
  Widget build(BuildContext context) {
    return WhiteContainer(
      padding: EdgeInsets.zero,
      width: double.infinity,
      child: Column(
        children: [
          // // Navy top accent strip
          // Container(
          //   height: 3,
          //   color: AppColors.navy,
          // ),
          Padding(
            padding:
                EdgeInsets.fromLTRB(Scale.x(14), Scale.x(14), Scale.x(14), 0),
            child: Column(
              children: [
                const BannerSummary(title: 'Accounts Summary'),
                Obx(() {
                  return _accController.isLoading.value == true ||
                          (_accController.allBalanceData.isEmpty &&
                              _accController.addAccount.value == false &&
                              _accController.tryAgain.value == false)
                      ? const LoadingContainer()
                      : _accController.addAccount.value == true
                          ? const AddAccount()
                          : _accController.tryAgain.value == true
                              ? TryAgain(
                                  reloadText: 'Try Again',
                                  onRetry: () async =>
                                      _accController.reset(null),
                                  height: 150,
                                )
                              : _accountAggregator();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountAggregator() {
    final groups = _aggController.data.values.toList();

    return Column(
      children: [
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return Column(
              children: [
                SummaryDetails(group: group),
                Container(
                  height: .5,
                  color: AppColors.blue,
                ),
              ],
            );
          },
        ),
        GestureDetector(
          onTap: () => Get.to(() => ManageAccountsPage()),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: Scale.x(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_outlined,
                  color: AppColors.navy,
                  size: Scale.x(16),
                ),
                SizedBox(width: Scale.x(6)),
                Text(
                  'Manage Accounts',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: Scale.x(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
