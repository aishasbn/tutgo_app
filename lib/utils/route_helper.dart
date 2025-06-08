import 'package:flutter/material.dart';

class RouteHelper {
  // Route names constants
  static const String authWrapper = '/';
  static const String accountType = '/account-type';
  static const String userLogin = '/user-login';
  static const String staffLogin = '/staff-login';
  static const String userRegister = '/user-register';
  static const String main = '/main';
  static const String trainCode = '/train-code';
  static const String detail = '/detail';
  static const String success = '/success';

  // Navigation methods
  static void navigateToAccountType(BuildContext context) {
    Navigator.pushReplacementNamed(context, accountType);
  }

  static void navigateToUserLogin(BuildContext context) {
    Navigator.pushNamed(context, userLogin);
  }

  static void navigateToStaffLogin(BuildContext context) {
    Navigator.pushNamed(context, staffLogin);
  }

  static void navigateToUserRegister(BuildContext context) {
    Navigator.pushNamed(context, userRegister);
  }

  static void navigateToMain(BuildContext context) {
    Navigator.pushReplacementNamed(context, main);
  }

  static void navigateToTrainCode(BuildContext context) {
    Navigator.pushNamed(context, trainCode);
  }

  static void navigateToDetail(BuildContext context, {Object? arguments}) {
    Navigator.pushNamed(context, detail, arguments: arguments);
  }

  static void navigateToSuccess(BuildContext context) {
    Navigator.pushNamed(context, success);
  }

  // Clear stack and navigate
  static void navigateAndClearStack(BuildContext context, String routeName) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
    );
  }

  // Go back
  static void goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  // Go back to specific route
  static void goBackTo(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }
}
