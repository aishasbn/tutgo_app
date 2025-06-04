import 'package:flutter/material.dart';
import 'package:tutgo/widgets/success_widget.dart'; // sesuaikan path

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEFEF),
      body: SafeArea(
        child: SuccessWidget(
          onContinue: () {
            Navigator.pop(context); // kembali ke sebelumnya, bisa diganti jika ingin navigasi lain
          },
        ),
      ),
    );
  }
}
