// lib/widgets/code_input_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeInputWidget extends StatefulWidget {
  final int codeLength;
  final Function(String) onCompleted;
  final Function(String)? onCodeChanged;
  final String? initialValue;

  const CodeInputWidget({
    super.key,
    this.codeLength = 6,
    required this.onCompleted,
    this.onCodeChanged,
    this.initialValue,
  });

  @override
  State<CodeInputWidget> createState() => _CodeInputWidgetState();
}

class _CodeInputWidgetState extends State<CodeInputWidget> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  
  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.codeLength, 
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.codeLength, 
      (index) => FocusNode(),
    );
    
    // Fill with initial value if provided
    if (widget.initialValue != null) {
      final digits = widget.initialValue!.split('');
      for (int i = 0; i < digits.length && i < widget.codeLength; i++) {
        _controllers[i].text = digits[i];
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next field
      if (index < widget.codeLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    
    // Get current code
    String currentCode = _controllers.map((c) => c.text).join();
    
    // Call onCodeChanged callback
    if (widget.onCodeChanged != null) {
      widget.onCodeChanged!(currentCode);
    }
    
    // Check if code is complete
    if (currentCode.length == widget.codeLength) {
      widget.onCompleted(currentCode);
    }
  }

  void _onKeyEvent(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controllers[index].text.isEmpty && index > 0) {
          _focusNodes[index - 1].requestFocus();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.codeLength,
        (index) => Container(
          width: 45,
          height: 45,
          margin: EdgeInsets.symmetric(horizontal: 5),
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (event) => _onKeyEvent(event, index),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Color(0xFFD75A9E),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Color(0xFFD75A9E),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) => _onChanged(value, index),
            ),
          ),
        ),
      ),
    );
  }
}