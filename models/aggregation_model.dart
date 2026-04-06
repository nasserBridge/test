import 'package:bridgeapp/src/features/authentication/models/account_model.dart';

class AggregationModel {
  String groupName;
  double combinedBalance;
  final List<AccountModel> accounts;

  AggregationModel({
    required this.groupName,
    this.combinedBalance = 0.0,
    List<AccountModel>? accounts,
  }) : accounts = accounts ?? [];

  void add(AccountModel account) {
    combinedBalance += account.balanceAmount;
    accounts.add(account);
  }
}
