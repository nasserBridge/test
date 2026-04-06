// import 'package:encrypt/encrypt.dart' as encrypt;

// class Decryptor {
//   // Define the encryption key inside the class
//   final String _encryptionKey =
//       'c0_tP9wgmj_MFnMnTIpuFsZ_98I5dphOD0h0Y76CIM4='; // Replace with your actual key

//   // Method to decrypt a single encrypted string
//   String? decryptString(String encryptedData) {
//     try {
//       // Convert the encryption key from base64
//       final key = encrypt.Key.fromBase64(_encryptionKey);

//       // Fernet does not require a custom IV; it manages it internally
//       final encrypter = encrypt.Encrypter(encrypt.Fernet(key));

//       // Decrypt the data
//       final decrypted = encrypter.decrypt64(encryptedData);

//       // Convert "null" strings to null
//       if (decrypted.toLowerCase() == 'null') {
//         return null;
//       }

//       return decrypted;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Recursive method to decrypt Map<Object?, Object?> and handle nulls
//   Map<Object?, Object?> decryptMap(Map<Object?, Object?> encryptedMap) {
//     try {
//       return encryptedMap.map<Object?, Object?>((key, value) {
//         if (value is String) {
//           // Decrypt the string
//           final decryptedValue = decryptString(value);

//           // Convert "null" strings to null
//           if (decryptedValue.toLowerCase() == 'null') {
//             return MapEntry(key, null);
//           }

//           // Skip conversion for 'mask'
//           if (key == 'mask') {
//             return MapEntry(key, decryptedValue);
//           }

//           // Attempt to parse numbers, otherwise keep as a string
//           final numValue = double.tryParse(decryptedValue);
//           return MapEntry(key, numValue ?? decryptedValue);
//         } else if (value is Map<Object?, Object?>) {
//           // Recursively process nested maps
//           return MapEntry(key, decryptMap(value));
//         } else if (value is List<Object?>) {
//           // Process lists while preserving their type
//           return MapEntry(key, decryptList(value));
//         } else {
//           // Preserve non-encrypted data
//           return MapEntry(key, value);
//         }
//       });
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Recursive method to decrypt List<Object?> and handle nulls
//   List<Object?> decryptList(List<Object?> encryptedList) {
//     try {
//       return encryptedList.map<Object?>((element) {
//         if (element is String) {
//           final decryptedValue = decryptString(element);

//           // Convert "null" strings to null
//           if (decryptedValue.toLowerCase() == 'null') {
//             return null;
//           }

//           // Attempt to parse numbers, otherwise keep as a string
//           final numValue = double.tryParse(decryptedValue);
//           return numValue ?? decryptedValue;
//         } else if (element is Map<Object?, Object?>) {
//           return decryptMap(element);
//         } else if (element is List<Object?>) {
//           return decryptList(element);
//         } else {
//           return element; // Preserve non-encrypted data
//         }
//       }).toList();
//     } catch (e) {
//       rethrow;
//     }
//   }
// }

import 'package:encrypt/encrypt.dart' as encrypt;

class Decryptor {
  // NOTE: Avoid hardcoding keys in production — load from secure storage.
  final String _encryptionKey =
      'c0_tP9wgmj_MFnMnTIpuFsZ_98I5dphOD0h0Y76CIM4='; // Replace with your actual key

  /// One function to "decrypt anything".
  /// Handles String, Map, List, or primitive values automatically.
  Object? anyData(Object? data) {
    if (data == null) return null;

    if (data is String) {
      final decrypted = decryptString(data);

      // If decryptString returned null, keep it as null
      if (decrypted == null) return null;

      // Try to coerce numbers
      final numValue = double.tryParse(decrypted);
      return numValue ?? decrypted;
    }

    if (data is Map<Object?, Object?>) {
      return decryptMap(data);
    }

    if (data is List<Object?>) {
      return decryptList(data);
    }

    return data; // Leave primitives unchanged
  }

  /// Core Fernet decryption function
  /// Converts `"null"` → `null` automatically.
  /// Returns the original string if it is not a valid Fernet token.
  String? decryptString(String encryptedData) {
    try {
      final key = encrypt.Key.fromBase64(_encryptionKey);
      final encrypter = encrypt.Encrypter(encrypt.Fernet(key));

      final decrypted = encrypter.decrypt64(encryptedData);

      // Normalize "null" to actual null
      if (decrypted.toLowerCase() == 'null') {
        return null;
      }
      return decrypted;
    } catch (e) {
      // Not a valid Fernet token — return as-is (unencrypted field)
      return encryptedData;
    }
  }

  /// Recursive Map decryptor
  Map<Object?, Object?> decryptMap(Map<Object?, Object?> encryptedMap) {
    try {
      return encryptedMap.map<Object?, Object?>((key, value) {
        if (value is String) {
          final decryptedValue = decryptString(value);

          // Skip numeric coercion for 'mask'
          if (key == 'mask') {
            return MapEntry(key, decryptedValue);
          }

          // Attempt numeric parsing
          if (decryptedValue == null) {
            return MapEntry(key, null);
          }
          final numValue = double.tryParse(decryptedValue);
          return MapEntry(key, numValue ?? decryptedValue);
        } else if (value is Map<Object?, Object?>) {
          return MapEntry(key, decryptMap(value));
        } else if (value is List<Object?>) {
          return MapEntry(key, decryptList(value));
        } else {
          return MapEntry(key, value);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Recursive List decryptor
  List<Object?> decryptList(List<Object?> encryptedList) {
    try {
      return encryptedList.map<Object?>((element) {
        if (element is String) {
          final decryptedValue = decryptString(element);
          if (decryptedValue == null) return null;

          final numValue = double.tryParse(decryptedValue);
          return numValue ?? decryptedValue;
        } else if (element is Map<Object?, Object?>) {
          return decryptMap(element);
        } else if (element is List<Object?>) {
          return decryptList(element);
        } else {
          return element;
        }
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
