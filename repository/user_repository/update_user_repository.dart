import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:bridgeapp/src/repository/authentication_repository/exceptions/firebase_exception_handling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateUserRepository extends GetxController{
  static UpdateUserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _authRepo = Get.put(AuthenticationRepository());

  //Update the user's names, contact, or passwords in firestore
  Future<void> updateUser(dynamic user) async {
    try {
      await _db.collection('Users').doc(_authRepo.firebaseUser.value?.uid).update(user.toJson());
    } on FirebaseException catch (e) {
      // Handle errors, for example, a document that doesn't exist or network issues
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } catch (_) {
      // Handle any other exceptions that might occur
      const ex = ExceptionHandling();
      throw ex;
    }
  }

  Future<void> deleteFirestore() async {
    try {
      debugPrint(_authRepo.firebaseUser.value?.uid);
      await _db.collection('userConsents').doc(_authRepo.firebaseUser.value?.uid).delete();
      await _db.collection('Users').doc(_authRepo.firebaseUser.value?.uid).delete();
    } on FirebaseException catch (e) {
      // Handle errors, for example, a document that doesn't exist or network issues
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } catch (_) {
      // Handle any other exceptions that might occur
      const ex = ExceptionHandling();
      throw ex;
    }
    
  }

}

