// Sahay Police Control Response App (Flutter — 24 Screens UI Architecture)
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const SahayPoliceApp());
}

class SahayPoliceApp extends StatelessWidget {
  const SahayPoliceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahay Police PCR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.bgColor,
        fontFamily: 'Roboto', // Standardized font
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bgColor,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
