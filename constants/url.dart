import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
//Contains urls

// Choose to connect locally or the the cloud server

const String apiUrl =
    'https://appserver.bridgebanking.info'; // Google Cloud Production Server

const String devUrl = 'https://development-dot-bridgebanking.wm.r.appspot.com';
//const String devUrl = 'http://192.168.1.98:8080';

String getUrlForUser() {
  final String? userUID =
      AuthenticationRepository.instance.firebaseUser.value?.uid;
  List<String> devUIDs = [
    '9Mypw9E2cWZV9gKCUTaSqBOxCsC3',
    'yVEpkgkdXGh1lxXqe9KtaJvhYyA3',
    'KteYOYBi6pMuyEiKQufY21WiEmo1',
    // 'tUUD1QMBtpTKdcf4YedNOntNd4G3',
    // 'SBNp30PCKuf1erL9IvFh6Jf51z23',
  ];

  if (devUIDs.contains(userUID)) {
    return devUrl;
  }

  // Otherwise, return the production URL
  return apiUrl;
}

String getAPIVersion() {
  String version = '1.00';
  return version;
}

String getBridgetteAPIVersion() {
  String version = '1.00';
  return version;
}

const String aiURL = '${aIDevelopment}chat';
const String aIDevelopment =
    'wss://bridgette-dev-793219956284.europe-west1.run.app/';
const String aiProduction =
    'https://bridgette-793219956284.us-central1.run.app/ ';
