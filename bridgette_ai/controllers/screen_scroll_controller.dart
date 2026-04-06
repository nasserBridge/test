import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A central controller for managing scroll behavior on the conversation screen.
///
/// The [ScreenScrollController] provides reactive scroll state and utility
/// methods to control and observe scroll position for chat interfaces.
///
/// Responsibilities:
/// - Tracks current scroll offset and maximum extent
/// - Shows or hides a "scroll to bottom" button based on scroll position
/// - Supports both animated and instant scrolling to bottom
/// - Attaches scroll listeners to update UI state reactively
/// - Provides manual lifecycle cleanup via [manuallyDispose]
///
/// Reactive State Fields:
/// - [_scrollOffset]: current vertical scroll position
/// - [_scrollMaxExtent]: scrollable height of the list
/// - [showScrollToBottomIcon]: toggle for bottom-aligned UI elements
///
/// Example Usage:
/// ```dart
/// final scrollCtrl = ScreenScrollController.instance;
/// scrollCtrl.scrollToBottomAnimated();
/// ```
class ScreenScrollController extends GetxController {
  // ────────────────────────────────────────────
  // Singleton Accessor
  // ────────────────────────────────────────────

  /// Singleton instance of [ScreenScrollController].
  static ScreenScrollController get instance => Get.find();

  // ────────────────────────────────────────────
  // Scroll Controller & Listener
  // ────────────────────────────────────────────

  /// Scroll controller used to manage vertical scrolling in conversation UI.
  final ScrollController conversationScrollController = ScrollController();

  /// Internal listener function used to monitor and respond to scroll events.
  late void Function() _scrollListener;

  // ────────────────────────────────────────────
  // Reactive Scroll State
  // ────────────────────────────────────────────

  /// Tracks the current scroll offset in pixels.
  final RxDouble _scrollOffset = 0.0.obs;

  /// Tracks the maximum scroll extent of the content.
  final RxDouble _scrollMaxExtent = 1.0.obs;

  /// Indicates whether the "scroll to bottom" button should be visible.
  final RxBool showScrollToBottomIcon = false.obs;

  // ────────────────────────────────────────────
  // Lifecycle
  // ────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    monitorScroll(); // Begin monitoring scroll state
  }

  @override
  void dispose() {
    // Remove listener and clean up the scroll controller.
    conversationScrollController.removeListener(_scrollListener);
    conversationScrollController.dispose();
    super.dispose();
  }

  /// Manually disposes the controller and unregisters it from GetX.
  ///
  /// Useful when the controller is initialized manually and
  /// needs to be explicitly released.
  void manuallyDispose() {
    dispose();
    if (Get.isRegistered<ScreenScrollController>()) {
      Get.delete<ScreenScrollController>();
    }
  }

  // ────────────────────────────────────────────
  // Scroll Control Methods
  // ────────────────────────────────────────────

  /// Smoothly animates the scroll view to the bottom.
  ///
  /// Useful when sending new messages or receiving AI responses.
  /// [milliseconds] controls the animation speed (default is 300ms).
  void scrollToBottomAnimated({int milliseconds = 300}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!conversationScrollController.hasClients) return;

      final offset = conversationScrollController.position.maxScrollExtent;

      conversationScrollController.animateTo(
        offset,
        duration: Duration(milliseconds: milliseconds),
        curve: Curves.easeOut,
      );
    });
  }

  /// Instantly jumps the scroll view to the bottom without animation.
  ///
  /// Typically used when switching conversations or resetting the view.
  void scrollToBottomInstant() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!conversationScrollController.hasClients) return;

      final offset = conversationScrollController.position.maxScrollExtent;
      conversationScrollController.jumpTo(offset);
    });
  }

  /// Attaches a scroll listener to monitor and update scroll state reactively.
  ///
  /// Updates:
  /// - [_scrollOffset] as the user scrolls
  /// - [_scrollMaxExtent] when new content is added
  /// - [showScrollToBottomIcon] when user scrolls away from the bottom
  void monitorScroll() {
    _scrollListener = () {
      if (!conversationScrollController.hasClients) return;

      final pos = conversationScrollController.position;

      _scrollOffset.value = pos.pixels;
      _scrollMaxExtent.value = pos.maxScrollExtent;

      // User is at bottom if within 50 pixels of the max extent
      final atBottom = pos.pixels >= (pos.maxScrollExtent - 50);
      showScrollToBottomIcon.value = !atBottom;
    };

    conversationScrollController.addListener(_scrollListener);
  }
}
