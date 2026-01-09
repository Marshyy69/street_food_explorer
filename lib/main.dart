import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart'; // Start at Login

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Street Food Explorer',
      
      // --- THE NEW "BROWN-ISH" THEME ---
      theme: ThemeData(
        useMaterial3: true,
        
        // 1. Color Palette
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E342E), // Dark Brown
          primary: const Color(0xFF4E342E),
          secondary: const Color(0xFFD84315), // Burnt Orange
          surface: const Color(0xFFFDFBF7),   // Cream Background
        ),
        
        // 2. Background Colors
        scaffoldBackgroundColor: const Color(0xFFFDFBF7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFDFBF7),
          elevation: 0,
          foregroundColor: Color(0xFF4E342E), // Brown Text/Icons
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF4E342E),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),

        // 3. Button Styling (Rounded & Brown)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4E342E), // Brown Buttons
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            elevation: 3,
          ),
        ),

        // 4. Input Fields (Clean outlines)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.brown.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.brown.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD84315), width: 2),
          ),
          prefixIconColor: Colors.brown.shade400,
        ),
      ),
      
      home: const LoginScreen(),
    );
  }
}