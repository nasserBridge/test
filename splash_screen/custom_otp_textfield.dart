import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomOtpTextField extends StatefulWidget {
  final int numberOfFields;
  final Function(String) onSubmit;
  final Function(String)? onCodeChanged;
  final double fieldWidth;
  final bool showFieldAsBox;
  final Color fillColor;
  final bool filled;

  const CustomOtpTextField({
    super.key,
    required this.numberOfFields,
    required this.onSubmit,
    this.onCodeChanged,
    this.fieldWidth = 20, // Increased for better mobile usability
    this.showFieldAsBox = false,
    this.fillColor = const Color.fromRGBO(0, 0, 0, 0.1),
    this.filled = false,
  });

  @override
  CustomOtpTextFieldState createState() => CustomOtpTextFieldState();
}

class CustomOtpTextFieldState extends State<CustomOtpTextField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  final FocusNode _keyboardFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.numberOfFields, (_) => TextEditingController());
    _focusNodes = List.generate(widget.numberOfFields, (_) => FocusNode());

    // Detect clipboard paste on field tap
    for (var controller in _controllers) {
      controller.addListener(() {
        _handlePaste(controller);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _keyboardFocus.dispose();
    super.dispose();
  }

  // Handle normal input (single character per field) or paste event
  void _onChanged(String value, int index) {
    if (value.length > 1) {
      // Pasting multiple characters
      _pasteOtp(value);
      return;
    }

    if (value.isNotEmpty) {
      String newValue =
          value.substring(value.length - 1); // Keep only last digit
      setState(() {
        _controllers[index].text = newValue;
      });

      String currentCode = _controllers.map((c) => c.text).join();
      widget.onCodeChanged?.call(currentCode);

      if (index < widget.numberOfFields - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _submitOtp();
      }
    }
  }

  // Handle Backspace Press
  void _onBackspace(int index) {
    if (_controllers[index].text.isNotEmpty) {
      setState(() {
        _controllers[index].clear();
      });

      String currentCode = _controllers.map((c) => c.text).join();
      widget.onCodeChanged?.call(currentCode);
    } else if (index > 0) {
      setState(() {
        _controllers[index - 1].clear();
      });
      _focusNodes[index - 1].requestFocus();
    }
  }

  // Handle paste from clipboard properly
  void _handlePaste(TextEditingController controller) async {
    ClipboardData? clipboardData =
        await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      String otp = clipboardData.text!.trim();
      if (otp.length == widget.numberOfFields &&
          RegExp(r'^\d+$').hasMatch(otp)) {
        _pasteOtp(otp);
      }
    }
  }

  // Paste OTP correctly across fields
  void _pasteOtp(String otp) {
    otp = otp.replaceAll(RegExp(r'\D'), ''); // Remove non-digits
    if (otp.length > widget.numberOfFields) {
      otp = otp.substring(0, widget.numberOfFields); // Ensure length fits
    }

    for (int i = 0; i < otp.length; i++) {
      _controllers[i].text = otp[i]; // Set one digit per field
    }
    _focusNodes.last.requestFocus(); // Move focus to last field
    widget.onSubmit(otp); // Auto-submit when all fields are filled
  }

  // Auto-submit OTP when last field is filled
  void _submitOtp() {
    String otp = _controllers.map((controller) => controller.text).join();
    widget.onSubmit(otp);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocus, // Detects backspace globally
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace) {
          for (int i = 0; i < widget.numberOfFields; i++) {
            if (_focusNodes[i].hasFocus) {
              _onBackspace(i);
              break;
            }
          }
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.numberOfFields, (index) {
          return Container(
            width: widget.fieldWidth,
            margin: EdgeInsets.symmetric(horizontal: Scale.x(5)),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              maxLength: 1,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: Scale.x(20)),
              decoration: InputDecoration(
                counterText: "",
                filled: widget.filled,
                fillColor: widget.fillColor,
                border: widget.showFieldAsBox
                    ? OutlineInputBorder()
                    : UnderlineInputBorder(),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => _onChanged(value, index),
              onTap: () {
                _controllers[index].selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: _controllers[index].text.length,
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
