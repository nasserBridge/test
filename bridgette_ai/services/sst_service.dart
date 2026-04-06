import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/controllers/ai_text_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';

/// Service class responsible for handling speech-to-text functionality.
///
/// The [SSTService] encapsulates the speech recognition lifecycle,
/// including:
/// - Initializing and listening for speech input
/// - Capturing transcription results via [_resultCompleter]
/// - Inserting recognized speech into the input field via [AITextController]
/// - Providing cancel/finalize behavior via [convertSTT]
///
/// This service is not a GetX controller — it is used by other
/// controllers (e.g., [SpeechToTextController]) to manage STT logic
/// without polluting their scopes.
class SSTService {
  // ─────────────────────────────────────────────
  // Internal State & Dependencies
  // ─────────────────────────────────────────────

  /// Instance of the speech-to-text engine.
  stt.SpeechToText? _speech;

  /// Completer used to capture and await the final recognition result.
  Completer<SpeechRecognitionResult>? _resultCompleter;

  /// Reference to the AITextController for inserting recognized speech into the editor.
  final AITextController _textController = Get.put(AITextController());

  /// Initializes and starts the speech-to-text (STT) engine.
  ///
  /// This method:
  /// - Sets up a [Completer] to await the final [SpeechRecognitionResult]
  /// - Instantiates the [SpeechToText] engine
  /// - Initializes the engine and begins listening for user voice input
  /// - Enables automatic punctuation via [SpeechListenOptions]
  /// - Completes [_resultCompleter] once a final transcription result is detected
  ///
  /// This is part of the recording flow and is triggered inside [startRecording].
  ///
  /// Throws:
  /// - Any error encountered during initialization or listening setup is rethrown
  ///   to be handled by the calling method (e.g. [startRecording]).
  Future<void> startSTT() async {
    try {
      // Prepare a completer to capture the final transcription result from voice input
      _resultCompleter = Completer<SpeechRecognitionResult>();

      // Create a new instance of the speech-to-text engine
      _speech = stt.SpeechToText();

      // Initialize the engine (checks mic permissions, language models, etc.)
      await _speech?.initialize();

      // Begin listening for speech with auto-punctuation enabled
      await _speech?.listen(
        onResult: (result) {
          // If a final result is returned and hasn't already been captured, complete the future
          if (result.finalResult && !_resultCompleter!.isCompleted) {
            _resultCompleter!.complete(result);
          }
        },
        listenOptions: stt.SpeechListenOptions(autoPunctuation: true),
      );
    } catch (e) {
      // Rethrow the error to allow upstream error logging and fallback
      rethrow;
    }
  }

  /// Finalizes or cancels the speech-to-text transcription process,
  /// and inserts the recognized result into the active input field.
  ///
  /// Parameters:
  /// - [cancel]: If `true`, the transcription is discarded.
  ///   Otherwise, the recognized text is finalized and inserted.
  ///
  /// Behavior:
  /// - If [cancel] is true, calls `cancel()` on the STT engine
  /// - If false, finalizes recognition with `stop()`
  /// - Waits for [_resultCompleter] to resolve, then inserts recognized
  ///   words into the text field at the current cursor or selection
  /// - Automatically handles caret movement and fallback append behavior
  /// - Cleans up the STT engine and result completer via [dispose]
  Future<void> convertSTT(bool cancel) async {
    try {
      // Cancel or finalize the speech recognition session
      if (cancel) {
        await _speech?.cancel(); // Discard result
      } else {
        await _speech?.stop(); // Complete transcription
      }

      // If a valid transcription result is available, insert it into the editor
      if (_resultCompleter != null) {
        final result = await _resultCompleter!.future;

        final text = _textController.editor.text;
        final selection = _textController.editor.selection;

        if (selection.start >= 0 && selection.end >= 0) {
          // Replace selected text with recognized speech
          final newText = text.replaceRange(
            selection.start,
            selection.end,
            result.recognizedWords,
          );

          // Move cursor to the end of the inserted phrase
          final newSelectionIndex =
              selection.start + result.recognizedWords.length;

          _textController.editor.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: newSelectionIndex),
          );
        } else {
          // If no selection, append recognized words to the end of text
          final newText = text + result.recognizedWords;

          _textController.editor.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: newText.length),
          );
        }
      }

      // Clean up STT and related resources
      dispose();
    } catch (e) {
      // Let calling function handle the error
      rethrow;
    }
  }

  /// Cancels and resets any ongoing audio session or UI state.
  Future<void> dispose() async {
    _resultCompleter = null;
    await _speech?.cancel();
    _speech = null;
  }
}
