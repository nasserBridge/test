import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/display_extensions/mortgage_display_extension.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/liabilities/liability_detail.dart';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/models/mortgage_model.dart';

class MortgagePaymentDetails extends StatelessWidget {
  final MortgageModel mortgageData;

  const MortgagePaymentDetails({
    super.key,
    required this.mortgageData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        mortgageData.pastDueAmountDisplay != null
            ? LiabilityDetail(
                title: 'Past Due Amount',
                detail: mortgageData.pastDueAmountDisplay!,
                detailTextStyle: TextStyle(
                  color: Colors.red.shade800,
                ),
              )
            : SizedBox.shrink(),
        mortgageData.lateFeeDisplay != null
            ? LiabilityDetail(
                title: 'Late Fee', detail: mortgageData.lateFeeDisplay!)
            : SizedBox.shrink(),
        LiabilityDetail(
            title: 'Next Payment',
            detail: mortgageData.nextMonthyPaymentDisplay),
        LiabilityDetail(
            title: 'Due Date', detail: mortgageData.nextPaymentDueDateDisplay),
        LiabilityDetail(
            title: 'Last Payment (${mortgageData.lastPaymentDateDisplay})',
            detail: mortgageData.lastPaymentAmountDisplay),
        LiabilityDetail(
          title: "YTD Paid",
          detail: mortgageData.ytdPaidDisplay,
          expandedContent: _expandedYtdPaid(),
        ),
        LiabilityDetail(
            title: 'Escrow Balance', detail: mortgageData.escrowBalanceDisplay),
      ],
    );
  }

  Container _expandedYtdPaid() {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Interest",
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  color: const Color.fromARGB(255, 99, 99, 99),
                  fontSize: FontSizes.transDate,
                ),
              ),
              Text(
                mortgageData.ytdInterestPaidDisplay,
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  color: const Color.fromARGB(255, 99, 99, 99),
                  fontSize: FontSizes.transDate,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Principal",
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  color: const Color.fromARGB(255, 99, 99, 99),
                  fontSize: FontSizes.transDate,
                ),
              ),
              Text(
                mortgageData.ytdPrincipalPaidDisplay,
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  color: const Color.fromARGB(255, 99, 99, 99),
                  fontSize: FontSizes.transDate,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
