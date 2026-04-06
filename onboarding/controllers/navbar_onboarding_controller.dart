import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A controller that manages the onboarding navbar's page carousel behavior:
/// - Auto-advances a [PageView] every fixed interval
/// - Loops seamlessly back to the first page after the last
/// - Exposes reactive state for the current page index
///
/// # Responsibilities
/// - Hold the [PageController] used by the onboarding [PageView]
/// - Start/stop a periodic timer that advances pages on a cadence
/// - Keep track of the current page via [currentPage] so UI bindings stay in sync
///
/// # Reactive Fields
/// - [currentPage]: the index of the currently visible page in the onboarding flow
///
/// # Lifecycle
/// - [onInit]: starts the auto-scroll
/// - [onClose]: cancels timers and disposes the [PageController]
///
/// ## Example Usage
/// ```dart
/// final ctrl = NavbarOnboardingController.instance;
///
/// PageView(
///   controller: ctrl.pageChanger,
///   onPageChanged: (i) => ctrl.currentPage.value = i,
///   children: [ /* your pages */ ],
/// );
/// ```
///
/// Notes:
/// - The auto-advance uses a modulo operation to wrap at the end.
/// - If the [PageView] hasn't attached yet ([pageChanger.hasClients] is false),
///   the controller updates [currentPage] and waits to animate until attached.
class NavbarOnboardingController extends GetxController {
  /// Singleton-style accessor via GetX service locator.
  static NavbarOnboardingController get instance => Get.find();

  // ────────────────────────────────────────────
  // Public, Reactive State
  // ────────────────────────────────────────────

  /// Controller for the onboarding [PageView].
  final PageController pageChanger = PageController();

  /// Current page index in the onboarding flow.
  final RxInt currentPage = 0.obs;

  // ────────────────────────────────────────────
  // Configuration
  // ────────────────────────────────────────────

  /// Auto-advance cadence. Change this to adjust timing.
  static const Duration _interval = Duration(seconds: 10);

  // ────────────────────────────────────────────
  // Internal Timer State
  // ────────────────────────────────────────────

  /// Periodic timer driving the auto-advance behavior.
  Timer? _timer;

  // ────────────────────────────────────────────
  // Content (used to derive page count and copy)
  // ────────────────────────────────────────────

  /// Static onboarding facts used by the carousel.
  ///
  /// The length of this list implicitly determines the number of
  /// pages we expect to cycle through if bound 1:1 with pages.
  final List<String> factTextList = const [
    'Bridge Supports Over 10,000 Financial Institutions.',
    'Bridge Is Secured by Bank-Grade End-To-End Encryption.',
    'We Never Store Your Bank Credentials On Our Servers.',
    'Bridgette AI Is Committed to Your Privacy & Financial Health.',
  ];

  // ────────────────────────────────────────────
  // GetX Lifecycle
  // ────────────────────────────────────────────

  /// Initializes the controller and starts the auto-scroll timer.
  ///
  /// Starts a periodic timer that will advance pages every [_interval].
  /// If the view is not yet attached to the [PageController], the controller
  /// will keep [currentPage] in sync so that animation begins once attached.
  @override
  void onInit() {
    super.onInit();
    _startAutoScroll();
  }

  /// Cleans up resources when the controller is removed from memory.
  ///
  /// - Cancels the periodic timer if running
  /// - Disposes the [PageController] to free scroll resources
  ///
  /// Important: Cleanup happens **before** calling [super.onClose()]
  /// to ensure all subscriptions/resources are released deterministically.
  @override
  void onClose() {
    _stopAutoScroll();
    pageChanger.dispose();
    super.onClose();
  }

  // ────────────────────────────────────────────
  // Auto-Scroll Control
  // ────────────────────────────────────────────

  /// Starts (or restarts) the periodic auto-scroll timer.
  ///
  /// Behavior:
  /// - Cancels any existing timer to avoid duplicate schedulers.
  /// - Schedules a periodic tick every [_interval].
  /// - Each tick calls [_goToNext] which computes the next index and
  ///   animates to it (wrapping at the end).
  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) => _goToNext());
  }

  /// Stops/pause the auto-scroll timer.
  ///
  /// Use when:
  /// - You want to temporarily suspend auto-advance (e.g., when the user
  ///   is interacting with the carousel or the app goes to background).
  /// - During teardown in [onClose].
  void _stopAutoScroll() {
    _timer?.cancel();
    _timer = null;
  }

  // ────────────────────────────────────────────
  // Page Advancement Logic
  // ────────────────────────────────────────────

  /// Advances the carousel to the next page with seamless looping.
  ///
  /// Algorithm:
  /// - Determine `itemCount` from [factTextList.length] (or your page count).
  /// - Compute `next = (currentPage + 1) % itemCount` to wrap at the end.
  /// - If the [PageView] isn't attached to [pageChanger] yet, just update
  ///   [currentPage] so the UI reflects the next logical index.
  /// - Otherwise, animate to `next` using a smooth easing curve.
  ///
  /// Safety:
  /// - No-ops if `itemCount == 0` (prevents divide-by-zero modulo).
  void _goToNext() {
    final int itemCount = factTextList.length;
    if (itemCount == 0) return;

    final int next = (currentPage.value + 1) % itemCount;

    if (!pageChanger.hasClients) {
      // PageView not attached yet → just update state; animation will occur later.
      currentPage.value = next;
      return;
    }

    pageChanger.animateToPage(
      next,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }
}
