import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth_wrapper.dart';
import 'screens/detail_kereta_screen.dart';
import 'screens/train_code_screen.dart';
import 'screens/auth/account_type_screen.dart';
import 'screens/auth/user_login_screen.dart';
import 'screens/auth/staff_login_screen.dart';
import 'screens/auth/user_register_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Train Tracking App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/account-type': (context) => const AccountTypeScreen(),
        '/user-login': (context) => const UserLoginScreen(),
        '/staff-login': (context) => const StaffLoginScreen(),
        '/user-register': (context) => const UserRegisterScreen(),
        '/main': (context) => const MainNavigationScreen(),
        '/train-code': (context) => const TrainCodeScreen(),
        '/detail': (context) => const DetailKeretaScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const AuthWrapper(),
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
