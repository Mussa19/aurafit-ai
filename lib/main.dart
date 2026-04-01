import 'package:flutter/material.dart';
import 'screens/setup_screen.dart';

void main() {
  runApp(const AuraFitApp());
}

class AuraFitApp extends StatefulWidget {
  const AuraFitApp({super.key});

  @override
  State<AuraFitApp> createState() => _AuraFitAppState();
}

class _AuraFitAppState extends State<AuraFitApp> {
 
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "AuraFit AI",
      // Define Light Theme
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      // Define Dark Theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      themeMode: _themeMode, // This tells the app which theme to show
      home: SetupScreen(onThemeToggle: _toggleTheme),
    );
  }
}