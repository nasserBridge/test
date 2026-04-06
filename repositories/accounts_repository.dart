import 'package:bridgeapp/src/features/authentication/models/account_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/mappers/accounts_mapper.dart';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:firebase_database/firebase_database.dart';

class AccountsRepository {
  final AccountsMapper _mapper = AccountsMapper();

  Stream<DatabaseEvent> dbStream() {
    try {
      // The user UID of the currently authenticated user.
      final String? userUID =
          AuthenticationRepository.instance.firebaseUser.value?.uid;

      // Intantiate the firebase database.
      FirebaseDatabase database = FirebaseDatabase.instance;
      DatabaseReference dbRef = database.ref(
          "/Users/$userUID/balanceData"); // Path were user's balance data is stored

      // Listen to Firebase for any changes in the bank data.
      return dbRef.onValue;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, AccountModel> parseData(Object data) {
    return _mapper.toModel(data);
  }
}
