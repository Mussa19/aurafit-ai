import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: .env file not found. AI keys might not work.');
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  final isSetupComplete = prefs.getBool('is_setup_complete') ?? false;
  final initialThemeMode = await ThemeService.loadThemeMode();

  runApp(
    AuraFitApp(
      isSetupComplete: isSetupComplete,
      initialThemeMode: initialThemeMode,
    ),
  );
}

class AuraFitApp extends StatefulWidget {
  final bool isSetupComplete;
  final ThemeMode initialThemeMode;

  const AuraFitApp({
    super.key,
    required this.isSetupComplete,
    required this.initialThemeMode,
  });

  @override
  State<AuraFitApp> createState() => _AuraFitAppState();
}

class _AuraFitAppState extends State<AuraFitApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  ThemeMode _getNextThemeMode() {
    if (_themeMode == ThemeMode.system) {
      final isDark = WidgetsBinding
              .instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
      return isDark ? ThemeMode.light : ThemeMode.dark;
    }

    return _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> _toggleTheme() async {
    final nextMode = _getNextThemeMode();
    setState(() {
      _themeMode = nextMode;
    });
    await ThemeService.saveThemeMode(nextMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AuraFit AI',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: SplashScreen(
        isSetupComplete: widget.isSetupComplete,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}
