import 'dart:async';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:firebase_database/firebase_database.dart';

class HoldingsRepo {
  String accountID;
  HoldingsRepo({required this.accountID});

  Stream<DatabaseEvent> dbStream() {
    try {
      // The user UID of the currently authenticated user.
      final String? userUID =
          AuthenticationRepository.instance.firebaseUser.value?.uid;

      // Intantiate the firebase database.
      FirebaseDatabase database = FirebaseDatabase.instance;
      DatabaseReference dbRef = database.ref(
          "/Users/$userUID/investments/$accountID"); // Path were user's balance data is stored

      // Listen to Firebase for any changes in the bank data.
      return dbRef.onValue;
    } catch (e) {
      rethrow;
    }
  }
}
