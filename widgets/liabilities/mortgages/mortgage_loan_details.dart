import 'package:bridgeapp/src/features/authentication/screens/accounts/display_extensions/mortgage_display_extension.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/liabilities/liability_detail.dart';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/models/mortgage_model.dart';

class MortgageLoanDetails extends StatelessWidget {
  final MortgageModel mortgageData;

  const MortgageLoanDetails({
    super.key,
    required this.mortgageData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LiabilityDetail(
            title: 'Origination Principal',
            detail: mortgageData.originalPrincipalAmountDisplay),
        LiabilityDetail(
            title: 'Loan Type', detail: mortgageData.loanTypeDisplay),
        LiabilityDetail(title: 'Term', detail: mortgageData.loanTermDisplay),
        LiabilityDetail(
            title: 'Origination Date',
            detail: mortgageData.originationDateDisplay),
        LiabilityDetail(
            title: 'Maturity Date', detail: mortgageData.maturityDateDisplay),
        LiabilityDetail(title: 'APR', detail: mortgageData.interestRateDisplay),
        LiabilityDetail(title: 'PMI', detail: mortgageData.hasPMIDisplay),
        LiabilityDetail(
            title: 'Prepayment Penalty',
            detail: mortgageData.hasPrepaymentPenaltyDisplay),
        LiabilityDetail(
            title: 'Property Address',
            detail: mortgageData.propertyAddressDisplay)
      ],
    );
  }
}
