import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'theme/theme_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/complete_profile_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/edit_profile_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const PreDiaCareApp());
}

class PreDiaCareApp extends StatelessWidget {
  const PreDiaCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PreDiaCare',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/complete-profile': (context) => const CompleteProfileScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),




      },
    );
  }
}
