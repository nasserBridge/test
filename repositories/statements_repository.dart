import 'dart:async';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';

import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';

class StatementRepository extends GetxController {
  static StatementRepository get instance => Get.find();

  final FirebaseDatabase _database =
      FirebaseDatabase.instance; // Firebase instance

  // Store the user UID of the logged in user in a variable.
  final String? _userUID =
      AuthenticationRepository.instance.firebaseUser.value?.uid;

  @override
  void onClose() {
    deleteStatementsPath();
    super.onClose();
  }

  void manuallyDispose() {
    if (Get.isRegistered<StatementRepository>()) {
      Get.delete<StatementRepository>();
    }
  }

  Stream<DatabaseEvent> dbStream() {
    try {
      DatabaseReference dbRef =
          _database.ref("/Users/$_userUID/statement_request");
      return dbRef.onValue;
    } catch (e) {
      rethrow;
    }
  }

  void deleteStatementsPath() async {
    DatabaseReference dbRef1 =
        _database.ref("/Users/$_userUID/statement_request");
    await dbRef1.remove();
  }
}
