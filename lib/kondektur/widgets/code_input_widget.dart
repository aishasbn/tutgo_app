import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeInputWidget extends StatefulWidget {
  final int codeLength;
  final Function(String) onCompleted;
  final Function(String)? onCodeChanged;
  final String? initialValue;

  const CodeInputWidget({
    super.key,
    this.codeLength = 5, // Changed to 5 for TG001 format
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
    
    // Set initial value if provided
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _setInitialValue(widget.initialValue!);
    }
  }
  
  void _setInitialValue(String value) {
    for (int i = 0; i < widget.codeLength && i < value.length; i++) {
      _controllers[i].text = value[i];
    }
    _checkCompletion();
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
      if (index < widget.codeLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    
    _checkCompletion();
  }
  
  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }
  
  void _checkCompletion() {
    String code = _controllers.map((controller) => controller.text).join();
    
    if (widget.onCodeChanged != null) {
      widget.onCodeChanged!(code);
    }
    
    if (code.length == widget.codeLength) {
      widget.onCompleted(code);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.codeLength, (index) {
        return Container(
          width: 50,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(
              color: _focusNodes[index].hasFocus 
                  ? const Color(0xFFD75A9E)
                  : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
            ],
            onChanged: (value) => _onChanged(value.toUpperCase(), index),
            onTap: () {
              _controllers[index].selection = TextSelection.fromPosition(
                TextPosition(offset: _controllers[index].text.length),
              );
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
            ),
          ),
        );
      }),
    );
  }
}
