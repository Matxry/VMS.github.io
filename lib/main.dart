import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const VMSSportsApp());
}

class VMSSportsApp extends StatelessWidget {
  const VMSSportsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D1B2A),
          primary: const Color(0xFF0D1B2A),
          secondary: const Color(0xFF1A3A5C),
          surface: const Color(0xFFF2F4F6),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F4F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1B2A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF2F4F6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1A3A5C), width: 1.5),
          ),
          labelStyle: const TextStyle(color: Color(0xFF5C6B7A)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D1B2A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0D1B2A),
            side: const BorderSide(color: Color(0xFF0D1B2A)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF0D1B2A)),
          bodyMedium: TextStyle(color: Color(0xFF0D1B2A)),
          titleMedium: TextStyle(color: Color(0xFF0D1B2A), fontWeight: FontWeight.w600),
        ),
        dividerColor: const Color(0xFFB0BEC5),
      ),
      home: const HomeScreen(),
    );
  }
}
