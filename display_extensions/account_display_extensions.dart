import 'package:bridgeapp/src/features/authentication/models/account_model.dart';
import 'package:bridgeapp/src/utils/formatters.dart';

extension AccountDisplay on AccountModel {
  // -------- Identity --------
  String get accountMaskDisplay => mask ?? '—';

  // -------- Aggregate --------
  String get balanceAmountDisplay => text(currency(balanceAmount));

  // -------- Balances --------
  String get availableBalanceDisplay => text(currency(balances.available));

  String get currentBalanceDisplay => text(currency(balances.current));

  String get limitDisplay => text(currency(balances.limit));
}
