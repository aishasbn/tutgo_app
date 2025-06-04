import 'package:flutter/material.dart';

class EnterCode extends StatelessWidget{
  const EnterCode({super.key});

  @override  
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFC95792), 
        borderRadius: BorderRadius.circular(12), 
      ),

    );
  }
}