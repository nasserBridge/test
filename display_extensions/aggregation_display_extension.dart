import 'package:bridgeapp/src/features/authentication/screens/accounts/models/aggregation_model.dart';
import 'package:bridgeapp/src/utils/formatters.dart';

extension AggregationDisplay on AggregationModel {
  String? get combinedBalanceDisplay => text(currency((combinedBalance)));
}
