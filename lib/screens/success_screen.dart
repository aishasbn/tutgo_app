import 'package:flutter/material.dart';
import '../widgets/success_widget.dart';
import '../utils/route_helper.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEFEF),
      body: SafeArea(
        child: SuccessWidget(
          onContinue: () {
            // Navigate back to main screen
            RouteHelper.navigateAndClearStack(context, RouteHelper.main);
          },
        ),
      ),
    );
  }
}
