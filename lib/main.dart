import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/otp_login_screen.dart';
import 'dashboards/student_dashboard.dart';
import 'dashboards/contributor_dashboard.dart';
// import 'dashboards/parent_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(); // Load .env variables
    await Firebase.initializeApp(); // Firebase init
    runApp(const MyApp());
  } catch (e) {
    print('❌ Initialization failed: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learning Nest',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/login-otp': (context) => const OtpLoginScreen(),

        // Dashboards based on role
        '/student-dashboard': (context) => const StudentDashboard(),
        '/contributor-dashboard': (context) => const ContributorDashboard(),

        // '/parent-dashboard': (context) => const ParentDashboard(),
      },
    );
  }
}
