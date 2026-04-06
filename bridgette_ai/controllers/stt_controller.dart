import 'package:bridgeapp/src/exceptions/exception_logging.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/controllers/ai_text_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/services/sst_service.dart';
import 'package:get/get.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'dart:async';

// A GetX controller for handling voice input via speech-to-text and waveform animation.
///
/// The [SpeechToTextController] manages the lifecycle of audio recording sessions,
/// including:
/// - Initializing the microphone and transcription engine
/// - Starting and stopping voice recording
/// - Animating waveform visuals using `audio_waveforms`
/// - Inserting transcribed text into the [AITextController]'s input field
/// - Exposing reactive fields to reflect UI recording states (active, duration, preload)
///
/// Lifecycle-safe and singleton-based for centralized usage.
class SpeechToTextController extends GetxController {
  /// Singleton instance accessible via `SpeechToTextController.instance`.
  static SpeechToTextController get instance => Get.find();

  // ─────────────────────────────────────────────
  // Reactive Recording State
  // ─────────────────────────────────────────────

  /// Flag indicating whether voice recording is currently in progress.
  final RxBool recordingAudio = false.obs;

  /// Flag used to preload or delay-start UI elements during recording setup.
  final RxBool preLoadRecorder = false.obs;

  /// Tracks the total elapsed time for the current recording session.
  final Rx<Duration> recordingDuration = Rx<Duration>(Duration.zero);

  // ─────────────────────────────────────────────
  // Internal Controllers & Dependencies
  // ─────────────────────────────────────────────

  /// Recorder controller for animating waveform UI elements.
  RecorderController? waveController;

  /// Timer that increments [recordingDuration] every second.
  Timer? _recordingTimer;

  SSTService? _service;

  // ─────────────────────────────────────────────
  // Notes:
  // - Call `toggleRecordingAudio()` to begin/stop voice input
  // - Call `manuallyDispose()` if you need to free memory manually
  // ─────────────────────────────────────────────

  /// Manually disposes this controller and unregisters it from GetX.
  ///
  /// This method is useful when the controller is not bound via typical
  /// GetBuilder lifecycle management and needs to be explicitly cleaned up.
  ///
  /// Steps:
  /// - Calls [dispose] to release internal resources
  /// - Checks if the controller is still registered with GetX
  /// - If so, calls [Get.delete] to remove the instance from memory
  Future<void> manuallyDispose() async {
    await clearAllInputs();
    dispose();
    if (Get.isRegistered<SpeechToTextController>()) {
      Get.delete<SpeechToTextController>();
    }
  }

  /// Cancels and resets any ongoing audio session or UI state.
  Future<void> clearAllInputs() async {
    _service?.dispose();
    _service = null;

    await waveController?.stop(); // Stop waveform animation
    waveController?.dispose();
    waveController = null;

    _recordingTimer?.cancel();
    _recordingTimer = null;
    recordingDuration.value = Duration.zero;
  }

  /// Toggles the audio recording state (start ↔ stop) for the voice input feature.
  ///
  /// This method is responsible for:
  /// - Starting or stopping both speech-to-text (STT) and audio waveform recording
  /// - Toggling reactive indicators: [preLoadRecorder] and [recordingAudio]
  /// - Conditionally cancelling speech input if [cancel] is `true`
  ///
  /// Error Handling:
  /// - Logs any exceptions and resets recorder state and UI indicators
  ///
  /// Usage:
  /// ```dart
  /// await controller.toggleRecordingAudio(); // Toggles recording state
  /// await controller.toggleRecordingAudio(cancel: true); // Cancels input
  /// ```
  Future<void> toggleRecordingAudio({bool cancel = false}) async {
    try {
      // Add short delay to allow any UI animation/state transitions to settle
      await Future.delayed(const Duration(milliseconds: 200));

      // Flip preload indicator (used to trigger UI animation/loading spinner)
      preLoadRecorder.value = !preLoadRecorder.value;

      if (recordingAudio.value == false) {
        // If not currently recording → start STT and waveform tracking
        await startRecording();
      } else {
        // If already recording → stop recording and optionally cancel input
        recordingAudio.value = !recordingAudio.value;
        await stopRecording(cancel: cancel);
      }
    } catch (e, stackTrace) {
      // On error: reset state, clear user input, and log details
      recordingAudio.value = false;
      preLoadRecorder.value = false;
      clearAllInputs();
      LogUtil.error(
        'Error toggling audio recording state',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Initiates audio recording and voice transcription workflow.
  ///
  /// This method is responsible for:
  /// - Starting the speech-to-text (STT) engine to capture voice input
  /// - Activating the visual waveform animation via microphone input
  /// - Launching a timer to track and display recording duration
  /// - Setting the [recordingAudio] observable to `true` to update UI state
  ///
  /// Called internally by [toggleRecordingAudio] when beginning a recording session.
  ///
  /// Throws:
  /// - Any exception encountered during STT or waveform initialization is rethrown
  ///   so that higher-level handlers (e.g., `toggleRecordingAudio`) can manage cleanup.
  Future<void> startRecording() async {
    try {
      // Initialize and start speech-to-text transcription
      _service = SSTService();
      await _service?.startSTT();

      // Begin waveform visualization using live microphone input
      await _startWaveForm();

      // Start a timer to track and display elapsed recording time
      _startRecordingTimer();

      // Mark that recording has started (reactive flag for UI updates)
      recordingAudio.value = !recordingAudio.value;
    } catch (e) {
      // Let upstream method handle the exception and logging
      rethrow;
    }
  }

  /// Initializes and starts waveform-based audio recording.
  ///
  /// This method:
  /// - Instantiates a new [RecorderController] for the waveform visualizer
  /// - Begins recording via the `audio_waveforms` package
  /// - Prepares the waveform to sync with voice input during active recording
  ///
  /// This is typically invoked inside [startRecording] and complements the
  /// speech-to-text engine for visual feedback during recording.
  ///
  /// Throws:
  /// - Any error encountered while initializing or starting the waveform recorder
  ///   is rethrown to be handled by the caller (e.g., [startRecording]).
  Future<void> _startWaveForm() async {
    try {
      // Create a new controller for managing waveform visuals
      waveController = RecorderController();

      // Begin audio recording and waveform animation
      await waveController?.record();
    } catch (e) {
      // Propagate the error to the upstream caller for handling/logging
      rethrow;
    }
  }

  /// Starts a periodic timer to track the duration of the audio recording.
  ///
  /// This method:
  /// - Resets the [recordingDuration] observable to zero
  /// - Initializes [_recordingTimer] to tick every second
  /// - Increments [recordingDuration] by one second on each tick
  /// - Triggers reactive UI updates for live duration feedback
  ///
  /// This is typically called alongside [_startSTT] and [_startWaveForm]
  /// when recording begins.
  ///
  /// Throws:
  /// - Any unexpected error during timer setup is rethrown to the caller.
  void _startRecordingTimer() {
    try {
      // Reset the reactive duration counter
      recordingDuration.value = Duration.zero;

      // Start a repeating timer to update the duration every second
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        recordingDuration.value += const Duration(seconds: 1);
      });
    } catch (e) {
      // Rethrow to allow upstream error handling
      rethrow;
    }
  }

  /// Stops the voice recording session, disposes waveform animation,
  /// and optionally cancels the speech-to-text transcription.
  ///
  /// Parameters:
  /// - [cancel]: If `true`, discards the current speech result;
  ///   otherwise, completes and inserts it into the input field.
  ///
  /// This method:
  /// - Cancels the recording duration timer
  /// - Stops and disposes the waveform animation controller
  /// - Delegates transcription finalization or cancellation to [_service]
  Future<void> stopRecording({bool cancel = false}) async {
    try {
      // Cancel the duration timer and clear the reference
      _recordingTimer?.cancel();
      _recordingTimer = null;
      // Reset the reactive duration counter
      recordingDuration.value = Duration.zero;

      // Stop waveform recording and dispose the waveform controller
      await waveController?.stop();
      waveController?.dispose();
      waveController = null;

      // Delegate conversion or cancellation of speech result to the STT service
      await _service?.convertSTT(cancel);

      // Nullify the service reference to release memory
      _service = null;
    } catch (e) {
      // Propagate error upward for logging or UI error state
      rethrow;
    }
  }
}
