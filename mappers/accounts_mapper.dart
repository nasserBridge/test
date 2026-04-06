import 'package:bridgeapp/src/features/authentication/models/account_model.dart';
import 'package:bridgeapp/src/utils/normalize.dart';

/// Responsible for transforming raw server data into clean AccountModel objects.
/// This class contains ONLY pure mapping & normalization logic.
/// No HTTP calls, no tokens, no controllers.
class AccountsMapper {
  /// Converts raw JSON/dynamic data into a typed Map of AccountModels.
  /// - Normalizes nested maps
  /// - Fixes missing balances
  /// - Computes balance_amount
  /// - Computes cleaned account_name
  Map<String, AccountModel> toModel(Object data) {
    try {
      final Map<String, AccountModel> parsedData = {};

      // Normalize dynamic data (ensures keys are strings, nested values are maps)
      final rawMap = normalizeMap(data);

      for (final entry in rawMap.entries) {
        final key = entry.key;

        // Ensure the value is a mutable JSON-like map
        final value = Map<String, dynamic>.from(entry.value as Map);

        // Apply transformations,
        value['balances'] = _normalizeBalances(value);
        value['balance_amount'] = _balanceAmount(value);
        value['account_name'] = _accountName(value);

        // Convert into AccountModel
        parsedData[key] = AccountModel.fromJson(value);
      }

      return parsedData;
    } catch (e) {
      rethrow;
    }
  }

  /// Ensures all expected balance keys exist and default to 0.00.
  Map<String, dynamic> _normalizeBalances(Map<String, dynamic> value) {
    final balances = Map<String, dynamic>.from(value['balances'] ?? {});

    balances['available'] = balances['available'] ?? 0.00;
    balances['current'] = balances['current'] ?? 0.00;
    balances['limit'] = balances['limit'] ?? 0.00;

    return balances;
  }

  /// Chooses which balance type determines the primary balance_amount.
  /// Depository accounts use "available", others use "current".
  double _balanceAmount(Map<String, dynamic> value) {
    final type = value['type'];
    final balanceType = (type == 'depository') ? 'available' : 'current';

    return value['balances'][balanceType] ?? 0.00;
  }

  /// Cleans up the account's display name and removes Plaid artifacts.
  String _accountName(Map<String, dynamic> value) {
    String accountName = value['official_name'] ?? value['name'];
    return accountName.replaceAll('Plaid', '').trim();
  }
}
