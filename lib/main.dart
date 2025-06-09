import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth_wrapper.dart';
import 'screens/auth/account_type_screen.dart';
import 'screens/auth/user_login_screen.dart';
import 'screens/auth/staff_login_screen.dart';
import 'screens/auth/user_register_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/train_code_screen.dart';
import 'screens//detail_kereta_screen.dart';
import 'screens/success_screen.dart';
import 'kondektur/screens/home_screen.dart';
import 'kondektur/screens/enhanced_enter_code_screen.dart';
import 'kondektur/screens/profile_screen.dart';
import 'kondektur/screens/gps_tracking_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }

  runApp(const TutGoApp());
}

class TutGoApp extends StatelessWidget {
  const TutGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TutGo - Train Tracking App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        primaryColor: const Color(0xFFD75A9E),
        scaffoldBackgroundColor: const Color(0xFFFFF5EE),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        // Auth routes
        '/': (context) => const AuthWrapper(),
        '/account-type': (context) => const AccountTypeScreen(),
        '/user-login': (context) => const UserLoginScreen(),
        '/staff-login': (context) => const StaffLoginScreen(),
        '/user-register': (context) => const UserRegisterScreen(),
        
        // Passenger routes
        '/passenger-main': (context) => const MainNavigationScreen(),
        '/train-code': (context) => const TrainCodeScreen(),
        '/detail': (context) => const DetailKeretaScreen(),
        '/success': (context) => const SuccessScreen(),
        
        // Conductor routes
        '/conductor-home': (context) => const ConductorHomeScreen(),
        '/conductor-enter-code': (context) => const EnhancedEnterCodeScreen(),
        '/conductor-profile': (context) => const ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle conductor tracking route with parameters
        if (settings.name == '/conductor-tracking') {
          final routeCode = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => GPSTrackingScreen(routeCode: routeCode),
          );
        }
        return null;
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
