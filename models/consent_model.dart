import 'package:cloud_firestore/cloud_firestore.dart';

// Function to save consent preferences for a user
Future<void> saveConsentPreferences(
    String userId,
    bool acceptAllChecked,
    bool acceptAllDataUsage,
    bool marketingCommunications,
    bool dataUse,
    bool anonymizedDataSharing) async {
  try {
    // Get reference to the 'userConsents' collection in Firestore
    final collectionRef = FirebaseFirestore.instance.collection('userConsents');

    // Set document with user ID as the document ID
    await collectionRef.doc(userId).set({
      'acceptAllChecked': acceptAllChecked,
      'acceptAllDataUsage': acceptAllDataUsage,
      'marketingCommunications': marketingCommunications,
      'dataUse': dataUse,
      'anonymizedDataSharing': anonymizedDataSharing,
      'timestamp': FieldValue
          .serverTimestamp(), // Optional: to keep track of when the preferences were saved
    });
    // Print success message if preferences are saved successfully
  } catch (e) {
    // Print error message if there is an error during saving
  }
}
