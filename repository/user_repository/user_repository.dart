import 'package:bridgeapp/src/features/authentication/models/user_model.dart';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  // Create a StreamController to handle the stream of bank data.
  final _userDataController = StreamController<UserModel>.broadcast();
  // Stream getter to expose the stream to external classes.
  Stream<UserModel> get userDataStream => _userDataController.stream;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _listener;

  final _boolController = StreamController<String>.broadcast();
  // Stream getter to expose the stream to external classes.
  Stream<String> get boolStream => _boolController.stream;

  Rx<UserModel?> userInfo = Rx<UserModel?>(null);

  // Store user in firestore
  Future<void> createUser(UserModel user, String newuserUID) async {
    try {
      Map<String, dynamic> userJson = user.toJson();

      // ensure timestamp is written
      userJson['createdAt'] = FieldValue.serverTimestamp();

      final newdoc = _db.collection('Users').doc(newuserUID);

      await newdoc.set(userJson);
    } catch (error) {
      Get.snackbar(
        "Error",
        "Something went wrong. Try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: .1),
        colorText: Colors.red,
      );
    }
  }

  // Fetch user details from firestore
  void getUserDetails() {
    // Fetch user json data from the Firestore database collection called used "Users".
    final docRef = _db
        .collection("Users")
        .doc(AuthenticationRepository.instance.firebaseUser.value?.uid);
    //Take the json data fetched and stores it in a variable
    _listener = docRef.snapshots().listen(
      (data) {
        if (data.data() != null) {
          _userDataController.add(UserModel.fromSnapshot(data));
          userInfo.value = UserModel.fromSnapshot(data);
        }
      },
      onError: (error) => debugPrint("Listen failed: $error"),
    );
  }

  Stream<UserModel> getUserStream(String uid) {
    return _db
        .collection('Users')
        .doc(uid)
        .snapshots()
        .map((doc) => UserModel.fromSnapshot(doc));
  }

  void disposeListender() {
    _listener?.cancel();
  }

  Stream<QuerySnapshot> userstreams() {
    final Stream<QuerySnapshot> usersStream =
        FirebaseFirestore.instance.collection('users').snapshots();
    return usersStream;
  }

  void boolName(String name) {
    _boolController.add(name);
  }
}
