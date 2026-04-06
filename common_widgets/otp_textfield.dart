import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef OnCodeEnteredCompletion = void Function(String value);
typedef OnCodeChanged = void Function(String value);

class MyOtpTextField extends StatefulWidget {
  final bool showCursor;
  final int maxDigits;
  final double fieldWidth;
  final double? fieldHeight;
  final double borderWidth;
  final Color enabledBorderColor;
  final Color focusedBorderColor;
  final Color disabledBorderColor;
  final Color borderColor;
  final Color? cursorColor;
  final TextInputType keyboardType;
  final TextStyle? textStyle;
  final OnCodeEnteredCompletion? onSubmit;
  final OnCodeEnteredCompletion? onCodeChanged;
  final bool obscureText;
  final bool showFieldAsBox;
  final bool enabled;
  final bool filled;
  final bool readOnly;
  final Color fillColor;
  final BorderRadius borderRadius;
  final InputDecoration? decoration;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;
  final bool hasCustomInputDecoration;

  const MyOtpTextField({
    super.key,
    this.showCursor = true,
    this.maxDigits = 6,
    this.fieldWidth = 250.0,
    this.fieldHeight,
    this.textStyle,
    this.keyboardType = TextInputType.number,
    this.borderWidth = 2.0,
    this.cursorColor,
    this.disabledBorderColor = const Color(0xFFE7E7E7),
    this.enabledBorderColor = const Color(0xFFE7E7E7),
    this.borderColor = const Color(0xFFE7E7E7),
    this.focusedBorderColor = const Color(0xFFE7E7E7),
    this.onSubmit,
    this.obscureText = false,
    this.showFieldAsBox = false,
    this.enabled = true,
    this.filled = false,
    this.fillColor = const Color(0xFFFFFFFF),
    this.readOnly = false,
    this.decoration,
    this.onCodeChanged,
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.inputFormatters,
    this.contentPadding,
    this.hasCustomInputDecoration = false,
  }) : assert(maxDigits > 0);

  @override
  MyOtpTextFieldState createState() => MyOtpTextFieldState();
}

class MyOtpTextFieldState extends State<MyOtpTextField> {
  late TextEditingController _otpController;
  late FocusNode _focusNode;
  bool _wasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _focusNode = FocusNode();

    _otpController.addListener(() {
      final text = _otpController.text;

      if (widget.onCodeChanged != null) {
        widget.onCodeChanged!(text);
      }

      if (text.length == widget.maxDigits) {
        _onSubmit(text);
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSubmit(String otp) {
    if (!_wasSubmitted) {
      _wasSubmitted = true;
      if (widget.onSubmit != null) {
        widget.onSubmit!(otp);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 150,
        height: widget.fieldHeight ?? 50,
        child: Center(
          child: TextField(
            controller: _otpController,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            textAlignVertical: TextAlignVertical.center,
            textAlign: TextAlign.center,
            maxLength: widget.maxDigits,
            showCursor: widget.showCursor,
            cursorColor: widget.cursorColor,
            style: widget.textStyle,
            obscureText: widget.obscureText,
            inputFormatters: widget.inputFormatters ??
                [
                  FilteringTextInputFormatter.digitsOnly,
                ],
            decoration: widget.hasCustomInputDecoration
                ? widget.decoration
                : InputDecoration(
                    counterText: "",
                    filled: widget.filled,
                    fillColor: widget.fillColor,
                    focusedBorder: _underlineBorder(widget.focusedBorderColor),
                    enabledBorder: _underlineBorder(widget.enabledBorderColor),
                    disabledBorder:
                        _underlineBorder(widget.disabledBorderColor),
                    border: _underlineBorder(widget.borderColor),
                    contentPadding: widget.contentPadding,
                  ),
            onChanged: (String value) {
              if (value.length == widget.maxDigits) {
                _onSubmit(value);
              } else {
                setState(() {
                  _wasSubmitted = false;
                });
              }
            },
          ),
        ),
      ),
    );
  }

  UnderlineInputBorder _underlineBorder(Color color) {
    return UnderlineInputBorder(
      borderSide: BorderSide(
        width: widget.borderWidth,
        color: color,
      ),
    );
  }
}
