import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';

class OverlayHandler {
  static OverlayEntry? overlayEntry;
  static final TextEditingController _codeController = TextEditingController();

  /// Shows the MFA SMS code overlay.
  /// [onSubmit] receives the 6-digit code the user entered.
  /// [message] customises the prompt text.
  static void showOverlay(
    BuildContext context, {
    required Future<void> Function(String code) onSubmit,
    String message = 'Please enter the verification code sent to your phone.',
  }) {
    _codeController.clear();

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / Scale.x(3),
            left: MediaQuery.of(context).size.width / Scale.x(6),
            child: Material(
              elevation: 4.0,
              child: Container(
                padding: EdgeInsets.all(Scale.x(20)),
                color: Colors.white,
                width: MediaQuery.of(context).size.width * Scale.x(0.66),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message),
                    SizedBox(height: Scale.x(12)),
                    TextField(
                      controller: _codeController,
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '6-digit code',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: Scale.x(8)),
                    ElevatedButton(
                      onPressed: () async {
                        final code = _codeController.text.trim();
                        if (code.length != 6) return;
                        removeOverlay();
                        await onSubmit(code);
                      },
                      child: const Text('Submit'),
                    ),
                    TextButton(
                      onPressed: removeOverlay,
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(overlayEntry!);
  }

  static void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
    _codeController.clear();
  }
}
