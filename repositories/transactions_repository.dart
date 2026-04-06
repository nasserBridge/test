import 'dart:async';
import 'package:bridgeapp/src/exceptions/exception_logging.dart';
import 'package:bridgeapp/src/common_widgets/snackbar_service.dart';
import 'package:bridgeapp/src/features/authentication/models/account_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/accounts_controller.dart';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:bridgeapp/src/utils/decryptor.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/link_tokens/update_link_token_controller.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bridgeapp/src/constants/url.dart';

/// Repository for managing bank data.
///
/// This class uses Firebase Realtime Database and server-side API requests to
/// fetch, format, and manage bank data for the authenticated user. It also
/// provides streams for bank data and loading indicators that external classes
/// can subscribe to.
///
/// The class uses GetX for state management and Firebase for database interaction.
class TransactionsRepository extends GetxController {
  static TransactionsRepository get instance =>
      Get.find(); // Singleton instance of the class repository.
  final decryptor = Decryptor();

  RxList<Map<String, dynamic>>? data = RxList<Map<String, dynamic>>([]);
  RxBool isLoading = true.obs;
  RxInt refeshCycles = 0.obs;
  RxBool tryAgain = false.obs;

  /// Undefined subscription reference for listening to Firebase database events.
  StreamSubscription<DatabaseEvent>? _dbRefSubricption;

  ///
  /// Disposes the Firebase subscription to avoid memory leaks.
  ///
  /// Should be called when the subscription reference for listening is no longer needed.
  void disposeSubscription() {
    _dbRefSubricption?.cancel();
  }

  @override
  void onClose() {
    disposeSubscription();
    tryAgain.value = false;
    isLoading.value = true;
    refeshCycles.value = 0;
    data = RxList<Map<String, dynamic>>([]);
    super.onClose();
  }

  void manuallyDispose() {
    if (Get.isRegistered<TransactionsRepository>()) {
      Get.delete<TransactionsRepository>();
    }
  }

  /// Fetches bank data from Firebase and updates the bank data stream.
  ///
  /// The method listens to changes in the user's bank data stored in Firebase.
  ///
  void fetchTransactionData(AccountModel account, bool forceRefresh) async {
    // The user UID of the currently authenticated user.
    final String? userUID =
        AuthenticationRepository.instance.firebaseUser.value?.uid;
    String accountID = account.accountId;

    // Intantiate the firebase database.
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference dbRef = database.ref(
        "/Users/$userUID/transactions/$accountID/data"); // Path were user's balance data is stored

    // Listen to Firebase for any changes in the bank data.
    _dbRefSubricption = dbRef.onValue.listen((DatabaseEvent event) {
      try {
        final decryptor = Decryptor(); // Assuming Decryptor is initialized
        Object? rawTransactionData = decryptor.anyData(event.snapshot.value);

        if (rawTransactionData == null || rawTransactionData is String) {
          // Set transactionData to null if no data is available

          data?.clear();
          isLoading.value = false;

          if (refeshCycles.value < 1) {
            refeshCycles.value++;

            refreshTransactionData(accountID, false);
            SnackbarService.show(
              'Retrieving transactions, update may take a while.',
              isError: false,
            );
          }
        } else if (rawTransactionData is Map<Object?, Object?>) {
          // Ensure 'balance' field is handled
          if (rawTransactionData['balance'] == null ||
              rawTransactionData['balance'] == 'null') {
            rawTransactionData['balance'] = 0.00;
          }

          // if recent balance data matches balance data cached in transction information
          // provide data without refreshing, else refresh data
          if (account.balanceAmount ==
              formatDollars(rawTransactionData['balance'] as double)) {
            // Provide data
            final formattedData = cleanData(account.type, rawTransactionData);

            data?.value = formattedData!;

            isLoading.value = false;
          } else {
            final formattedData = cleanData(account.type, rawTransactionData);
            data?.value = formattedData!;
            isLoading.value = false;
            if (forceRefresh == false) {
              SnackbarService.show(
                'Retrieving latest transactions',
                isError: false,
              );
              refreshTransactionData(accountID, true);
            }
          }
        }
      } catch (error, stackTrace) {
        tryAgain.value = true;
        LogUtil.error('Error processing transaction data stream',
            error: error, stackTrace: stackTrace);
      }
    }, onError: (error, stackTrace) {
      // Try reconnecting if there is an api problem
      tryAgain.value = true;
      LogUtil.error('Error listening to transaction data stream',
          error: error, stackTrace: stackTrace);
    });
  }

  /// This function restarts the database listener, in case of an error
  ///
  void retryData(AccountModel account) {
    isLoading.value = true;
    tryAgain.value = false;
    data = RxList<Map<String, dynamic>>([]);
    refeshCycles.value = 0;
    disposeSubscription(); // Close the previous db listener
    fetchTransactionData(account, true);
  }

  /// This function refreshed the live balance data and transaction data
  ///
  Future<void> refreshData(AccountModel account) async {
    try {
      SnackbarService.show(
          'Refreshing account data. Updates my take a few seconds if any found.',
          isError: false);
      disposeSubscription();
      refeshCycles.value = 0;
      final accController =
          Get.find<AccountsController>(); // Initialize Balance Repo
      // Run both functions concurrently and wait until both are done
      await Future.wait<Future<dynamic>>([
        Future.value(
            accController.reset(account.accountId)), // Ensure it's a Future
        Future.value(refreshTransactionData(
            account.accountId, true)), // Ensure it's a Future
      ]);
      fetchTransactionData(
          account, true); // Re-initalizing listening to the db.
    } catch (error, stackTrace) {
      LogUtil.error('Error refreshing account data',
          error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Checks with the server if there are any existing access tokens for the user.
  ///
  /// Makes an authenticated API request to the server to determine if there are
  /// stored access tokens for the user. Returns `true` if tokens exist, otherwise `false`.
  Future<void> refreshTransactionData(String accountID, bool refresh) async {
    try {
      // Retrieve the user's authentication token.
      String? token = await AuthenticationRepository.instance
          .getIdToken(); // Wait until auth token is created before proceeding.
      String uri = getUrlForUser(); // URI for making API requests to server.
      String apiVersion = getAPIVersion();

      // Create http header.
      final headers = {
        'Content-Type': 'application/json', // Content type
        'Authorization': 'Bearer $token', // Include authentication token.
        'Version': apiVersion,
      };
      final body = {'account_id': accountID, 'initial_request': refresh};

      // Make a post request to the server, wait for response before proceeding.
      final response = await http.post(
          Uri.parse('$uri/transactionData'), // Define api route.
          headers: headers, // Include header.
          body: jsonEncode(body));

      if (response.statusCode == 426) {
        SnackbarService.show(
          'Please update your app to the latest version.',
          isError: true,
        );
      }
      if (jsonDecode(response.body)['unhealthy link token'] != null) {
        final repoUpdateLinkTokenRepo =
            Get.find<UpdateLinkTokenController>(tag: 'accountLevel');
        repoUpdateLinkTokenRepo.updateTokenList(
            [jsonDecode(response.body)['unhealthy link token']], accountID);
      }
    } catch (error, stackTrace) {
      LogUtil.error('refresh request error',
          error: error, stackTrace: stackTrace);
      SnackbarService.show('Error refreshing transactions, try again later.',
          isError: true);
      rethrow;
    }
  }

  /// Cleans and formats bank data or prompts the user to add accounts.
  ///
  /// If no access tokens are found and the data is `null`, the user is prompted
  /// to add a bank account. Otherwise, the raw data is formatted and added to the stream.
  ///
  /// @param data Raw bank data from Firebase.
  /// @param accesstokencheck Boolean indicating whether access tokens exist.
  // cleandata(String balanceType, transactionData) async {
  //   print(transactionData.runtimeType);
  //   // Cast each element (which is a Map<Object?, Object?>) to Map<String, dynamic>
  //   // final accountData = (data as List<dynamic>).map((account) {
  //   //   return (account as Map).map(
  //   //     (key, value) => MapEntry(key.toString(), value),
  //   //   );
  //   // }).toList();

  //   // final masterfile = AccountService().createMasterFile(accountData); // Format data
  //   //_transactionsController.add(masterfile); // Add masterfile to bank data contrller.

  // }

  /// Emits a loading event to notify external classes.
  ///
  /// This method can be used to trigger loading indicators in the UI by sending
  /// a boolean value through the stream.
  ///
  /// @param trueorfalse Boolean indicating whether loading is in progress.
  // void isloadingEvent(bool trueorfalse) {
  //   _isloadingController.add(trueorfalse);
  // }

  /// Sorts through a list of single transactions and matches them by account_id
  /// to their respective account, cleaning and formatting the transactions.
  ///
  /// @param balancetype A string containing the type of balance the account has.
  /// Example format:
  /// --------------
  /// "available" or "current"
  ///
  /// @param transactionData A map containing the account balance, timestamp, and transaction data.
  ///
  /// Example format:
  /// --------------
  /// {
  ///   'balance': 100,
  ///   'time_stamp': '2024-10-09T00:34:46.102870',
  ///   'transactions': [
  ///     {
  ///       'date': '2024-08-21',
  ///       'transaction_id': '12345abcd',
  ///       'name': 'Grocery Store',
  ///       'amount': -150.25,
  ///       'account_id': 'G1eArzQrRKtXwy1Gx1poTX4rVomynbugg3WDm',
  ///       'category': ['Food and Drink', 'Groceries'],
  ///       'location': {'city': 'San Francisco', 'state': 'CA'},
  ///     },
  ///   ]
  /// }
  ///
  /// @return A list of transactions cleaned and formatted.
  ///
  /// Example format:
  /// --------------
  /// [
  ///   {
  ///     'Date': '2024-08-21',
  ///     'Transaction': 'Grocery Store',
  ///     'Type': 'in-store',
  ///     'Amount': '-\$150.25',
  ///     'Balance': '\$1,350.50'
  ///   },
  /// ]
  List<Map<String, dynamic>>? cleanData(
      String balancetype, Map<Object?, Object?> rawTransactionData) {
    try {
      Map<String, dynamic> transactionData = rawTransactionData.map(
        (key, value) => MapEntry(key.toString(), value),
      );

      // Extract transactions
      List<dynamic> transactionsRaw =
          (transactionData['transactions'] as List<dynamic>).map((account) {
        return (account as Map).map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }).toList();

      double balance = transactionData['balance'];
      List<Map<String, dynamic>> transactions = [];

      // Convert transactions into cleaned format
      for (var transactionRaw in transactionsRaw) {
        // Fix negative amounts for depository accounts
        if (balancetype == 'depository') {
          transactionRaw['amount'] = transactionRaw['amount'] * -1;
        }
        transactions.add(cleanTransaction(transactionRaw));
      }

      //  Ensure Dates are in YYYY-MM-DD format before sorting
      for (var transaction in transactions) {
        try {
          String dateString = transaction['Date'];

          // Convert MM/DD/YYYY → YYYY-MM-DD
          List<String> dateParts = dateString.split('/');
          if (dateParts.length == 3) {
            dateString =
                "${dateParts[2]}-${dateParts[0].padLeft(2, '0')}-${dateParts[1].padLeft(2, '0')}";
          }

          transaction['ParsedDate'] = DateTime.parse(dateString);
        } catch (e) {
          transaction['ParsedDate'] = null; // Set to null if parsing fails
        }
      }

      // 🔵 Sort transactions by date (latest first)
      transactions.sort((b, a) => a['ParsedDate'].compareTo(b['ParsedDate']));

      // Remove parsed date before returning
      for (var transaction in transactions) {
        transaction.remove('ParsedDate');
      }

      // Compute balance history
      double balanceMemory = balance;
      int i = 0;

      for (var transaction in transactions) {
        if (transaction == transactions[0]) {
          transaction['Balance'] = balanceMemory;
          transaction['Balance'] = formatDollars(transaction['Balance']);
          i++;
        } else {
          transaction['Balance'] =
              balanceMemory - transactions[i - 1]['Amount'];
          balanceMemory = transaction['Balance'];
          transaction['Balance'] = formatDollars(transaction['Balance']);

          transactions[i - 1]['Amount'] =
              formatDollars(transactions[i - 1]['Amount']);
          i++;
        }
      }

      if (transactions.isNotEmpty) {
        transactions[i - 1]['Amount'] =
            formatDollars(transactions[i - 1]['Amount']);
      }

      return transactions;
    } catch (e) {
      rethrow;
    }
  }

  /// Cleans and returns a map with specifically selected information
  /// from the raw data of a single transaction.
  ///
  /// This function takes in a map of raw transaction data and returns
  /// a cleaned map containing only the relevant information.
  ///
  /// @param transactionRaw A map containing raw data of a single transaction.
  ///
  /// Example format:
  /// --------------
  /// {
  ///   'date': '2024-08-21',
  ///   'transaction_id': '12345abcd',
  ///   'name': 'Grocery Store',
  ///   'amount': -150.25,
  ///   'account_id': 'G1eArzQrRKtXwy1Gx1poTX4rVomynbugg3WDm',
  ///   'category': ['Food and Drink', 'Groceries'],
  ///   'location': {'city': 'San Francisco', 'state': 'CA'},
  ///   'payment_channel': 'in-store',
  /// }
  ///
  /// @return A map with selected transaction information.
  ///
  /// Example return format:
  /// --------------
  /// {
  ///   'Date': '2024-08-21',
  ///   'Transaction': 'Grocery Store',
  ///   'Type': 'in-store',
  ///   'Amount': 150.25,
  ///   'Balance': 0,
  /// }
  Map<String, dynamic> cleanTransaction(Map<String, dynamic> transactionRaw) {
    try {
      // Create an empty map to store the cleaned transaction information
      Map<String, dynamic> transaction = {};

      // Add selected fields to the map
      transaction['Date'] = transactionRaw['date'];
      transaction['Transaction'] = transactionRaw['name'];
      transaction['Type'] = transactionRaw['payment_channel'];
      transaction['Amount'] = transactionRaw['amount'];
      transaction['Balance'] = 0.00; // Default balance to 0.00

      // Return the cleaned transaction map
      return transaction;
    } catch (e) {
      rethrow;
    }
  }

  String formatDollars(double number) {
    try {
      // Convert the number to its absolute value and round to 2 decimal places
      double absoluteNumber = number.abs();

      // Convert the absolute number to a string with a dollar sign and comma separators
      String formattedNumber =
          "\$${absoluteNumber.toStringAsFixed(2).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}";

      // Check if the original number was negative
      bool isNegative = number < 0;

      // Add the negative sign back if the number was originally negative
      if (isNegative) {
        formattedNumber = "-$formattedNumber";
      }

      // Return the formatted number string
      return formattedNumber;
    } catch (e) {
      rethrow;
    }
  }
}
