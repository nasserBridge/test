import 'package:bridgeapp/src/features/authentication/screens/accounts/models/financial_insights_model.dart';
import 'package:bridgeapp/src/utils/formatters.dart';

extension FinancialInsightsDisplay on FinancialInsightsModel {
  String get titleDisplay => text(title);

  String get insightDisplay {
    switch (displayType) {
      case InsightDisplayType.percentage:
        return text('${insight.toStringAsFixed(1)}%');

      case InsightDisplayType.raw:
        return text(insight.toString());

      case InsightDisplayType.currency:
        return text(currency(insight));
    }
  }
}
