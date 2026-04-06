import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A GetX controller for managing reactive text input state in AI conversations.
///
/// The [AITextController] tracks the content and emptiness state of a
/// [TextEditingController] used in AI messaging UIs. It exposes a reactive
/// [isInputEmpty] flag that allows UI elements (e.g., send buttons) to react
/// to changes in the input field.
///
/// Features:
/// - Maintains a [TextEditingController] for AI prompt input
/// - Observes the input field and updates [isInputEmpty] in real-time
/// - Provides lifecycle cleanup via `dispose()` and [manuallyDispose]
/// - Supports singleton access via `.instance`
///
/// Example usage:
/// ```dart
/// final inputController = AITextController.instance;
/// if (!inputController.isInputEmpty.value) {
///   // Enable send button
/// }
/// ```
class AITextController extends GetxController {
  /// Singleton instance of [AITextController], accessible via `.instance`.
  static AITextController get instance => Get.find();

  // ─────────────────────────────────────────────
  // Reactive State
  // ─────────────────────────────────────────────

  /// Reactive flag indicating whether the input field is empty.
  ///
  /// This can be used to disable or enable UI elements (e.g., send buttons)
  /// based on whether the user has entered any text.
  final RxBool isInputEmpty = true.obs;

  // ─────────────────────────────────────────────
  // Input Management
  // ─────────────────────────────────────────────

  /// Controller for the editable text field used to send AI prompts.
  final TextEditingController editor = TextEditingController();

  /// Internal listener that reacts to text input changes.
  late VoidCallback _inputListener;

  // Scroll controller used to manage vertical scrolling in the Textfield.
  final scroller = ScrollController(); //Scroll for textfield

  // ─────────────────────────────────────────────
  // Lifecycle Hooks
  // ─────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    startListeningToInput(); // Attach input listener on init
  }

  @override
  void dispose() {
    editor.removeListener(_inputListener); // Detach listener before disposal
    editor.dispose(); // Dispose controller to release memory
    scroller.dispose(); // Dispose controller to release memory
    super.dispose();
  }

  /// Manually disposes this controller and unregisters it from GetX.
  ///
  /// Useful when the controller is not managed via GetBuilder or dependency bindings.
  ///
  /// Steps:
  /// - Calls [dispose] to clean up resources
  /// - Removes the controller from memory using `Get.delete()`
  void manuallyDispose() {
    dispose();
    if (Get.isRegistered<AITextController>()) {
      Get.delete<AITextController>();
    }
  }

  // ─────────────────────────────────────────────
  // Input Listener
  // ─────────────────────────────────────────────

  /// Starts listening to changes in the input field and updates [isInputEmpty].
  ///
  /// This attaches a listener to [editor] that checks whether the user
  /// has typed anything and updates [isInputEmpty] reactively.
  ///
  /// Call this once during initialization, or again if reattaching the controller.
  void startListeningToInput() {
    _inputListener = () {
      isInputEmpty.value = editor.text.isEmpty;
    };
    editor.addListener(_inputListener);
  }
}
