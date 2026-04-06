import 'package:bridgeapp/src/utils/formatters.dart';
import '../models/mortgage_model.dart';

extension MortgageDisplay on MortgageModel {
  // -------- Currency --------
  String? get lateFeeDisplay => currency(currentLateFee);
  String? get pastDueAmountDisplay => currency(pastDueAmount);
  String get escrowBalanceDisplay => text(currency(escrowBalance));
  String get nextMonthyPaymentDisplay => text(currency(nextMonthlyPayment));
  String get lastPaymentAmountDisplay => text(currency(lastPaymentAmount));
  String get ytdInterestPaidDisplay => text(currency(ytdInterestPaid));
  String get ytdPrincipalPaidDisplay => text(currency(ytdPrincipalPaid));
  String get ytdPaidDisplay => text(currency(ytdPaid));
  String get originalPrincipalAmountDisplay =>
      text(currency(originationPrincipalAmount));

  // -------- Dates / Text --------
  String get nextPaymentDueDateDisplay => text(nextPaymentDueDate);
  String get lastPaymentDateDisplay => text(lastPaymentDate);
  String get originationDateDisplay => text(originationDate);
  String get maturityDateDisplay => text(maturityDate);
  String get loanTermDisplay => text(loanTerm);
  String get loanTypeDisplay => text(loanTypeDescription);

  // -------- Booleans --------
  String get hasPMIDisplay => boolDisplay(hasPMI);
  String get hasPrepaymentPenaltyDisplay => boolDisplay(hasPrepaymentPenalty);

  // -------- Nested --------

  String get interestRateDisplay =>
      formatInterestRate(interestRateType, interestRatePercentage);
  String get propertyAddressDisplay => formatAddress(propertyAddress);

  String boolDisplay(bool? value) {
    if (value == null) return "NA";
    return value == true ? "Yes" : "No";
  }

  String formatInterestRate(String? type, double? percentage) {
    if (percentage == null && type == null) {
      return 'NA';
    }
    if (percentage == null) return type!;

    // Format percentage with two decimal places
    final formattedPercentage = percentage.toStringAsFixed(2);
    if (type == null) return formattedPercentage;

    return '$formattedPercentage% $type';
  }

  String formatAddress(Map<String, dynamic>? propertyAddress) {
    if (propertyAddress == null) return 'NA';
    final street = propertyAddress['street'] ?? '';
    final city = propertyAddress['city'] ?? '';
    final region = propertyAddress['region'] ?? '';
    final pcode = propertyAddress['postal_code'];

    // Handle double → int if postal code is a whole number
    final postalCode = (pcode is double && pcode % 1 == 0)
        ? pcode.toInt().toString()
        : pcode == null
            ? ''
            : pcode.toString();

    final parts = [
      street,
      city,
      region,
      postalCode.toString(),
    ].where((e) => e.isNotEmpty).toList();

    return parts.isEmpty ? "NA" : parts.join(', ');
  }
}
