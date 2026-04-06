import 'dart:async';
import 'package:bridgeapp/src/exceptions/exception_logging.dart';
import 'package:bridgeapp/src/features/authentication/models/account_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/accounts_controller.dart';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:bridgeapp/src/utils/decryptor.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

/// Aggregates transactions across all linked accounts.
/// Source of truth: AccountsController.allBalanceData
class AggregatedTransactionsController extends GetxController {
  static AggregatedTransactionsController get instance => Get.find();

  final RxList<Map<String, dynamic>> allTransactions =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;

  final AccountsController _accountsController = Get.find<AccountsController>();
  final Decryptor _decryptor = Decryptor();
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    ever(_accountsController.allBalanceData, (_) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 400), _fetchAllTransactions);
    });
    _fetchAllTransactions();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  /// Public manual refresh
  void refreshAllTransactions() {
    _fetchAllTransactions();
  }

  /// Core aggregation method — fetches all accounts in parallel via one-time reads
  void _fetchAllTransactions() async {
    try {
      isLoading.value = true;
      allTransactions.clear();

      final accounts = _accountsController.allBalanceData.values.toList();
      if (accounts.isEmpty) {
        isLoading.value = false;
        return;
      }

      final String? userUID =
          AuthenticationRepository.instance.firebaseUser.value?.uid;
      if (userUID == null) {
        isLoading.value = false;
        return;
      }

      final futures = accounts.map((AccountModel account) async {
        final String accountId = account.accountId;
        final String type = account.type;
        final DatabaseReference dbRef = FirebaseDatabase.instance
            .ref("/Users/$userUID/transactions/$accountId/data");
        try {
          final event = await dbRef.get();
          final decrypted = _decryptor.anyData(event.value);
          if (decrypted is Map<Object?, Object?>) {
            final cleaned = _cleanData(type, decrypted);
            if (cleaned != null && cleaned.isNotEmpty) {
              for (final tx in cleaned) {
                tx['AccountID'] = accountId;
                tx['Institution'] = account.institution;
                tx['AccountType'] = account.type;
              }
              return cleaned;
            }
          }
        } catch (e, stack) {
          LogUtil.error(
            'Transaction processing error for $accountId',
            error: e,
            stackTrace: stack,
          );
        }
        return <Map<String, dynamic>>[];
      }).toList();

      final results = await Future.wait(futures);
      final aggregated = results.expand((list) => list).toList();
      allTransactions.assignAll(_deduplicateAndSort(aggregated));
      isLoading.value = false;
    } catch (e, stackTrace) {
      LogUtil.error(
        'Error fetching aggregated transactions',
        error: e,
        stackTrace: stackTrace,
      );
      isLoading.value = false;
    }
  }

  /// Clean and normalize transaction data
  List<Map<String, dynamic>>? _cleanData(
    String balanceType,
    Map<Object?, Object?> raw,
  ) {
    try {
      final Map<String, dynamic> data =
          raw.map((k, v) => MapEntry(k.toString(), v));

      if (data['transactions'] == null) return null;

      final List<dynamic> rawTransactions =
          List<dynamic>.from(data['transactions']);

      final List<Map<String, dynamic>> cleaned = [];

      for (final txRaw in rawTransactions) {
        final Map<String, dynamic> tx = Map<String, dynamic>.from(txRaw);

        double amount = (tx['amount'] ?? 0).toDouble();

        // Fix depository sign
        if (balanceType == 'available') {
          amount = amount * -1;
        }

        cleaned.add({
          'Date': tx['date'],
          'Transaction': tx['name'],
          'Type': tx['payment_channel'],
          'Amount': amount,
        });
      }

      return cleaned;
    } catch (_) {
      return null;
    }
  }

  /// Remove duplicates + sort newest first
  List<Map<String, dynamic>> _deduplicateAndSort(
    List<Map<String, dynamic>> transactions,
  ) {
    final Map<String, Map<String, dynamic>> unique = {};

    for (final tx in transactions) {
      final key = '${tx['Transaction']}_${tx['Date']}_${tx['Amount']}';
      unique[key] = tx;
    }

    final List<Map<String, dynamic>> list = unique.values.toList();

    list.sort((a, b) {
      try {
        final dateA = DateTime.parse(a['Date']);
        final dateB = DateTime.parse(b['Date']);
        return dateB.compareTo(dateA);
      } catch (_) {
        return 0;
      }
    });

    return list;
  }

  /// Manual cleanup helper
  void manuallyDispose() {
    if (Get.isRegistered<AggregatedTransactionsController>()) {
      Get.delete<AggregatedTransactionsController>();
    }
  }
}
