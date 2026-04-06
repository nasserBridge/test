class HoldingsModel {
  final String? accountID;
  final String? accountName;
  final double? closePrice;
  final String? closePriceAsOf;
  final double? costBasis;
  final String? cusip;
  final bool? fixedIncome;
  final String? industry;
  final String? institutionID;
  final double? institutionPrice;
  final String? institutionPriceAsOf;
  final String? institutionPriceDatetime;
  final String? institutionSecurityID;
  final double? institutionValue;
  final bool? isCashEquivalent;
  final String? isin;
  final String? isoCurrencyCode;
  final String? marketIdentifierCode;
  final String? name;
  final bool? optionContract;
  final String? proxySecurityID;
  final double? quantity;
  final String? sector;
  final String? securityID;
  final String? sedol;
  final String? subtype;
  final String? tickerSymbol;
  final String? type;
  final String? unofficialCurrencyCode;
  final String? updateDatetime;
  final double? vestedQuantity;
  final double? vestedValue;

  HoldingsModel({
    this.accountID,
    this.accountName,
    this.closePrice,
    this.closePriceAsOf,
    this.costBasis,
    this.cusip,
    this.fixedIncome,
    this.industry,
    this.institutionID,
    this.institutionPrice,
    this.institutionPriceAsOf,
    this.institutionPriceDatetime,
    this.institutionSecurityID,
    this.institutionValue,
    this.isCashEquivalent,
    this.isin,
    this.isoCurrencyCode,
    this.marketIdentifierCode,
    this.name,
    this.optionContract,
    this.proxySecurityID,
    this.quantity,
    this.sector,
    this.securityID,
    this.sedol,
    this.subtype,
    this.tickerSymbol,
    this.type,
    this.unofficialCurrencyCode,
    this.updateDatetime,
    this.vestedQuantity,
    this.vestedValue,
  });

  factory HoldingsModel.fromMap(Map<String, dynamic> map) {
    return HoldingsModel(
      accountID: map['account_id'],
      accountName: map['account_name'],
      closePrice: map['close_price'],
      closePriceAsOf: map['close_price_as_of'],
      costBasis: map['cost_basis'],
      cusip: map['cusip'],
      fixedIncome: map['fixed_income'],
      industry: map['industry'],
      institutionID: map['institution_id'],
      institutionPrice: map['institution_price'],
      institutionPriceAsOf: map['institution_price_as_of'],
      institutionPriceDatetime: map['institution_price_datetime'],
      institutionSecurityID: map['institution_security_id'],
      institutionValue: map['institution_value'],
      isCashEquivalent: map['is_cash_equivalent'],
      isin: map['isin'],
      isoCurrencyCode: map['iso_currency_code'],
      marketIdentifierCode: map['market_identifier_code'],
      name: map['name'],
      optionContract: map['option_contract'],
      proxySecurityID: map['proxy_security_id'],
      quantity: map['quantity'],
      sector: map['sector'],
      securityID: map['security_id'],
      sedol: map['sedol'],
      subtype: map['subtype'],
      tickerSymbol: map['ticker_symbol'],
      type: map['type'],
      unofficialCurrencyCode: map['unofficial_currency_code'],
      updateDatetime: map['update_datetime'],
      vestedQuantity: map['vested_quantity'],
      vestedValue: map['vested_value'],
    );
  }
}
