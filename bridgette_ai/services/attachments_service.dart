import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/models/attachments_model.dart';
import 'dart:convert';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;

/// A service class responsible for handling user file selections and conversions.
///
/// The [AttachmentService] provides utility methods for:
/// - Picking images via camera or gallery using [ImagePicker]
/// - Selecting PDFs using [FilePicker]
/// - Converting files (PDF or image) into base64-encoded [Attachment] objects
///
/// This service supports the AI message attachment workflow by normalizing and
/// compressing files for WebSocket transfer or display.
///
/// Example usage:
/// ```dart
/// final service = AttachmentService();
/// final images = await service.pickImages();
/// final processed = await Future.wait(images.map(service.convertAttachment));
/// ```
class AttachmentService {
  /// Instance of [ImagePicker] used to pick images from camera/gallery.
  final ImagePicker _picker = ImagePicker();

  /// Opens the device camera to capture a single image.
  ///
  /// Returns:
  /// - A list with one [Attachment] if successful.
  /// - An empty list if the user cancels or the capture fails.
  Future<List<Attachment>> pickCameraImage() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return [];
    return [_mapXFileToAttachment(picked)];
  }

  /// Opens the gallery to pick multiple images.
  ///
  /// Returns:
  /// - A list of [Attachment] objects mapped from the selected images.
  /// - An empty list if none are selected or the operation fails.
  Future<List<Attachment>> pickImages() async {
    final picked = await _picker.pickMultiImage();
    return picked.map(_mapXFileToAttachment).toList();
  }

  /// Opens a file picker to select one or more PDF files.
  ///
  /// Returns:
  /// - A list of [Attachment] objects mapped from selected PDFs.
  /// - An empty list if no PDFs are selected or the operation fails.
  Future<List<Attachment>> pickPDFs() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return [];

    return result.files.map((f) {
      final file = File(f.path!);
      return Attachment(
        name: f.name,
        type: f.extension ?? 'pdf',
        file: file,
        fromStorage: false,
      );
    }).toList();
  }

  /// Compresses and base64-encodes the given [Attachment] based on its type.
  ///
  /// Supported file types:
  /// - `pdf`: Encodes the raw byte stream
  /// - `image`: Resizes to 800px width and compresses to 75% JPEG quality
  ///
  /// Returns:
  /// - A new [Attachment] with updated `base64` and `converted` fields.
  /// - The original [Attachment] if decoding fails (e.g., corrupt image).
  Future<Attachment> convertAttachment(Attachment a) async {
    if (a.type == 'pdf') {
      final bytes = await a.file.readAsBytes();
      return a.copyWith(
        base64: base64Encode(bytes),
        converted: true,
      );
    }

    final bytes = await a.file.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) return a; // Skip invalid image

    final resized = img.copyResize(decoded, width: 800);
    final compressed = img.encodeJpg(resized, quality: 75);

    return a.copyWith(
      base64: base64Encode(compressed),
      converted: true,
    );
  }

  /// Internal utility method to convert [XFile] to [Attachment].
  ///
  /// Used when picking images with [ImagePicker].
  Attachment _mapXFileToAttachment(XFile f) {
    return Attachment(
      name: f.name,
      type: f.path.split('.').last.toLowerCase(),
      file: File(f.path),
      fromStorage: false,
    );
  }

  /// Sorts a list of attachments so that PDFs appear before images or other types.
  ///
  /// This method is useful for prioritizing document-like files in UI display
  /// or backend processing.
  List<Attachment> sortAttachmentsByPdfFirst(List<Attachment> attachments) {
    final sorted = List<Attachment>.from(attachments)
      ..sort((a, b) {
        final aIsPdf = a.type.toLowerCase() == 'pdf';
        final bIsPdf = b.type.toLowerCase() == 'pdf';
        if (aIsPdf == bIsPdf) return 0;
        return aIsPdf ? -1 : 1;
      });
    return sorted;
  }
}
