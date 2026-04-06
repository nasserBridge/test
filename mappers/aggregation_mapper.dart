import 'package:bridgeapp/src/constants/aggregation_groups.dart';
import 'package:bridgeapp/src/features/authentication/models/account_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/models/aggregation_model.dart';

class AggregationMapper {
  Map<String, AggregationModel> groupAccounts(
    Map<String, AccountModel> allBalanceData,
  ) {
    final Map<String, AggregationModel> tempData = {};

    for (final account in allBalanceData.values) {
      final type = account.type.toLowerCase();
      final subtype = account.subtype?.toLowerCase();
      String? groupKey;

      if (subtype == 'checking') {
        groupKey = AggregationGroups.checkings;
      } else if (type == 'depository' && subtype != 'checking') {
        groupKey = AggregationGroups.savings;
      } else if (type == 'credit') {
        groupKey = AggregationGroups.creditCards;
      } else if (type == 'loan') {
        groupKey = AggregationGroups.loans;
      } else if (type == 'investment') {
        groupKey = AggregationGroups.investments;
      }

      if (groupKey != null) {
        tempData.putIfAbsent(
            groupKey, () => AggregationModel(groupName: groupKey!));
        tempData[groupKey]!.add(account);
      }
    }

    // Preserve original order but only include populated groups
    return {
      for (final group in AggregationGroups.ordered)
        if (tempData.containsKey(group)) group: tempData[group]!
    };
  }
}
