import 'dart:async';
import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/features/authentication/models/account_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/repositories/transactions_repository.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/screens/individial_accounts/investments/holdings_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/screens/individial_accounts/investments/holdings_extension_display.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/screens/individial_accounts/investments/holdings_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/screens/individial_accounts/investments/holdings_service.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/screens/individial_accounts/investments/stock_detail_view.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/screens/individial_accounts/investments/stock_logo_service.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/pull_to_refresh.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/header_transaction.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/reauthenticate_link_token.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/try_again.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/widgets/white_container.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HoldingsViewPage extends StatefulWidget {
  final AccountModel accountData;
  const HoldingsViewPage({super.key, required this.accountData});

  @override
  State<HoldingsViewPage> createState() => _HoldingsViewPageState();
}

class _HoldingsViewPageState extends State<HoldingsViewPage> {
  final _repoTransactions = Get.put(TransactionsRepository());
  late HoldingsController _holdingsController;

  @override
  void initState() {
    super.initState();
    // Note: We don't need to sync balance controller here since holdings
    // come from their own controller and we already have accountData

    final accountID = widget.accountData.accountId;
    final tag = 'holdings_$accountID';

    _holdingsController = Get.put(
      HoldingsController(accountData: widget.accountData),
      tag: tag,
      permanent: false,
    );

    // Fetch initial data immediately
    _fetchInitialData();
  }

  void _fetchInitialData() async {
    // Small delay to ensure controller is fully initialized
    await Future.delayed(const Duration(milliseconds: 100));

    // Check if we need to make an API call
    if (_holdingsController.holdingsData.value == null ||
        _holdingsController.holdingsData.value!.isEmpty) {
      HoldingsService().plaidRequest(widget.accountData.accountId, false);
    }
  }

  @override
  void dispose() {
    _holdingsController.manuallyDispose();

    final accountID = widget.accountData.accountId;
    final tag = 'holdings_$accountID';
    if (Get.isRegistered<HoldingsController>(tag: tag)) {
      Get.delete<HoldingsController>(tag: tag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> refreshPull() async {
      _repoTransactions.refreshData(widget.accountData);
      HoldingsService().plaidRequest(widget.accountData.accountId, true);
    }

    return Scaffold(
      backgroundColor: AppColors.customGreen,
      appBar: HeaderTransactions(
        institution: widget.accountData.institution,
        accountID: widget.accountData.accountId,
      ),
      body: PullToRefresh(
        onRefresh: refreshPull,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ReauthenticateLinkToken(controllerTag: 'accountLevel'),
              SizedBox(height: Scale.x(30)),
              _buildPortfolioSummary(),
              SizedBox(height: Scale.x(30)),
              _buildHoldingsList(),
              SizedBox(height: Scale.x(100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioSummary() {
    return Obx(() {
      if (_holdingsController.isLoading.value ||
          (_holdingsController.holdingsData.value == null &&
              !_holdingsController.tryAgain.value)) {
        return Padding(
          padding: EdgeInsets.all(Scale.x(40)),
          child: Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        );
      }

      if (_holdingsController.tryAgain.value) {
        return const SizedBox.shrink();
      }

      final holdingsList = _holdingsController.holdingsData.value ?? [];

      if (holdingsList.isEmpty) return const SizedBox.shrink();

      // Calculate portfolio metrics
      double totalValue = 0;
      double totalCost = 0;

      for (var holding in holdingsList) {
        totalValue += holding.marketValue ?? 0;
        totalCost += holding.costBasis ?? 0;
      }

      final totalGainLoss = totalValue - totalCost;
      final percentageGainLoss =
          totalCost != 0 ? (totalGainLoss / totalCost) * 100 : 0;

      final currencyFormat =
          NumberFormat.currency(symbol: '\$', decimalDigits: 2);
      final percentFormat = NumberFormat('+0.00;-0.00');

      return WhiteContainer(
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, Scale.x(5), 0, Scale.x(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: Scale.x(10), top: Scale.x(10)),
                child: Text(
                  'Portfolio Summary',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w600,
                    letterSpacing: Scale.x(1.5),
                    fontSize: FontSizes.statements,
                  ),
                ),
              ),
              SizedBox(height: Scale.x(12)),
              SizedBox(
                height: Scale.x(60),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    SizedBox(width: Scale.x(5)),
                    _buildMetricBox(
                      title: 'Total Value',
                      value: currencyFormat.format(totalValue),
                      borderColor: const Color.fromARGB(255, 188, 188, 188),
                      textColor: AppColors.navy,
                    ),
                    _buildMetricBox(
                      title: 'Total Cost',
                      value: currencyFormat.format(totalCost),
                      borderColor: const Color.fromARGB(255, 188, 188, 188),
                      textColor: AppColors.mediumGrey,
                    ),
                    _buildMetricBox(
                      title: 'Gain/Loss',
                      value:
                          '${currencyFormat.format(totalGainLoss.abs())} (${percentFormat.format(percentageGainLoss)}%)',
                      borderColor: const Color.fromARGB(255, 188, 188, 188),
                      textColor: totalGainLoss >= 0
                          ? AppColors.green
                          : const Color.fromARGB(255, 142, 1, 1),
                    ),
                    _buildMetricBox(
                      title: 'Positions',
                      value: holdingsList.length.toString(),
                      borderColor: const Color.fromARGB(255, 188, 188, 188),
                      textColor: AppColors.navy,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMetricBox({
    required String title,
    required String value,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Scale.x(5.0)),
      padding:
          EdgeInsets.fromLTRB(Scale.x(17), Scale.x(5), Scale.x(17), Scale.x(5)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Scale.x(12)),
        border: Border.all(color: borderColor, width: Scale.x(1.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Open Sans',
              fontSize: FontSizes.dashboardText,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Open Sans',
              fontSize: FontSizes.dashboardAmount,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsList() {
    return WhiteContainer(
      child: Column(
        children: [
          _buildHoldingsHeader(),
          Obx(() {
            if (_holdingsController.isLoading.value ||
                (_holdingsController.holdingsData.value == null &&
                    !_holdingsController.tryAgain.value)) {
              return Padding(
                padding: EdgeInsets.all(Scale.x(40)),
                child: Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              );
            }

            if (_holdingsController.tryAgain.value) {
              return TryAgain(
                reloadText: 'Try Again',
                onRetry: () async {
                  HoldingsService()
                      .plaidRequest(widget.accountData.accountId, true);
                },
                height: 150,
              );
            }

            final holdingsList = _holdingsController.holdingsData.value ?? [];

            if (holdingsList.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(Scale.x(20)),
                child: Text(
                  'No holdings found',
                  style: TextStyle(
                    color: AppColors.mediumGrey,
                    fontSize: FontSizes.accountGroup,
                  ),
                ),
              );
            }

            return _buildHoldingsListView(holdingsList);
          }),
        ],
      ),
    );
  }

  Widget _buildHoldingsHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          Scale.x(15), Scale.x(18), Scale.x(15), Scale.x(12)),
      decoration: BoxDecoration(
        color: AppColors.customGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Scale.x(20)),
          topRight: Radius.circular(Scale.x(20)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Your Holdings',
            style: TextStyle(
              color: AppColors.navy,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w600,
              letterSpacing: Scale.x(1.5),
              fontSize: FontSizes.statements,
            ),
          ),
          Icon(
            Icons.trending_up,
            color: AppColors.green,
            size: Scale.x(24),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsListView(List<HoldingsModel> holdings) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Scale.x(10)),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: holdings.length,
        itemBuilder: (context, index) {
          final holding = holdings[index];
          return Column(
            children: [
              _buildHoldingItem(holding),
              if (index != holdings.length - 1)
                Container(
                  decoration: const BoxDecoration(color: Colors.blueGrey),
                  child: const SizedBox(
                    height: .5,
                    width: double.infinity,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHoldingItem(HoldingsModel holding) {
    final currencyFormat =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isGain = holding.isGain;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StockDetailView(holding: holding),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: Scale.x(12),
          horizontal: Scale.x(5),
        ),
        child: Row(
          children: [
            // Stock Logo
            FutureBuilder<String?>(
              future: holding.tickerSymbol != null
                  ? StockLogoService.getLogoUrl(holding.tickerSymbol!)
                  : null,
              builder: (context, snapshot) {
                final logoUrl = snapshot.data;
                return Container(
                  width: Scale.x(45),
                  height: Scale.x(45),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Scale.x(10)),
                  ),
                  child: logoUrl != null && logoUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(Scale.x(10)),
                          child: Image.network(
                            logoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildFallbackLogo(holding),
                          ),
                        )
                      : _buildFallbackLogo(holding),
                );
              },
            ),
            SizedBox(width: Scale.x(12)),

            // Stock Name and Ticker
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    holding.name ?? 'Unknown',
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: FontSizes.accountGroup,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Scale.x(2)),
                  Text(
                    holding.tickerSymbol ?? 'N/A',
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: FontSizes.dashboardText,
                      color: AppColors.mediumGrey,
                      letterSpacing: Scale.x(.5),
                    ),
                  ),
                ],
              ),
            ),

            // Value and Gain/Loss
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  holding.marketValue != null
                      ? currencyFormat.format(holding.marketValue!)
                      : 'N/A',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.bold,
                    fontSize: FontSizes.combinedBalance,
                  ),
                ),
                SizedBox(height: Scale.x(2)),
                if (holding.totalGainLoss != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isGain ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isGain
                            ? AppColors.green
                            : const Color.fromARGB(255, 142, 1, 1),
                        size: Scale.x(12),
                      ),
                      SizedBox(width: Scale.x(2)),
                      Text(
                        holding.percentageGainLoss != null
                            ? '${holding.percentageGainLoss!.toStringAsFixed(2)}%'
                            : 'N/A',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize: FontSizes.dashboardText,
                          fontWeight: FontWeight.w600,
                          color: isGain
                              ? AppColors.green
                              : const Color.fromARGB(255, 142, 1, 1),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(width: Scale.x(5)),
            Icon(
              Icons.chevron_right,
              color: AppColors.mediumGrey,
              size: Scale.x(24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackLogo(HoldingsModel holding) {
    return Center(
      child: Text(
        holding.tickerSymbol?.isNotEmpty == true
            ? holding.tickerSymbol![0]
            : '?',
        style: TextStyle(
          fontSize: FontSizes.combinedBalance,
          fontWeight: FontWeight.bold,
          color: AppColors.navy.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
