import 'package:bridgeapp/src/features/authentication/screens/accounts/screens/individial_accounts/investments/holdings_model.dart';
import 'package:intl/intl.dart';

extension HoldingsDisplay on HoldingsModel {
  // -------- Currency --------
  String get closePriceDisplay => currency(closePrice);
  String get costBasisDisplay => currency(costBasis);
  String get institutionPriceDisplay => currency(institutionPrice);
  String get institutionValueDisplay => currency(institutionValue);
  String get vestedValueDisplay => currency(vestedValue);

  // -------- Computed Values --------
  String get marketValueDisplay => currency(marketValue);
  String get totalGainLossDisplay => currencyWithSign(totalGainLoss);
  String get percentageGainLossDisplay => percentage(percentageGainLoss);
  String get averageCostPerShareDisplay => currency(averageCostPerShare);

  // -------- Numeric --------
  String get quantityDisplay => decimal(quantity, 4);
  String get vestedQuantityDisplay => decimal(vestedQuantity, 4);

  // -------- Text --------
  String get nameDisplay => text(name);
  String get tickerSymbolDisplay => text(tickerSymbol);
  String get sectorDisplay => text(sector);
  String get industryDisplay => text(industry);
  String get typeDisplay => text(type);
  String get subtypeDisplay => text(subtype);

  // -------- Dates --------
  String get closePriceAsOfDisplay => dateString(closePriceAsOf);
  String get institutionPriceAsOfDisplay => text(institutionPriceAsOf);
  String get updateDatetimeDisplay => text(updateDatetime);

  // -------- Booleans --------
  String get isCashEquivalentDisplay => boolDisplay(isCashEquivalent);
  String get fixedIncomeDisplay => boolDisplay(fixedIncome);
  String get optionContractDisplay => boolDisplay(optionContract);

  // -------- Status Indicators --------
  String get gainLossIndicator {
    final gainLoss = totalGainLoss;
    if (gainLoss == null) return '';
    if (gainLoss > 0) return '▲';
    if (gainLoss < 0) return '▼';
    return '−';
  }

  // ============================================================
  // ===================== CORRECTED MATH =======================
  // ============================================================

  /// Market Value
  /// Prefer institutionValue (Plaid's total current value).
  /// Fallback to quantity * price only if necessary.
  double? get marketValue {
    if (institutionValue != null) return institutionValue;

    if (quantity != null && effectivePrice != null) {
      return quantity! * effectivePrice!;
    }

    return null;
  }

  /// Total Cost Basis
  /// Plaid's costBasis is already TOTAL invested amount.
  double? get totalCostBasis => costBasis;

  /// Effective price (closePrice preferred)
  double? get effectivePrice => closePrice ?? institutionPrice;

  /// Average cost per share
  double? get averageCostPerShare {
    if (costBasis != null && quantity != null && quantity! > 0) {
      return costBasis! / quantity!;
    }
    return null;
  }

  /// Total gain/loss (Dollar)
  double? get totalGainLoss {
    final market = marketValue;
    final cost = totalCostBasis;

    if (market != null && cost != null) {
      return market - cost;
    }

    return null;
  }

  /// Percentage gain/loss
  /// Formula:
  /// (Current Value - Cost Basis) / Cost Basis * 100
  double? get percentageGainLoss {
    final market = marketValue;
    final cost = totalCostBasis;

    if (market != null && cost != null && cost != 0) {
      return ((market - cost) / cost) * 100;
    }

    return null;
  }

  /// Gain / Loss flags
  bool get isGain => totalGainLoss != null && totalGainLoss! > 0;
  bool get isLoss => totalGainLoss != null && totalGainLoss! < 0;

  // ============================================================
  // ===================== HELPER METHODS =======================
  // ============================================================

  String currency(double? value) {
    if (value == null) return "NA";
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  String currencyWithSign(double? value) {
    if (value == null) return "NA";
    final formatted = currency(value.abs());
    if (value > 0) return '+$formatted';
    if (value < 0) return '-$formatted';
    return formatted;
  }

  String percentage(double? value) {
    if (value == null) return "NA";
    final formatted = value.toStringAsFixed(2);
    if (value > 0) return '+$formatted%';
    if (value < 0) return '$formatted%';
    return '$formatted%';
  }

  String decimal(double? value, int decimalPlaces) {
    if (value == null) return "NA";
    return value.toStringAsFixed(decimalPlaces);
  }

  String text(String? value) => (value == null || value.isEmpty) ? "NA" : value;

  String boolDisplay(bool? value) {
    if (value == null) return "NA";
    return value ? "Yes" : "No";
  }

  String dateString(String? dateValue) {
    if (dateValue == null || dateValue.isEmpty) return "NA";

    try {
      if (dateValue.contains('/')) {
        final parts = dateValue.split('/');
        if (parts.length == 3) {
          final month = int.parse(parts[0]);
          final day = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final date = DateTime(year, month, day);
          return DateFormat('MMM d, yyyy').format(date);
        }
      }

      final date = DateTime.parse(dateValue);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return dateValue;
    }
  }

  String date(double? timestamp) {
    if (timestamp == null) return "NA";
    try {
      final date =
          DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return "NA";
    }
  }
}
