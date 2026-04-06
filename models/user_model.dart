import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? docID;
  final String firstName;
  final String lastName;
  final String phoneNo;
  final String email;

  final String address1;
  final String address2;
  final String city;
  final String state;
  final String zipcode;
  final Timestamp? createdAt;
  final Timestamp? emailVerifiedAt;
  final Timestamp? firstAccountLinkedAt;

  const UserModel({
    this.docID,
    required this.firstName,
    required this.lastName,
    required this.phoneNo,
    required this.email,
    required this.address1,
    required this.address2,
    required this.city,
    required this.state,
    required this.zipcode,
    this.createdAt,
    this.emailVerifiedAt,
    this.firstAccountLinkedAt,
  });

  /// Convert model → Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'Phone': phoneNo,
      'Email': email,

      'Address1': address1,
      'Address2': address2,
      'City': city,
      'State': state,
      'ZipCode': zipcode,

      // ✅ automatically set at account creation
      'createdAt': FieldValue.serverTimestamp(),

      // these start null
      'emailVerifiedAt': emailVerifiedAt,
      'firstAccountLinkedAt': firstAccountLinkedAt,
    };
  }

  /// Convert Firestore → Model
  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;

    return UserModel(
      docID: document.id,
      firstName: data['FirstName'] ?? '',
      lastName: data['LastName'] ?? '',
      phoneNo: data['Phone'] ?? '',
      email: data['Email'] ?? '',

      address1: data['Address1'] ?? '',
      address2: data['Address2'] ?? '',
      city: data['City'] ?? '',
      state: data['State'] ?? '',
      zipcode: data['ZipCode'] ?? '',

      // read timestamps from Firestore
      createdAt: data['createdAt'] as Timestamp?,
      emailVerifiedAt: data['emailVerifiedAt'] as Timestamp?,
      firstAccountLinkedAt: data['firstAccountLinkedAt'] as Timestamp?,
    );
  }
}
