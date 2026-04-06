import 'package:cloud_firestore/cloud_firestore.dart';

class AuthModel {
  //create a class that requires user info as inputs and formats it into Json data.
  final String? id;
  final String email;
  final String password;

  const AuthModel({
    this.id,
    required this.email,
    required this.password,
    });

    Map<String, dynamic> toJson(){
      return {
        'Email': email,
        'Password': password,
      };
    }

    factory AuthModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
      final data = document.data()!;
      return AuthModel(
        id: document.id,
        email: data['Email'],  
        password: data['Password'], 
      );
    }
}