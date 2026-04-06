import 'package:bridgeapp/src/features/authentication/screens/accounts/models/mortgage_model.dart';
import 'package:bridgeapp/src/utils/normalize.dart';

class MortgageService {
  final Object data;

  MortgageService({required this.data});

  MortgageModel toModel() {
    final Map<String, dynamic> raw = normalizeMap(data);
    Map<String, dynamic> normalizedData = {
      "account_id": raw["account_id"],
      "account_number": raw["account_number"],

      // Doubles?
      "current_late_fee": raw["current_late_fee"],
      "past_due_amount": raw["past_due_amount"],
      "escrow_balance": raw["escrow_balance"],
      "last_payment_amount": raw["last_payment_amount"],
      "next_monthly_payment": raw["next_monthly_payment"],
      "origination_principal_amount": raw["origination_principal_amount"],

      'ytd_paid': calculateYTDPaid(raw["ytd_interest_paid"],
          raw["ytd_principal_paid"]), //for showing on display side

      "ytd_interest_paid": raw["ytd_interest_paid"],
      "ytd_principal_paid": raw["ytd_principal_paid"],

      // Strings (leave nullable)
      "last_payment_date": raw["last_payment_date"],
      "loan_term": raw["loan_term"],
      "loan_type_description": raw["loan_type_description"],
      "maturity_date": raw["maturity_date"],
      "next_payment_due_date": raw["next_payment_due_date"],
      "origination_date": raw["origination_date"],

      // Booleans, but instead plaid is providing Strings
      "has_pmi": stringToBool(raw['has_pmi']),
      "has_prepayment_penalty": stringToBool(raw['has_prepayment_penalty']),

      // Nested
      "interest_percentage": raw["interest_rate"]?['percentage'],
      'interest_type': raw["interest_rate"]?['type'],
      "property_address": raw["property_address"], //for showing on display side
    };
    return MortgageModel.fromMap(normalizedData);
  }

  double? calculateYTDPaid(double? interest, double? principal) {
    if (interest == null || principal == null) return null;
    return interest + principal;
  }

  bool? stringToBool(String? boolString) {
    if (boolString == null) return null;
    final bool boolValue = boolString == 'true' ? true : false;
    return boolValue;
  }
}
