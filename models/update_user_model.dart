import 'package:cloud_firestore/cloud_firestore.dart';


class UpdateNameUserModel {
  //create a class that requires user info as inputs as strings
  final String firstName;
  final String lastName;
  

  const UpdateNameUserModel({
    required this.firstName,
    required this.lastName,
    });

    // A callable function that converts the datat of UserModel variable to Json format for the firestore database.
    Map<String, dynamic> toJson(){
      return {
        'FirstName': firstName,
        'LastName': lastName,
      };
    }

    
    // A callable function that takes json data fetched firebase to be store in a variable. 
    factory UpdateNameUserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
      final data = document.data()!;
      return UpdateNameUserModel(
        firstName: data['FirstName'],
        lastName: data['LastName'],
      );
    }
}

class UpdateAddressUserModel {
  //create a class that requires user info as inputs as strings
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String zipcode;
  

  const UpdateAddressUserModel({
    required this.address1,
    required this.address2,
    required this.city,
    required this.state,
    required this.zipcode,
    });

    // A callable function that converts the datat of UserModel variable to Json format for the firestore database.
    Map<String, dynamic> toJson(){
      return {
        'Address1' : address1,
        'Address2' : address2,
        'City' : city,
        'State' : state,
        'ZipCode' : zipcode,
      };
    }

    
    // A callable function that takes json data fetched firebase to be store in a variable. 
    factory UpdateAddressUserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
      final data = document.data()!;
      return UpdateAddressUserModel(
        address1: data['Address1'],
        address2: data['Address2'],
        city: data['City'],
        state: data['State'],
        zipcode: data['ZipCode'],
      );
    }
}

class UpdateContactUserModel {
  //create a class that requires user info as inputs as strings
  final String phoneNo;
  final String email;

  const UpdateContactUserModel({
    required this.phoneNo,
    required this.email,
    });

    // A callable function that converts the datat of UserModel variable to Json format for the firestore database.
    Map<String, dynamic> toJson(){
      return {
        'Phone': phoneNo,
        'Email': email,
      };
    }
    
    // A callable function that takes json data fetched firebase to be store in a variable. 
    factory UpdateContactUserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
      final data = document.data()!;
      return UpdateContactUserModel(
        phoneNo: data['Phone'], 
        email: data['Email'],  
      );
    }
}

class UpdatePasswordUserModel {
  //create a class that requires user info as inputs as strings
  final String password;


  const UpdatePasswordUserModel({
    required this.password,
    });

    // A callable function that converts the datat of UserModel variable to Json format for the firestore database.
    Map<String, dynamic> toJson(){
      return {
        'Password': password,
      };
    }

    
    // A callable function that takes json data fetched firebase to be store in a variable. 
    factory UpdatePasswordUserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
      final data = document.data()!;
      return UpdatePasswordUserModel(
        password: data['Password'], 
      );
    }
}



