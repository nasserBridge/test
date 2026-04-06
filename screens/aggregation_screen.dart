import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/accounts_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/pull_to_refresh.dart';
import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/account_aggregation/account_summary_widget.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/account_aggregation/financial_insights_widget.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/reauthenticate_link_token.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/account_aggregation/welcome_sign.dart';
import 'package:bridgeapp/src/subscriptions/subscriptions_widget.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AggregationScreen extends StatefulWidget {
  const AggregationScreen({super.key});

  @override
  State<AggregationScreen> createState() => _AggregationScreenState();
}

class _AggregationScreenState extends State<AggregationScreen> {
  final _controller = Get.find<AccountsController>();

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: PullToRefresh(
        onRefresh: () async => _controller.reset(null),
        child: Column(
          children: [
            // Gradient balance header
            const WelcomeSign(),

            // White card body overlapping the gradient
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: Scale.x(20)),
                        ReauthenticateLinkToken(
                            controllerTag: 'AggregationLevel'),
                        FinancialInsightsWidget(),
                        AccountSummaryWidget(),
                        SizedBox(height: Scale.x(16)),
                        SubscriptionsWidget(),
                        SizedBox(height: Scale.x(100)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
