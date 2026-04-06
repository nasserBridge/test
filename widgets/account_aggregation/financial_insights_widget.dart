import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/accounts_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/financial_insights_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/display_extensions/financial_insights_display_extensions.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/account_aggregation/banner_summary.dart';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/small_loading_container.dart';
import 'package:get/get.dart';
import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/widgets/white_container.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class FinancialInsightsWidget extends StatefulWidget {
  const FinancialInsightsWidget({super.key});

  @override
  State<FinancialInsightsWidget> createState() =>
      _FinancialInsightsWidgetState();
}

class _FinancialInsightsWidgetState extends State<FinancialInsightsWidget> {
  final _accountsController = Get.find<AccountsController>();
  final _fIController = Get.put(FinancialInsightsController());

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _accountsController.isLoading.value == true ||
              (_accountsController.allBalanceData.isEmpty &&
                  _accountsController.addAccount.value == false &&
                  _accountsController.tryAgain.value == false)
          ? SmallLoadingContainer()
          : _accountsController.addAccount.value == true
              ? SizedBox.shrink()
              : _accountsController.tryAgain.value == true
                  ? SizedBox.shrink()
                  : Column(
                      children: [
                        _financialInsightsContainer(),
                        SizedBox(
                          height: Scale.x(30),
                        ),
                      ],
                    );
    });
  }

  Widget _financialInsightsContainer() {
    final scrollController = PageController(viewportFraction: .25);

    return WhiteContainer(
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, Scale.x(5), 0, Scale.x(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: Scale.x(10),
                top: Scale.x(10),
                right: Scale.x(10),
              ),
              child: BannerSummary(title: 'Financial Insights'),
            ),
            SizedBox(height: Scale.x(7)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: Scale.x(10)),
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _fIController.data.values.map((item) {
                    return Container(
                      constraints: BoxConstraints(minWidth: Scale.x(120)),
                      margin: EdgeInsets.symmetric(
                          horizontal: Scale.x(6), vertical: Scale.x(6)),
                      padding: EdgeInsets.symmetric(
                        vertical: Scale.x(10),
                        horizontal: Scale.x(12),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(Scale.x(14)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.titleDisplay,
                            style: TextStyle(
                              fontFamily: 'Open Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navy.withValues(alpha: 0.85),
                            ),
                          ),
                          SizedBox(height: Scale.x(3)),
                          Text(
                            item.insightDisplay,
                            style: TextStyle(
                              fontFamily: 'Open Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: Scale.x(5)),
            Center(
              child: SmoothPageIndicator(
                controller: scrollController,
                count: _fIController.data.length,
                effect: ScrollingDotsEffect(
                  activeDotColor: AppColors.green,
                  //maxVisibleDots: 6,
                  dotColor: AppColors.blue,
                  dotHeight: Scale.x(6),
                  dotWidth: Scale.x(10),
                  spacing: Scale.x(6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
