import 'package:flutter/material.dart';
import 'package:tutgo/screens/success_screen.dart';
import 'package:tutgo/widgets/warning_box.dart';
import 'package:tutgo/widgets/title_section.dart';
import 'package:tutgo/widgets/train_code_input_form.dart';

class TrainCodeScreen extends StatelessWidget {
  const TrainCodeScreen({super.key});

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xFFFDEFEF), // warna solid background
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleSection(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                    const WarningBox(),
                    TrainCodeInputForm(
                      onSubmit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SuccessScreen(),
                          ),
                        );
                      },
                    ),
                  ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}
