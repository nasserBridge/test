import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/services/attachments_service.dart';
import 'package:get/get.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/models/attachments_model.dart';

/// A GetX controller responsible for managing file attachments (images, PDFs).
///
/// This controller provides:
/// - File picking from camera, gallery, or storage (PDFs)
/// - Internal conversion and compression logic using [AttachmentService]
/// - Observable state tracking via [attachments] for real-time UI updates
/// - Deletion of individual attachments by index
///
/// Reactive Fields:
/// - [attachments]: List of [Attachment] objects, kept in sync with the UI
///
/// Dependencies:
/// - [AttachmentService] for handling image picking, resizing, compression, and encoding
///
/// Example Usage:
/// ```dart
/// final ctrl = AttachmentsController.instance;
/// await ctrl.pickImages(); // UI will react to new attachments automatically
/// ```
class AttachmentsController extends GetxController {
  /// Singleton instance accessible throughout the app via `AttachmentsController.instance`
  static AttachmentsController get instance => Get.find();

  /// Reactive list of attachments that updates the UI when changed.
  final RxList<Attachment> attachments = <Attachment>[].obs;

  /// Service class for file picking and media conversion.
  final AttachmentService _service = AttachmentService();

  /// Manually disposes this controller and unregisters it from GetX.
  ///
  /// This method is useful when the controller is not bound via typical
  /// GetBuilder lifecycle management and needs to be explicitly cleaned up.
  ///
  /// Steps:
  /// - Calls [dispose] to release internal resources
  /// - Checks if the controller is still registered with GetX
  /// - If so, calls [Get.delete] to remove the instance from memory
  void manuallyDispose() {
    dispose();
    if (Get.isRegistered<AttachmentsController>()) {
      Get.delete<AttachmentsController>();
    }
  }

  /// Pick a photo from the device camera and add it to the attachments list.
  ///
  /// After adding, triggers conversion (e.g., compression and base64 encoding).
  Future<void> pickFromCamera() async {
    final picked = await _service.pickCameraImage(); // Get image from camera
    attachments.addAll(picked); // Add new image(s) to list
    _convertUnconverted(); // Convert new unprocessed attachments
  }

  /// Pick multiple images from the photo gallery and add them to the list.
  ///
  /// Converts the images after picking.
  Future<void> pickImages() async {
    final picked = await _service.pickImages(); // Get images from gallery
    attachments.addAll(picked); // Add them to the observable list
    _convertUnconverted(); // Begin compression and encoding
  }

  /// Pick multiple PDF files from local file storage.
  ///
  /// After picking, triggers encoding of PDF to base64.
  Future<void> pickPDFs() async {
    final picked = await _service.pickPDFs(); // Pick PDFs from storage
    attachments.addAll(picked); // Add to attachments
    _convertUnconverted(); // Process and encode the PDFs
  }

  /// Delete an attachment at a given index.
  ///
  /// Ignores invalid indices to avoid runtime errors.
  void deleteAttachment(int index) {
    if (index >= 0 && index < attachments.length) {
      attachments.removeAt(index); // Remove the item from the list
    }
  }

  /// Convert all unprocessed attachments (images or PDFs) in parallel.
  ///
  /// - Waits 1 second to allow UI state to update
  /// - Skips already converted files
  /// - Uses [AttachmentService.convertAttachment] to perform conversion
  Future<void> _convertUnconverted() async {
    await Future.delayed(
        Duration(milliseconds: 1000)); // Delay for UI animation

    // Convert attachments in parallel (if not already converted)
    final converted = await Future.wait(
      attachments.map((a) async {
        if (a.converted) return a; // Skip already converted
        return await _service
            .convertAttachment(a); // Convert and return updated copy
      }),
    );

    // Replace the observable list with updated, converted versions
    attachments.assignAll(converted);
  }
}
