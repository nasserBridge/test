import 'dart:io';

/// A model class representing a user-selected file attachment.
///
/// This class encapsulates metadata and file reference for attachments such as
/// images or PDFs used in chat or upload flows. It includes:
/// - File name, type, and source
/// - Flags for conversion state (e.g., whether base64 is available)
/// - Optional base64 string representation (for upload or WebSocket transmission)
///
/// This class is immutable—use [copyWith] to create modified copies.
///
/// Example usage:
/// ```dart
/// final newAttachment = attachment.copyWith(base64: encodedString, converted: true);
/// ```
class Attachment {
  /// The display name or filename of the attachment.
  final String name;

  /// The MIME type or file extension (e.g., `"jpg"`, `"pdf"`).
  final String type;

  /// The local file reference on the device.
  final File file;

  /// Indicates whether the file was loaded from persistent storage
  /// (e.g., a saved conversation) or added during the current session.
  final bool fromStorage;

  /// Base64-encoded content of the file, if already converted.
  ///
  /// May be `null` if the file has not yet been processed.
  final String? base64;

  /// Whether this file has been converted to base64 format.
  final bool converted;

  final String? path;

  final bool loaded;

  /// Creates an [Attachment] instance.
  ///
  /// [name], [type], and [file] are required. Optional fields include [base64],
  /// [converted] (default `false`), and [fromStorage] (default `false`).
  Attachment(
      {required this.name,
      required this.type,
      required this.file,
      this.fromStorage = false,
      this.base64,
      this.converted = false,
      this.path,
      this.loaded = true});

  /// Returns a copy of this attachment with updated fields.
  ///
  /// Useful for setting `base64` or toggling `converted` flags immutably.
  Attachment copyWith(
      {String? base64, bool? converted, String? path, bool? loaded}) {
    return Attachment(
      name: name,
      type: type,
      file: file,
      fromStorage: fromStorage,
      base64: base64 ?? this.base64,
      converted: converted ?? this.converted,
      path: path ?? this.path,
      loaded: loaded ?? this.loaded,
    );
  }

  /// Converts this attachment into a serializable map.
  ///
  /// This can be used to store the attachment in a local DB or send over the network.
  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type,
        'file': file,
        'fromStorage': fromStorage,
        'base64': base64,
        'converted': converted,
        'path': path,
        'loaded': loaded
      };
}
