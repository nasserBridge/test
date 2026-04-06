enum InsightDisplayType {
  currency,
  percentage,
  raw,
}

class FinancialInsightsModel {
  final String title;
  final double insight;
  final InsightDisplayType displayType;

  FinancialInsightsModel({
    required this.title,
    required this.insight,
    this.displayType = InsightDisplayType.currency, // default
  });
}
