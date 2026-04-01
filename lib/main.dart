import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/setup_screen.dart';
import 'screens/home_screen.dart';

void main() async {
 
  WidgetsFlutterBinding.ensureInitialized();
  
  
  final prefs = await SharedPreferences.getInstance();
  final bool isSetupComplete = prefs.getBool('is_setup_complete') ?? false;

  runApp(AuraFitApp(isSetupComplete: isSetupComplete));
}

class AuraFitApp extends StatefulWidget {
  final bool isSetupComplete;
  const AuraFitApp({super.key, required this.isSetupComplete});

  @override
  State<AuraFitApp> createState() => _AuraFitAppState();
}

class _AuraFitAppState extends State<AuraFitApp> {
  
  ThemeMode _themeMode = ThemeMode.dark; 

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
      
      
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F13), 
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      themeMode: _themeMode,

      
      home: widget.isSetupComplete 
          ? const HomeScreen() 
          : SetupScreen(onThemeToggle: _toggleTheme),
    );
  }
}