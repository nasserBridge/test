class AccountModel {
  final String accountId;
  final String institution;
  final AccountBalances balances;
  final double balanceAmount;
  final String? mask;
  final String accountName;
  final String? subtype;
  final String type;

  AccountModel({
    required this.accountId,
    required this.institution,
    required this.balances,
    required this.balanceAmount,
    required this.mask,
    required this.accountName,
    required this.subtype,
    required this.type,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      accountId: json['account_id'],
      institution: json['institution_name'],
      balances: AccountBalances.fromJson(json['balances']),
      balanceAmount: json['balance_amount'],
      mask: json['mask'],
      accountName: json['account_name'],
      subtype: json['subtype'],
      type: json['type'],
    );
  }

  dynamic operator [](String other) {}
}

class AccountBalances {
  final double available;
  final double current;
  final String? isoCurrencyCode;
  final double limit;
  final String? unofficialCurrencyCode;
  final String? lastUpdatedDatetime;

  AccountBalances({
    required this.available,
    required this.current,
    this.isoCurrencyCode,
    required this.limit,
    this.unofficialCurrencyCode,
    this.lastUpdatedDatetime,
  });

  factory AccountBalances.fromJson(Map<String, dynamic> json) {
    return AccountBalances(
      available: json['available'],
      current: json['current'],
      isoCurrencyCode: json['iso_currency_code'],
      limit: json['limit'],
      unofficialCurrencyCode: json['unofficial_currency_code'],
      lastUpdatedDatetime: json['last_updated_datetime'],
    );
  }
}
