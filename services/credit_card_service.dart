import 'package:bridgeapp/src/utils/formatters.dart';

class CreditCardService {
  /// Processes the liability data and returns formatted payment and APR details.
  ///
  /// This method orchestrates the processing of payment information and APRs,
  /// logging any errors that occur during execution.
  ///
  /// /// Example Liability Data Format:
  /// ```
  /// {
  ///   "next_payment_due_date": "2024-12-01",
  ///   "minimum_payment_amount": 20.0,
  ///   "last_statement_balance": 1708.77,
  ///   "is_overdue": false,
  ///   "aprs": [
  ///     {
  ///       "apr_percentage": 15.24,
  ///       "apr_type": "balance_transfer_apr",
  ///       "balance_subject_to_apr": 1562.32,
  ///       "interest_charge_amount": 130.22
  ///     },
  ///     ...
  ///   ]
  /// }
  /// ```
  ///
  /// Returns:
  ///   A `Map<String, dynamic>` containing the formatted liability data with keys:
  ///   - `next_payment_due_date`
  ///   - `minimum_payment_amount`
  ///   - `last_statement_balance`
  ///   - `is_overdue`
  ///   - `total_interest`
  ///   - `aprs` (List of formatted APR details)
  Future<Map<String, dynamic>> preparePaymentDetails(
      Object liabilityData) async {
    try {
      // Normalize FIRST to avoid type errors later.
      final normalized = _normalizeMap(liabilityData);
      // Process APRs first to calculate the total interest.
      final aprDetails = await aprs(normalized);

      // Process payment information after interest is calculated.
      final paymentInfo = await creditCardPayment(normalized);

      // Append APR details to the payment information.
      paymentInfo['aprs'] = aprDetails;

      return paymentInfo;
    } catch (e) {
      // Log the error with its stack trace.
      //LogUtil.error('Error running Credit class', error: e, stackTrace: stackTrace);
      rethrow; // Preserve the original error for higher-level handlers.
    }
  }

  // ---------------------------------------------------------------------------
  // NORMALIZATION UTILITIES
  // Converts all keys to String and recursively normalizes nested maps/lists.
  // ---------------------------------------------------------------------------

  /// Normalizes ANY map into `Map<String, dynamic>`
  Map<String, dynamic> _normalizeMap(Object liabilityData) {
    final raw = Map.from(liabilityData as Map);
    return raw.map((key, value) {
      final newKey = key.toString();

      if (value is Map) {
        return MapEntry(newKey, _normalizeMap(value));
      }

      if (value is List) {
        return MapEntry(
          newKey,
          value.map((e) => e is Map ? _normalizeMap(e) : e).toList(),
        );
      }

      return MapEntry(newKey, value);
    });
  }

  /// Processes and formats APR details from the liability data.
  ///
  /// Parameters:
  ///   - `card`: A `Map<String, dynamic>` containing the credit card liability data.
  ///
  /// Returns:
  ///   A `List<Map<String, dynamic>>` where each map represents an APR with keys:
  ///   - `apr_percentage`
  ///   - `apr_type`
  ///   - `balance_subject_to_apr`
  ///   - `interest_charge_amount`
  Future<List<Map<String, dynamic>>> aprs(Map<String, dynamic> card) async {
    try {
      final aprs = card['aprs'] as List<dynamic>?; // Retrieve the list of APRs.
      final result = <Map<String, dynamic>>[];
      if (aprs == null) {
        return result;
      }

      for (final apr in aprs) {
        // Safely create a new Map<String, dynamic> from the original map.
        final aprMap = Map<String, dynamic>.from(apr as Map);
        // Accumulate interest charges.
        // interest += aprMap['interest_charge_amount'] as double;

        // Format each APR field.
        final formattedApr = aprMap.map<String, dynamic>((key, value) {
          final formattedKey = key; // Keep the key as-is.

          // Only format numeric values; leave strings and other types unchanged.
          final formattedValue = (value is double)
              ? formatNumbers(formattedKey, value)
              : (value == null)
                  ? 'NA'
                  : value;

          return MapEntry(formattedKey, formattedValue);
        });

        result.add(formattedApr);
      }

      return result;
    } catch (e) {
      rethrow; // Propagate the error for handling at a higher level.
    }
  }

  /// Extracts and formats credit card payment information for display.
  ///
  /// Parameters:
  ///   - `card`: A `Map<String, dynamic>` containing the raw credit card liability data.
  ///
  /// Returns:
  ///   A `Map<String, dynamic>` with keys:
  ///   - `next_payment_due_date`
  ///   - `minimum_payment_amount`
  ///   - `last_statement_balance`
  ///   - `is_overdue` (Formatted as "OVERDUE" or "On Time")
  ///   - `total_interest` (Formatted string)
  Future<Map<String, dynamic>> creditCardPayment(
      Map<String, dynamic> card) async {
    try {
      return {
        'next_payment_due_date': card['next_payment_due_date'],
        'minimum_payment_amount': formatNumbers(
          'minimum_payment_amount',
          card['minimum_payment_amount'],
        ),
        'last_statement_balance': formatNumbers(
          'last_statement_balance',
          card['last_statement_balance'],
        ),
        'is_overdue': card['is_overdue'],
        // 'total_interest': formatNumbers('total_interest', interest),
      };
    } catch (e) {
      rethrow; // Propagate the error for handling at a higher level.
    }
  }

  /// Formats a numeric value based on its associated key.
  ///
  /// Parameters:
  ///   - `key`: A `String` indicating the type of value (e.g., "percentage").
  ///   - `value`: A `dynamic` value to be formatted.
  ///
  /// Returns:
  ///   A formatted `String` (e.g., "20.00%" or "$20.00").
  String formatNumbers(String key, double? value) {
    try {
      if (key.contains('percentage')) {
        return formatPercentage(value!);
      } else {
        double number = value ?? 0.00;
        return text(currency(number));
      }
    } catch (e) {
      rethrow; // Propagate the error for handling at a higher level.
    }
  }

  /// Formats a numeric value as a percentage string.
  ///
  /// Parameters:
  ///   - `number`: A `num` representing the percentage value.
  ///
  /// Returns:
  ///   A formatted `String` (e.g., "15.24%").
  String formatPercentage(num number) {
    try {
      return '${number.toStringAsFixed(2)}%';
    } catch (e) {
      rethrow; // Propagate the error for handling at a higher level.
    }
  }
}
