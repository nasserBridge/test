import 'dart:convert';
import 'package:bridgeapp/src/constants/url.dart';
import 'package:bridgeapp/src/exceptions/exception_logging.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/controllers/ai_text_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/controllers/attachments_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/controllers/screen_scroll_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/controllers/stt_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/repositories/history_repo.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/services/attachments_service.dart';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:stack_trace/stack_trace.dart';

/// To Do:

/// A central controller for managing AI interactions, WebSocket messaging,
/// and message state for the active conversation.
///
/// The [AIController] is responsible for:
/// - Preparing and sending structured messages to the AI backend via WebSocket
/// - Managing connection lifecycle, retry logic, and error flags
/// - Streaming real-time AI responses and animating them for display
/// - Holding and updating the state of the current user message and AI reply
/// - Managing attachments, scroll behavior, and message batching
///
/// This controller is initialized as a singleton and shared throughout the app
/// using `AIController.instance`.
///
/// Dependencies:
/// - [AuthenticationRepository] to retrieve the Firebase user token
/// - [ScreenScrollController] for managing scroll behavior
/// - [AITextController] for accessing text input
///
/// Reactive State Fields:
/// - [currentMessage]: Holds the user's in-progress message with optional attachments
/// - [conversationId]: Unique identifier for the current conversation thread
/// - [fullAIResponse]: The full unanimated response text from the AI
/// - [visibleAIResponse]: The animated/typed-out text for UI display
/// - [aiResponseComplete], [streamingResponse], [webSocketError]:
///   Flags used to track message state and connection status
/// - [activeMessages]: Ordered list of messages sent and received in the current thread
///
/// Example Usage:
/// ```dart
/// final ai = AIController.instance;
/// await ai.sendMessage(); // Triggers the send + animation logic
/// ```
class AIController extends GetxController {
  /// Singleton instance of the controller, accessible via `AIController.instance`.
  static AIController get instance => Get.find();

  // ────────────────────────────────────────────
  // Dependencies
  // ────────────────────────────────────────────

  /// Reference to the authentication repository to retrieve the user's token.
  final _authRepo = Get.put(AuthenticationRepository());

  /// Reference to the SST controllers.
  final _sttController = Get.put(SpeechToTextController());

  /// Reference to the screen scroll controller for animated scroll behavior.
  final _scrollController = Get.put(ScreenScrollController());

  /// Reference to the text controller that captures the text typed or from TTS
  final _textController = Get.put(AITextController());

  /// Reference to the attachments controller for pulling images and pdfs
  final _attachmentsController = Get.put(AttachmentsController());

  /// Convenience getter for the Firebase user UID.
  String? get _userUID => _authRepo.firebaseUser.value?.uid;

  // ────────────────────────────────────────────
  // Message State
  // ────────────────────────────────────────────

  /// Observable map holding the current user message before it's sent.
  final RxMap<String, dynamic> currentMessage = <String, dynamic>{}.obs;

  /// Observable ID of the active conversation thread, assigned after session handshake.
  final RxnString conversationId = RxnString();

  /// List of messages exchanged in the currently active thread.
  RxList<Map<String, dynamic>> activeMessages = <Map<String, dynamic>>[].obs;

  /// The complete AI response as received from the WebSocket stream.
  final RxString fullAIResponse = ''.obs;

  /// The animated portion of the AI response shown to the user, updated via typing effect.
  final RxString visibleAIResponse = ''.obs;

  /// Flag indicating whether the full AI response has finished streaming.
  final RxBool aiResponseComplete = false.obs;

  /// Flag indicating whether a streaming session is currently active.
  final RxBool streamingResponse = false.obs;

  /// Indicates whether a WebSocket connection error has occurred.
  final RxBool webSocketError = false.obs;

  // ────────────────────────────────────────────
  // Internal WebSocket & Timer State
  // ────────────────────────────────────────────

  /// Active WebSocket channel used to send and receive messages from the AI server.
  WebSocketChannel? _channel;

  /// Subscription to the WebSocket stream, used for receiving AI tokens and session IDs.
  StreamSubscription? _channelSubscription;

  /// Timer used to animate the AI's typing behavior character-by-character.
  Timer? _typingTimer;

  /// Index for tracking current character in typing animation.
  int _charIndex = 0;

  /// JSON payload used for sending structured data to the AI backend.
  final RxMap<String, dynamic> _jsonMessage = <String, dynamic>{}.obs;

  @override
  void dispose() {
    super.dispose();
    _channelSubscription?.cancel(); // Cancel the WebSocket subscription
    _channel?.sink.close(1000); //Cancel the WebSocket connection
  }

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
    if (Get.isRegistered<AIController>()) {
      Get.delete<AIController>();
    }
  }

  /// Sends a new user message to the AI assistant via WebSocket.
  ///
  /// This method orchestrates the full message-sending workflow:
  /// - Validates input (ensures user typed something or attached a file)
  /// - Persists the previous AI/user exchange into [activeMessages]
  /// - Builds the new message payload from input and attachments
  /// - Prepares and formats the data for WebSocket transmission
  /// - Sends the message to the server
  ///
  /// Uses `Chain.capture()` to improve error stack traces for debugging.
  ///
  /// If an exception occurs, it is caught and logged with [LogUtil].
  Future<void> sendMessage() async {
    Chain.capture(() async {
      // Check that either text input or attachments exist and user is logged in
      if ((_textController.isInputEmpty.value == false ||
              _attachmentsController.attachments.isNotEmpty) &&
          _userUID != null) {
        // Step 1: Persist the previous exchange (last user question and AI response)
        await _addLastUserQueryAndResponseToActiveMessages();

        // Step 2: Build the new user message from input text and attachments
        _addMessageToCurrentMessage();

        // Step 3: Format the message for the AI backend (auth, version, media, etc.)
        await _prepareJsonMessage();

        // Step 4: Send the message to the WebSocket server
        await _sendMessagetoServer();

        // add  1 to the count
        HistoryRepository.instance.newConversationCount
            .value++; // Increment the new conversation count
      }
    }, onError: (error, stackTrace) {
      // Log errors using structured logging with source and stack trace
      LogUtil.error(
        'Error sending message or streaming ai response',
        error: error,
        stackTrace: stackTrace,
      );
    });
  }

  /// Attempts to retry sending the current message payload to the AI backend.
  ///
  /// This method is useful when a previous attempt failed (e.g., due to an expired token
  /// or dropped WebSocket connection). It performs the following:
  /// - Refreshes the user's Firebase ID token and updates it in [_jsonMessage]
  /// - Attempts to re-send the message via [_sendMessagetoServer]
  /// - Clears both [fullAIResponse] and [visibleAIResponse] in preparation for a new response
  /// - Resets the typing animation state
  ///
  /// Uses `Chain.capture` from the `stack_trace` package to ensure better error stack traces.
  ///
  /// If an error occurs during this retry attempt, it is caught and logged via [LogUtil].
  Future<void> retrySendMessage() async {
    Chain.capture(() async {
      // Step 1: Refresh the Firebase ID token
      String? token = await AuthenticationRepository.instance.getIdToken();

      // Step 2: Update the message payload with the new token
      _jsonMessage["auth"]["token"] = "Bearer $token";

      // Step 3: Attempt to resend the message via WebSocket
      await _sendMessagetoServer();

      // Step 4: Clear any existing AI response text
      fullAIResponse.value = ''; // Clear the full (raw) AI response
      visibleAIResponse.value = ''; // Clear the currently displayed response

      // Step 5: Reset typing animation state
      _charIndex = 0;
      _typingTimer?.cancel();
      _typingTimer = null;
    }, onError: (error, stackTrace) {
      // Log the retry failure using centralized logging
      LogUtil.error(
        'Error retrying to send message or streaming AI response',
        error: error,
        stackTrace: stackTrace,
      );
    });
  }

  /// Gracefully stops the current AI response streaming session.
  ///
  /// This method is typically called when:
  /// - The user cancels the request
  /// - The app navigates away
  /// - An error occurs mid-stream
  ///
  /// It performs the following cleanup actions:
  /// - Sets [streamingResponse] to `false` to stop any loading indicators
  /// - Marks the AI response as complete
  /// - Cancels the WebSocket subscription and closes the connection
  /// - Resets the typing animation index and timer
  void stopStreaming() {
    streamingResponse.value = false; // Stop UI loading spinner or animation
    aiResponseComplete.value = true; // Mark AI response as finished

    _channelSubscription?.cancel(); // Cancel active WebSocket stream listener
    _channel?.sink.close(1000); // Close WebSocket connection gracefully

    _charIndex = 0; // Reset typing animation character index
    _typingTimer?.cancel(); // Cancel any ongoing timer for animated typing
    _typingTimer = null; // Clear the timer reference
  }

  /// Adds the user's most recent query and the AI's latest response
  /// to the active conversation message log, if present.
  ///
  /// This method performs the following:
  /// - If a user query exists in [currentMessage], it appends it to [activeMessages]
  ///   and clears [currentMessage].
  /// - If an AI response exists in [fullAIResponse] and it has fully streamed
  ///   ([aiResponseComplete] is `true`), it appends a structured AI message to
  ///   [activeMessages] and resets the AI response state using [resetAIResponse].
  ///
  /// This method is typically called after the AI finishes responding to the user's input.
  ///
  /// Throws:
  /// - Any unexpected exceptions are rethrown to be handled by the caller.
  Future<void> _addLastUserQueryAndResponseToActiveMessages() async {
    try {
      // Only log the user's message if one exists
      if (currentMessage.isNotEmpty) {
        activeMessages.add(Map<String, dynamic>.from(currentMessage));
        currentMessage.clear(); // Clear after logging
      }

      // Only log the AI's response if one exists and it's complete
      if (fullAIResponse.value.isNotEmpty && aiResponseComplete.value) {
        final aiMessage = {
          'type': 'AIMessage',
          'text': fullAIResponse.value,
          'timestamp': FieldValue.serverTimestamp(),
        };

        activeMessages.add(aiMessage);
        _resetAIResponse(); // Reset state for next AI interaction
      }
    } catch (e) {
      currentMessage.clear(); // Clear after logging
      _resetAIResponse(); // Reset state for next AI interaction
      // Let the error bubble up for higher-level error handling
      rethrow;
    }
  }

  /// Resets all AI response state used during streaming and display.
  ///
  /// This method performs a full reset of all variables involved in
  /// streaming and animating the AI's response, including:
  /// - [fullAIResponse]: The raw complete AI response
  /// - [visibleAIResponse]: The currently visible animated portion
  /// - [_charIndex]: Internal index used for character-by-character animation
  /// - [_typingTimer]: Timer driving the typing effect
  /// - [streamingResponse]: Flag indicating if a response is actively being streamed
  /// - [aiResponseComplete]: Flag indicating if the AI's response is fully rendered
  ///
  /// This is typically called after logging the AI message or
  /// when preparing for a new AI interaction.
  void _resetAIResponse() {
    fullAIResponse.value = ''; // Clear full response text
    visibleAIResponse.value = ''; // Clear visible/animated text
    _charIndex = 0; // Reset typing animation index
    _typingTimer?.cancel(); // Cancel any ongoing timer
    _typingTimer = null; // Nullify timer reference
    streamingResponse.value = false; // Reset streaming flag
    aiResponseComplete.value = false; // Mark response as incomplete
  }

  /// Constructs and appends the current user message—including text and any attachments—
  /// to the [currentMessage] map. This prepares the message for logging or streaming.
  ///
  /// This method performs the following:
  /// - Sorts any attached files so that PDFs appear before images
  /// - Constructs a message map with:
  ///   - `type`: fixed as `'HumanMessage'`
  ///   - `text`: pulled from [_navBarController.inputController], or `null` if empty
  ///   - `timestamp`: a Firestore server-side timestamp placeholder
  ///   - `attachments`: a deep copy of the sorted attachments list
  /// - Merges the new message into [currentMessage] for use in subsequent logic
  /// - Triggers scroll to bottom to ensure the new message is in view
  ///
  /// If any error occurs (e.g. during map mutation or type issues),
  /// [currentMessage] is cleared to prevent stale or partial data from persisting.
  ///
  /// Throws:
  /// - Any unexpected error is rethrown after cleaning up local state.
  void _addMessageToCurrentMessage() {
    try {
      // Sort attachments so that PDFs appear before images
      final sortedAttachments = AttachmentService()
          .sortAttachmentsByPdfFirst(_attachmentsController.attachments);

      // Construct the user message
      final message = {
        'type': 'HumanMessage',
        'text': _textController.editor.text.isNotEmpty
            ? _textController.editor.text
            : null,
        'timestamp': FieldValue.serverTimestamp(),
        'attachments': sortedAttachments.map((e) => e.toMap()).toList(),
      };

      // Merge the new message into the current message state
      currentMessage.addAll(message);

      // Ensure the most recent message is visible
      _scrollController.scrollToBottomAnimated();
    } catch (e) {
      // Clear the current message to avoid carrying invalid or partial data
      currentMessage.clear();
      rethrow;
    }
  }

  /// Prepares the `_jsonMessage` payload to be sent to the AI WebSocket backend.
  ///
  /// This method performs the following:
  /// - Retrieves the user's Firebase ID token for authentication
  /// - Fetches the current API version from [getBridgetteAPIVersion()]
  /// - Processes the current [_navBarController.attachments] list:
  ///   - Filters only those marked as `"converted" == true`
  ///   - Separates attachments into `imageInput` and `pdfInput` lists
  ///   - Collects only base64-encoded content
  /// - Builds a structured JSON object containing:
  ///   - `auth`: authentication header with token and version
  ///   - `userPrompt`: text input from the [_navBarController.inputController]
  ///   - `conversationId`: current session ID
  ///   - `imageInput` and `pdfInput`: base64-encoded media lists
  ///   - `timeTravel`: reserved for future extension
  /// - Merges the result into [_jsonMessage]
  /// - Clears the [_navBarController.inputController] and [_navBarController.attachments] to reset state
  ///
  /// Notes:
  /// - Only attachments with `converted == true` and valid base64 data are included.
  /// - Assumes all non-PDF attachments are treated as images.
  ///
  /// This method should be called before sending a message via WebSocket.
  Future<void> _prepareJsonMessage() async {
    // Retrieve Firebase ID token for authentication
    String? token = await AuthenticationRepository.instance.getIdToken();

    // Retrieve API version
    String apiVersion = getBridgetteAPIVersion();

    // Initialize input lists for base64-encoded attachments
    List<String> imageInput = [];
    List<String> pdfInput = [];

    for (final attachment in _attachmentsController.attachments) {
      if (!attachment.converted) continue;

      final base64 = attachment.base64;
      final type = attachment.type;

      if (base64 != null) {
        if (type == 'pdf') {
          pdfInput.add(base64);
        } else {
          imageInput.add(base64);
        }
      }
    }

    // Build the full message payload
    final message = {
      "auth": {
        "token": "Bearer $token",
        "version": apiVersion,
      },
      "userPrompt": _textController.editor.text.isNotEmpty
          ? _textController.editor.text
          : null,
      "conversationId": conversationId.value,
      "imageInput": imageInput,
      "pdfInput": pdfInput,
      "timeTravel": {}, // Placeholder for future state/time injection
    };

    // Merge into global outgoing message store
    _jsonMessage.addAll(message);

    // Clear UI inputs and attachment cache
    _textController.editor.clear();
    _attachmentsController.attachments.clear();
  }

  /// Sends the prepared user message to the AI backend via WebSocket and manages UI state.
  ///
  /// This method performs the following:
  /// - Verifies that [_jsonMessage] is populated before proceeding
  /// - Resets [webSocketError] and sets [streamingResponse] to `true`
  /// - Establishes a WebSocket connection via [_connectWebSocket]
  /// - Starts listening for incoming responses via [_listenToWebSocket]
  /// - Sends the message payload through [_channel.sink.add]
  ///
  /// If any error occurs during the connection or transmission phase:
  /// - [webSocketError] is set to `true`
  /// - [streamingResponse] is set to `false`
  /// - [_channelSubscription] is canceled to stop listening
  /// - [_channel] is closed gracefully with a status code `1000`
  /// - The error is rethrown to be handled by the caller
  ///
  /// Notes:
  /// - This method should be called only after [_prepareJsonMessage] has been executed
  /// - Only one message is sent per invocation; the listener handles multi-part responses (e.g., tokens)
  ///
  /// Throws:
  /// - Any exception during connection, listening, or sending will be propagated upward
  Future<void> _sendMessagetoServer() async {
    try {
      if (_jsonMessage.isNotEmpty) {
        webSocketError.value = false; // Reset connection error flag
        streamingResponse.value = true; // Indicate AI response is in progress

        await _connectWebSocket(); // Establish connection
        await _listenToWebSocket(); // Begin listening for streamed response
        _channel!.sink.add(jsonEncode(_jsonMessage)); // Send message to server
      }
    } catch (e) {
      webSocketError.value = true; // Flag error to UI
      streamingResponse.value = false; // Reset streaming state

      _channelSubscription?.cancel(); // Cancel stream listener, if any
      _channel?.sink.close(1000); // Close WebSocket connection gracefully

      rethrow; // Let the caller handle/log the error
    }
  }

  /// Establishes a WebSocket connection to the AI backend using the configured [aiURL].
  ///
  /// This method performs the following:
  /// - Parses the AI WebSocket URL
  /// - Initializes a new [WebSocketChannel] connection
  /// - Waits for the connection to become ready via `.ready`
  ///
  /// Important:
  /// - This method does **not** handle UI state (e.g., error flags or loading indicators);
  ///   those responsibilities are delegated to the caller (e.g., [_sendMessagetoServer]).
  ///
  /// Throws:
  /// - Any exception that occurs during connection setup (e.g., malformed URL,
  ///   unreachable server, connection timeout) will be rethrown for the caller to handle.
  Future<void> _connectWebSocket() async {
    try {
      final wsUrl = aiURL; // Construct WebSocket URL
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      await _channel!.ready; // Wait until the connection is established
    } catch (e) {
      rethrow; // Propagate connection errors to the caller
    }
  }

  /// Listens to messages from the WebSocket stream and routes them to the appropriate handlers.
  ///
  /// This method does the following:
  /// - Listens to the WebSocket stream via [_channel]
  /// - Parses each incoming message as JSON
  /// - Responds to different message types:
  ///   - `'ai_token'`: Appends partial content to [fullAIResponse] and starts the typing animation
  ///   - `'new_thread'`: Sets the [conversationId] if it's not already assigned
  ///   - `'ai_response_complete'`: Marks the AI response as finished, cancels the stream,
  ///     and closes the WebSocket connection
  ///   - `'session_connected'`: Sets the session ID for the current conversation
  ///
  /// If an error occurs during the setup or listening process, it is rethrown
  /// to be handled by the calling method.
  ///
  /// Throws:
  /// - Any stream-related exception will be rethrown for upstream handling.
  Future<void> _listenToWebSocket() async {
    try {
      _channelSubscription = _channel!.stream.listen((message) {
        // Decode the incoming JSON-formatted WebSocket message
        final data = jsonDecode(message);

        // Handle the message based on its type
        switch (data['type']) {
          case 'ai_token':
            // Append the AI token to the full response buffer
            fullAIResponse.value += data['content'];

            // Start the animated typing effect on new content
            _startTypingAnimation();
            break;

          case 'new_thread':
            // Assign conversation ID only if it hasn't been set yet
            if (conversationId.value == null && data['content'] != null) {
              conversationId.value = data['content'];
            }
            break; // Ensure no fallthrough to next case

          case 'ai_response_complete':
            // Mark that the AI response has been fully received
            aiResponseComplete.value = true;

            // Cancel the stream listener to stop listening for more messages
            _channelSubscription?.cancel();

            // Close the WebSocket connection with status code 1000 (normal closure)
            _channel?.sink.close(1000);
            break;

          case 'session_connected':
            // Set the session ID for the active conversation
            conversationId.value = data['session_id'];
            break;
        }
      });
    } catch (e) {
      // Rethrow error to be handled by the caller (e.g., _sendMessagetoServer)
      rethrow;
    }
  }

  /// Animates the AI's response text character-by-character in the UI, simulating a typing effect.
  ///
  /// This method:
  /// - Plays a short series of light haptic taps if the AI response area is initially empty
  /// - Starts a periodic timer that reveals one character at a time from [fullAIResponse]
  ///   and appends it to [visibleAIResponse]
  /// - Cancels the animation when all characters have been rendered
  /// - Once complete, turns off [streamingResponse] and plays a heavy haptic feedback
  ///   if the AI response has been fully received
  ///
  /// Notes:
  /// - Uses a 10ms interval for smooth animation
  /// - Haptic feedback improves the tactile feel during the response loading experience
  void _startTypingAnimation() async {
    if (visibleAIResponse.value.isEmpty) {
      for (int i = 0; i < 6; i++) {
        HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    // Reveal multiple characters at once to reduce flashing
    const charsPerTick =
        7; // Adjust this number - higher = faster, less flashing

    _typingTimer ??= Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_charIndex < fullAIResponse.value.length) {
        // Calculate how many chars to reveal this tick
        final endIndex =
            (_charIndex + charsPerTick).clamp(0, fullAIResponse.value.length);

        // Update visible response to show up to endIndex
        visibleAIResponse.value = fullAIResponse.value.substring(0, endIndex);
        _charIndex = endIndex;
      } else {
        _typingTimer?.cancel();
        _typingTimer = null;

        if (aiResponseComplete.value) {
          streamingResponse.value = false;
          HapticFeedback.heavyImpact();
        }
      }
    });
  }

  final RxList<Map<String, dynamic>>? conversationAttachments =
      <Map<String, dynamic>>[].obs;

  /// Sets the selected conversation as the active one and updates UI state accordingly.
  ///
  /// This method performs the following:
  /// - Updates [conversationId] to the selected conversation’s ID (if it has changed)
  /// - Clears the currently active conversation state (via [clearActiveConversation])
  /// - Assigns the messages from the new conversation to [activeMessages]
  /// - Scrolls the chat UI instantly to the bottom
  ///
  /// Parameters:
  /// - [conversation]: A [MapEntry] containing the Firestore document ID as the key,
  ///   and the conversation data (including messages) as the value.
  ///
  /// Note:
  /// - This is typically triggered when a user taps a conversation from history.
  void setAsActiveConversation(MapEntry<String, dynamic> conversation) async {
    try {
      // Check if the tapped conversation is different from the currently active one
      if (conversationId.value != conversation.key) {
        // Update the observable conversation ID
        conversationId.value = conversation.key;

        // Clear any existing conversation state (e.g. messages, attachments)
        await clearActiveConversation();

        conversationAttachments?.value = conversation.value['attachment_paths'];

        // Extract and assign the new conversation's message list to activeMessages
        final List<Map<String, dynamic>> messages =
            List<Map<String, dynamic>>.from(conversation.value['messages']);
        activeMessages.assignAll(messages);

        await loadAttachments(); // Load attachments for the new conversation

        // Re-assign the conversation ID for redundancy and safety
        conversationId.value = conversation.key;

        // Instantly scroll to the bottom of the chat view to show the latest message
        _scrollController.scrollToBottomInstant();
      }
    } catch (e, stackTrace) {
      LogUtil.error('Error setting convo as the active conversation',
          error: e, stackTrace: stackTrace);
    }
  }

  Future<void> loadAttachments() async {
    for (var attachment in conversationAttachments!) {
      final path = attachment['path'];
      String? url;
      try {
        attachment['loaded'] = false;
        url = await HistoryRepository.instance.getAttachmentFromStorage(path);
        attachment['loaded'] = true;
        attachment['error'] = false; // Set to null if preious error occured
      } catch (e, stackTrace) {
        attachment['error'] = true; // Set file to null if error occurs
        attachment['loaded'] = false;
        LogUtil.error('Error fetching attachment from storage',
            error: e, stackTrace: stackTrace);
      }
      attachment['file'] = url;
    }
    conversationAttachments!.refresh();
  }

  Future<void> clearActiveConversation() async {
    if (conversationId.value != null) {
      activeMessages.clear();
      conversationId.value = null;
      currentMessage.clear();
      _channelSubscription?.cancel(); // Cancel active WebSocket stream listener
      _channel?.sink.close(1000); // Close WebSocket connection gracefully
      _resetAIResponse();
      HistoryRepository.instance.newConversationCount.value =
          0; // Reset new conversation count
      _sttController.clearAllInputs();
      _textController.editor.clear();
      _attachmentsController.attachments.clear();
      conversationAttachments?.clear();
    }
  }
}
