import 'package:stack_trace/stack_trace.dart';
import 'package:logger/logger.dart';

class LogUtil {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount:
          null, // Number of stack trace lines to show in debug/info logs
      errorMethodCount: null, // Show deeper stack on errors
      lineLength: 120, // Adjust line width
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Log informational messages.
  static void info(String message) {
    _logger.i(message);
  }

  /// Log debug messages.
  static void debug(String message) {
    _logger.d(message);
  }

  /// Log warnings.
  static void warning(String message) {
    _logger.w(message);
  }

  /// Log errors with optional context, using terse stack trace folding and reversed order.
  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    final terse = Chain.forTrace(stackTrace ?? StackTrace.current).foldFrames(
      (frame) {
        final uri = frame.uri.toString();
        return uri.contains('dart:') ||
            uri.contains('flutter/') ||
            uri.contains('package:flutter/');
      },
      terse: true,
    );

    final reversed = _reverseStackTrace(terse);
    _logger.e(message, error: error, stackTrace: reversed);
  }

  /// Reverses the order of the stack trace lines to show top-level app code first.
  static StackTrace _reverseStackTrace(StackTrace stack) {
    final lines = stack.toString().trim().split('\n');
    final reversedLines = lines.reversed.join('\n');
    return StackTrace.fromString(reversedLines);
  }
}
