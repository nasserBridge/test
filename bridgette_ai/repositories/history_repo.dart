import 'package:bridgeapp/src/exceptions/exception_logging.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/controllers/ai_controller.dart';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

/// A central controller for managing conversation history in the application.
///
/// The [HistoryRepository] is responsible for:
/// - Fetching and caching conversation history data from Firestore
/// - Organizing conversations into date-based categories:
///   `"Today"`, `"Yesterday"`, `"This Week"`, and `"Older"`
/// - Managing related UI state such as loading indicators, error flags,
///   and deletion tracking
/// - Interfacing with Firebase Storage to handle attachment retrieval and deletion
/// - Providing reactive state updates using GetX observables to keep the UI in sync
///
/// This controller is initialized as a singleton and shared throughout the app
/// using `HistoryRepository.instance`.
/// - Offers manual cleanup via [manuallyDispose] for fine-grained controller lifecycle control
///
/// Dependencies:
/// - [AuthenticationRepository] to get the current user UID
/// - [AIController] for managing active conversation UI state
///
/// Reactive State Fields:
/// - [_querySnapshot]: Raw Firestore data used to trigger processing
/// - [conversationHistory]: Cleaned and categorized conversation list
/// - [errorOccurred], [conversationHistoryLoading], [retryGetAttachments],
///   [conversationIsDeleted], [deletedConversationId], and [newConversationCount]:
///   observable flags used for dynamic UI rendering
///
/// Example Usage:
/// ```dart
/// final history = HistoryRepository.instance;
/// await history.retrieveConversationHistory();
/// ```

class HistoryRepository extends GetxController {
  /// Singleton instance of the class, retrievable via `HistoryRepository.instance`
  static HistoryRepository get instance => Get.find();

  // ────────────────────────────────────────────
  // State Management & Observables
  // ────────────────────────────────────────────

  /// Subscription worker for reacting to changes in [_querySnapshot].
  ///
  /// This [Worker] is initialized using GetX's [ever] utility to listen for
  /// changes to the [_querySnapshot] observable. When the value changes,
  /// the listener triggers [_cleanConversationHistory] to update the
  /// processed conversation data.
  ///
  /// The subscription is disposed in [dispose()] to prevent memory leaks
  /// and duplicate reactions when the controller is destroyed or reset.
  late Worker _querySnapshotWorker;

  /// Indicates if an error has occurred during data fetching or processing.
  final RxBool errorOccurred = false.obs;

  /// Indicates whether the conversation history is currently being loaded.
  final RxBool conversationHistoryLoading = false.obs;

  /// Flag to notify the UI when attachment retrieval fails and a retry is required.
  final RxBool retryGetAttachments = false.obs;

  /// Flag to notify the UI that a conversation is currently being deleted.
  final RxBool conversationIsDeleted = false.obs;

  /// Holds the ID of the conversation being deleted, used for UI or logic tracking.
  final RxString deletedConversationId = ''.obs;

  /// Tracks the number of new conversations added (e.g., for badges or counters).
  final RxInt newConversationCount = 0.obs;

  // ────────────────────────────────────────────
  // Firebase References
  // ────────────────────────────────────────────

  /// UID of the currently authenticated Firebase user.
  final String? userUID =
      AuthenticationRepository.instance.firebaseUser.value?.uid;

  /// Firestore database instance for reading/writing structured data.
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Firebase Storage instance for reading/writing file attachments.
  final firebase_storage.FirebaseStorage _dbStorage =
      firebase_storage.FirebaseStorage.instance;

  // ────────────────────────────────────────────
  // Data Containers
  // ────────────────────────────────────────────

  /// Holds the raw Firestore query snapshot for the user's conversation history.
  /// This is watched reactively to trigger post-processing.
  final Rxn<QuerySnapshot<Map<String, dynamic>>> _querySnapshot =
      Rxn<QuerySnapshot<Map<String, dynamic>>>();

  /// Holds the cleaned and categorized conversation history, grouped by time buckets
  /// such as "Today", "Yesterday", "This Week", and "Older".
  final RxMap<String, dynamic> conversationHistory = <String, dynamic>{}.obs;

  // ────────────────────────────────────────────
  // AI Controller Reference
  // ────────────────────────────────────────────

  /// Singleton instance of [AIController] used for interacting with the active conversation UI.
  final AIController _controller = Get.put(AIController());

  // ────────────────────────────────────────────
  // Lifecycle Methods
  // ────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // Automatically clean and categorize conversation history
    // whenever the raw Firestore query snapshot updates.
    _querySnapshotWorker =
        ever(_querySnapshot, (_) => _organizeConversationHistory());
  }

  @override
  void dispose() {
    // Reset all reactive state variables when this controller is disposed.
    reset();
    super.dispose();
  }

  /// Manually disposes this controller and unregisters it from GetX.
  ///
  /// This method is useful when the controller is not bound via typical
  /// GetBuilder lifecycle management and needs to be explicitly cleaned up.
  ///
  /// Steps:
  /// - Calls [dispose] to release internal resources.
  /// - Checks if the controller is still registered with GetX
  /// - If so, calls [Get.delete] to remove the instance from memory
  void manuallyDispose() {
    dispose();
    if (Get.isRegistered<HistoryRepository>()) {
      Get.delete<HistoryRepository>();
    }
  }

  /// Retrieves the user's conversation history from Firestore and manages the
  /// UI state for loading and error indicators.
  ///
  /// This method does the following:
  /// - Resets any prior error state.
  /// - Sets the `conversationHistoryLoading` flag to `true` to notify the UI.
  /// - Calls the internal [_getDbConversationHistory] method to fetch the data.
  /// - Resets the loading flag to `false` once the operation completes.
  /// - If an error occurs, sets [errorOccurred] to `true`, stops loading,
  ///   and logs the error for diagnostics.
  ///
  /// This method is typically called when initializing or refreshing the
  /// conversation list view.
  Future<void> retrieveConversationHistory() async {
    try {
      // Reset error flag before starting the fetch
      errorOccurred.value = false;

      // Notify UI that loading is in progress
      conversationHistoryLoading.value = true;

      // Fetch conversation history from Firestore
      await _getDbConversationHistory();

      // Notify UI that loading has finished
      conversationHistoryLoading.value = false;
    } catch (e, stackTrace) {
      // On error, set error flag and stop the loading state
      errorOccurred.value = true;
      conversationHistoryLoading.value = false;

      // Log the error with context for debugging
      LogUtil.error(
        'Error retrieving Conversation History from db.',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Retrieves the conversation history for the currently authenticated user
  /// from Firestore and stores the result in the class-level observable [_querySnapshot].
  ///
  /// This method accesses the user's `conversation_history` subcollection located at:
  /// `/Users/{userUID}/conversation_history`
  ///
  /// The result is saved into [_querySnapshot], which is used by downstream processes
  /// (such as [_cleanConversationHistory]) to group and render the conversation list.
  ///
  /// Throws:
  /// - Any exceptions that occur during the Firestore fetch are rethrown
  ///   to allow higher-level handling (e.g., by the caller or a global error handler).
  Future<void> _getDbConversationHistory() async {
    try {
      // Define the Firestore path to the user's conversation history
      final path = _db
          .collection('Users')
          .doc(userUID)
          .collection('conversation_history');

      // Fetch all documents in the conversation_history subcollection
      _querySnapshot.value = await path.get();
    } catch (e) {
      // Let the caller handle the error; do not suppress it here
      rethrow;
    }
  }

  /// Cleans, enriches, and organizes the user's conversation history into
  /// intuitive time-based categories for display: `"Today"`, `"Yesterday"`,
  /// `"This Week"`, and `"Older"`.
  ///
  /// This method performs the following:
  /// 1. Derives normalized date boundaries (today, yesterday, start of week).
  /// 2. Iterates over the raw Firestore snapshot [_querySnapshot].
  /// 3. Converts each document's timestamp into a comparable `DateTime`.
  /// 4. Extracts messages and processes attachments using [retrieveAttachments].
  /// 5. Categorizes each conversation into its proper time bucket.
  /// 6. Sorts each bucket by descending `last_updated`.
  /// 7. Updates the observable [conversationHistory] with the cleaned result.
  ///
  /// This prepares conversation history data for sectioned UI display.
  ///
  /// Side effects:
  /// - Updates [conversationHistory] (grouped, sorted Map)
  /// - Resets [newConversationCount]
  /// - Toggles [errorOccurred] and [conversationHistoryLoading] on failure
  ///
  /// Throws:
  /// - All exceptions are caught internally and logged.
  Future<void> _organizeConversationHistory() async {
    // Current timestamp
    final now = DateTime.now();

    // Strip off time components to normalize dates
    final todayDate = DateTime(now.year, now.month, now.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    // Calculate start of the current week (Sunday as day 0)
    final startOfWeek =
        todayDate.subtract(Duration(days: todayDate.weekday % 7));

    // Prepare category map for organizing conversations
    final Map<String, List<MapEntry<String, Map<String, dynamic>>>>
        categorized = {
      'Today': [],
      'Yesterday': [],
      'This Week': [],
      'Older': [],
    };

    try {
      // Iterate through each conversation document from Firestore
      for (var doc in _querySnapshot.value!.docs) {
        final data = doc.data();

        // Parse and validate last_updated timestamp
        final Timestamp? ts = data['last_updated'];
        final lastUpdated = ts?.toDate();
        if (lastUpdated == null) continue; // Skip if no timestamp

        // Prepare message and attachment containers
        final List<Map<String, dynamic>> messages = [];
        final List<Map<String, dynamic>> attachmentPaths = [];

        // Process each message, enrich with attachment metadata
        for (var message in data['messages']) {
          if (message is Map<String, dynamic>) {
            final attachments = retrieveAttachments(message);
            message['attachments'] = attachments;
            messages.add(message);

            // Aggregate all the attachments
            attachmentPaths.addAll(attachments);
          }
        }

        // Build cleaned conversation object
        final conversation = {
          'title': data['title'],
          'last_updated': ts,
          'messages': messages,
          'attachment_paths': attachmentPaths,
        };

        // Normalize conversation date to date-only format
        final convDate =
            DateTime(lastUpdated.year, lastUpdated.month, lastUpdated.day);

        // Categorize based on date relative to today
        final category =
            _getDateCategory(convDate, todayDate, yesterdayDate, startOfWeek);

        // Add this entry to the appropriate category list
        final entry = MapEntry(doc.id, conversation);
        categorized[category]?.add(entry);
      }

      // Sort each category's conversations by last_updated (descending)
      for (var list in categorized.values) {
        list.sort(
          (a, b) => (b.value['last_updated'] as Timestamp)
              .compareTo(a.value['last_updated'] as Timestamp),
        );
      }

      // Reset any counter tracking new conversations
      newConversationCount.value = 0;

      // Overwrite final grouped map into reactive `conversationHistory`
      conversationHistory.assignAll({
        'Today': Map.fromEntries(categorized['Today']!),
        'Yesterday': Map.fromEntries(categorized['Yesterday']!),
        'This Week': Map.fromEntries(categorized['This Week']!),
        'Older': Map.fromEntries(categorized['Older']!),
      });
    } catch (e, stackTrace) {
      // Signal failure to UI and log the error for diagnostics
      errorOccurred.value = true;
      conversationHistoryLoading.value = false;
      LogUtil.error(
        'Error cleaning conversation history',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Extracts and formats attachment file paths (images and PDFs) from a
  /// message map, returning a structured list of attachment objects.
  ///
  /// This method performs the following:
  /// - Looks for `'images'` and `'pdf'` keys in the [msg] map.
  /// - For each file path in these lists:
  ///   - Ensures it is a valid string.
  ///   - Converts it into a standardized attachment object with keys:
  ///     - `'type'`: either `'image'` or `'pdf'`
  ///     - `'file'`: the original Firebase Storage path
  ///     - `'name'`: the extracted filename (e.g., `'receipt.pdf'`)
  ///     - `'converted'`: whether it has been base64-converted (false by default)
  ///     - `'base64'`: placeholder for a future base64 string (null by default)
  ///     - `'fromStorage'`: a flag used by the UI to determine source
  ///
  /// This format is intended to simplify downstream logic in the UI and attachment
  /// processors.
  ///
  /// Parameters:
  /// - [msg]: A `Map<String, dynamic>` object representing a message containing
  ///   optional 'images' and/or 'pdf' keys.
  ///
  /// Returns:
  /// - A `List<Map<String, dynamic>>` of formatted attachment objects.
  ///
  /// Throws:
  /// - Any unexpected error during parsing will be rethrown.
  List<Map<String, dynamic>> retrieveAttachments(Map<String, dynamic> msg) {
    try {
      // This list will hold the final structured attachment objects
      final List<Map<String, dynamic>> attachments = [];

      // Supported attachment keys in the message map
      for (final type in ['images', 'pdf']) {
        // Retrieve the list of paths under the current type (if present)
        final items = msg[type];

        // Proceed only if the list exists and is not empty
        if (items is List && items.isNotEmpty) {
          for (final path in items) {
            // Ensure the path is a string before processing
            if (path is String) {
              attachments.add({
                'type': type == 'images' ? 'image' : 'pdf', // Normalize label
                'file': path, // Full path in Firebase Storage
                'path': path,
                'loaded': false,
                'error': false,
                'name': path.split('/').last, // Extract the filename
                'converted': false, // Not yet base64-converted
                'base64': null, // Placeholder for base64 content
                'fromStorage': true, // Indicates file came from Firebase
              });
            }
          }
        }
      }

      // Return the fully built list of attachments
      return attachments;
    } catch (e) {
      // Let the error propagate to be handled by the caller
      rethrow;
    }
  }

  /// Categorizes a given conversation date into one of four relative date labels:
  /// - `"Today"`: if the date is the same as [today]
  /// - `"Yesterday"`: if the date is the same as [yesterday]
  /// - `"This Week"`: if the date is after the [startOfWeek] but not today or yesterday
  /// - `"Older"`: if the date is before the start of the current week
  ///
  /// This method helps organize conversations into intuitive groupings for the UI.
  ///
  /// Parameters:
  /// - [convDate]: The date of the conversation to categorize.
  /// - [today]: The current date (normalized to midnight).
  /// - [yesterday]: The date for "yesterday" (normalized to midnight).
  /// - [startOfWeek]: The first day of the current week (e.g., Sunday or Monday).
  ///
  /// Returns:
  /// - A [String] representing the category: "Today", "Yesterday", "This Week", or "Older".
  ///
  /// Throws:
  /// - Any unexpected error will be rethrown to be handled by the calling code.
  String _getDateCategory(
    DateTime convDate,
    DateTime today,
    DateTime yesterday,
    DateTime startOfWeek,
  ) {
    try {
      // Compare dates using isAtSameMomentAs to avoid millisecond mismatch issues
      if (convDate.isAtSameMomentAs(today)) return 'Today';
      if (convDate.isAtSameMomentAs(yesterday)) return 'Yesterday';

      // If the conversation occurred after the start of the week (but not today or yesterday)
      if (convDate.isAfter(startOfWeek)) return 'This Week';

      // All other dates are considered older
      return 'Older';
    } catch (e) {
      // Allow unexpected errors to bubble up for upstream handling
      rethrow;
    }
  }

  /// Retrieves and returns the download URL for an attachment stored in
  /// Firebase Storage that belongs to the currently authenticated user
  /// and is associated with a specific conversation.
  ///
  /// This method performs the following:
  /// - Constructs a Firebase Storage reference from the given [path].
  /// - Attempts to retrieve a download URL using `.getDownloadURL()`.
  /// - Returns the URL as a string if successful, or `null` if an error occurs.
  /// - Toggles the [retryGetAttachments] observable to signal the UI
  ///   (or any listeners) that a retry may be needed.
  ///
  /// Parameters:
  /// - [path]: A string representing the Firebase Storage path to the file,
  ///   such as `Users/{userUID}/attachments/{filename}.pdf`.
  ///
  /// Returns:
  /// - A [String] download URL if the file is found and accessible, or `null`
  ///   if retrieval fails.
  ///
  /// Errors:
  /// - All exceptions are caught and logged via [LogUtil].
  /// - If an error occurs, [retryGetAttachments] is toggled to trigger
  ///   a visual or logical retry handler in the UI or controller layer.
  Future<String?> getAttachmentFromStorage(String path) async {
    try {
      // Define a reference to the file in Firebase Storage using the given path.
      final ref = _dbStorage.ref(path);

      // Attempt to retrieve a publicly accessible download URL for the file.
      String url = await ref.getDownloadURL();

      // Return the retrieved URL so it can be used by the UI.
      return url;
    } catch (e) {
      rethrow;
    }
  }

  /// A function that resets the class variables.
  void reset() {
    _querySnapshotWorker.dispose(); // Cancels the ever() listener
    conversationHistoryLoading.value = false;
    _querySnapshot.value = null;
    retryGetAttachments.value = false;
    conversationIsDeleted.value = false;
    deletedConversationId.value = '';
    conversationHistory.clear();
    errorOccurred.value = false;
    newConversationCount.value = 0;
  }

  /// Deletes all traces of a conversation from Firestore and Firebase Storage,
  /// including both conversation metadata and attachments. Also manages the
  /// corresponding UI state to reflect deletion progress.
  ///
  /// This method performs the following tasks:
  /// 1. Sets UI flags to indicate that a conversation is being deleted.
  /// 2. Deletes:
  ///    - The conversation from `/Users/{userUID}/conversations/{id}`
  ///    - The associated history from `/Users/{userUID}/conversation_history/{id}`
  ///    - All related file attachments from Firebase Storage
  /// 3. If the deleted conversation is the one currently being viewed, it clears
  ///    the active UI state.
  /// 4. Refreshes the conversation history list from Firestore.
  /// 5. Resets the deletion state flags and handles any errors by logging them.
  ///
  /// Parameters:
  /// - [deletedConversationId]: The ID of the conversation to be fully deleted.
  /// - [currentConversationId]: The ID of the conversation currently active in the UI.
  /// - [attachmentPaths]: A list of Firebase Storage paths to attachments related to the conversation.
  ///
  /// Errors during any part of the deletion process are caught, logged, and the UI
  /// state is restored to avoid leaving the interface in an inconsistent state.
  Future<void> deleteConversation(
    String deletedConversationId,
    String? currentConversationId,
    List<Map<String, dynamic>> attachmentPaths,
  ) async {
    // Notify UI that deletion is in progress.
    conversationIsDeleted.value = true;

    // Save the ID of the conversation being deleted for global state tracking.
    this.deletedConversationId.value = deletedConversationId;

    try {
      // Concurrently delete:
      // - The conversation document
      // - The conversation history document
      // - All related attachments in storage
      await Future.wait([
        _deleteConversationHistoryPath(deletedConversationId),
        _deleteConversationsPath(deletedConversationId),
        _deleteAttachmentsFromStorage(attachmentPaths),
      ]);

      // If the deleted conversation is currently displayed in the UI,
      // clear it to avoid referencing deleted data.
      if (deletedConversationId == currentConversationId) {
        _controller.clearActiveConversation();
      }

      // Refresh the list of conversations shown in the UI.
      await _getDbConversationHistory();

      // Notify UI that deletion is complete.
      conversationIsDeleted.value = false;

      // Reset tracked deleted conversation ID.
      deletedConversationId = '';
    } catch (e, stackTrace) {
      // Log error with context for debugging and crash reporting.
      LogUtil.error('Error deleting conversation',
          error: e, stackTrace: stackTrace);

      // Reset UI state to prevent soft-lock.
      this.deletedConversationId.value = '';

      // Try to refresh the conversation history list.
      _getDbConversationHistory();
    }
  }

  /// Deletes a single conversation history document from Firestore that
  /// corresponds to the given conversation ID.
  ///
  /// This is used when cleaning up a conversation, ensuring the associated
  /// entry in the `conversation_history` subcollection is also removed to
  /// maintain data consistency and avoid clutter.
  ///
  /// The document path targeted is:
  /// `/Users/{userUID}/conversation_history/{deletedConversationId}`
  ///
  /// Parameters:
  /// - [deletedConversationId]: The ID of the conversation history document
  ///   to delete. This should match the conversation ID used elsewhere.
  ///
  /// Errors during the deletion process are propagated via `rethrow` so they
  /// can be handled by the calling function or global error handler.
  Future<void> _deleteConversationHistoryPath(
      String deletedConversationId) async {
    try {
      // Define the Firestore document reference for the conversation history.
      final path = _db
          .collection('Users')
          .doc(userUID)
          .collection('conversation_history')
          .doc(deletedConversationId);

      // Delete the conversation history document.
      await path.delete();
    } catch (e) {
      // Rethrow the error so the calling method can handle or log it.
      rethrow;
    }
  }

  /// Deletes a specific conversation and all of its associated nested data
  /// from Firestore for the current user.
  ///
  /// This function performs the following operations:
  /// 1. Locates the conversation document at:
  ///    `/Users/{userUID}/conversations/{deletedConversationId}`
  /// 2. Identifies and deletes all `writes` subcollections located under:
  ///    `/Users/{userUID}/conversations/{deletedConversationId}/checkpoints/*/writes`
  /// 3. Deletes each `checkpoint` document under the conversation's
  ///    `/checkpoints` subcollection.
  /// 4. Deletes the conversation document itself.
  ///
  /// This method ensures that no orphaned `write` or `checkpoint` documents remain,
  /// which is important for avoiding unnecessary document reads/writes and preserving
  /// clean Firestore structure.
  ///
  /// Parameters:
  /// - [deletedConversationId]: The ID of the conversation to be deleted.
  ///
  /// Errors during the deletion process are propagated via `rethrow` so they
  /// can be handled by the calling function or global error handler.
  Future<void> _deleteConversationsPath(String deletedConversationId) async {
    // Reference to the specific conversation document to be deleted.
    final path = _db
        .collection('Users')
        .doc(userUID)
        .collection('conversations')
        .doc(deletedConversationId);

    try {
      // Step 1: Query across all 'writes' subcollections in Firestore.
      final writesQuery = await _db.collectionGroup('writes').get();

      // Used to keep track of which checkpoints have already been handled,
      // so we don't try to delete the same one multiple times.
      final visitedCheckpoints = <String>{};

      // Step 2: Iterate through each 'write' document across all collections.
      for (final writeDoc in writesQuery.docs) {
        // Get the parent checkpoint of the 'writes' document.
        final checkpointRef = writeDoc.reference.parent.parent;

        // Continue only if:
        // - The checkpoint is part of the current conversation being deleted.
        // - It hasn't already been processed.
        if (checkpointRef != null &&
            checkpointRef.path.contains(
                '/conversations/$deletedConversationId/checkpoints/') &&
            !visitedCheckpoints.contains(checkpointRef.path)) {
          // Mark this checkpoint path as visited.
          visitedCheckpoints.add(checkpointRef.path);

          // Step 3: Delete all 'writes' under this checkpoint.
          final writesSnapshot = await checkpointRef.collection('writes').get();
          for (final w in writesSnapshot.docs) {
            await w.reference.delete(); // Delete each individual write.
          }

          // Delete the checkpoint document itself.
          await checkpointRef.delete();
        }
      }

      // Step 4: After checking group-level writes, make sure all checkpoints
      // directly under the conversation are also deleted.
      final checkpointsSnapshot = await path.collection('checkpoints').get();
      for (final cp in checkpointsSnapshot.docs) {
        // If the checkpoint wasn't already visited and deleted above, delete it now.
        if (!visitedCheckpoints.contains(cp.reference.path)) {
          await cp.reference.delete();
        }
      }

      // Step 5: Finally, delete the main conversation document.
      await path.delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes a list of file attachments from Firebase Storage that are
  /// associated with a conversation being deleted.
  ///
  /// This method is intended to be called before or during the deletion of
  /// a conversation, to ensure that any associated files stored in
  /// Firebase Storage are also removed to prevent orphaned storage files
  /// and minimize costs.
  ///
  /// Each file path in [attachmentPaths] should be a valid path in Firebase
  /// Storage (e.g., `Users/{userUID}/attachments/{fileName}.pdf`).
  ///
  /// Parameters:
  /// - [attachmentPaths]: A list of full storage paths to files that
  ///   should be deleted.
  /// Errors during the deletion process are propagated via `rethrow` so they
  /// can be handled by the calling function or global error handler.
  Future<void> _deleteAttachmentsFromStorage(
      List<Map<String, dynamic>> attachmentPaths) async {
    // Iterate through each attachment path in the provided list.
    for (final attachment in attachmentPaths) {
      try {
        String path = attachment['file'] as String;
        // Create a reference to the file in Firebase Storage.
        final ref = _dbStorage.ref(path);

        // Delete the file at the specified reference.
        await ref.delete();
      } catch (e) {
        rethrow;
      }
    }
  }
}
