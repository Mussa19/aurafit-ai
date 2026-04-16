import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/setup_screen.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart';
import 'services/ai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Загрузка переменных окружения
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: .env file not found. AI keys might not work.");
  }
  /// await AiService.initModels();

  // 3. Инициализация Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }
  
  // 4. Проверка состояния пользователя
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
  // Начинаем всегда с темной темы, как подобает AuraFit
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
      
      // СВЕТЛАЯ ТЕМА
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      
      // ТЕМНАЯ ТЕМА (Основная)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F13),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurpleAccent, 
          brightness: Brightness.dark,
          surface: const Color(0xFF1A1A23),
        ),
        useMaterial3: true,
      ),
      
      themeMode: _themeMode,
      
      // Навигация при старте
      home: widget.isSetupComplete 
          ? HomeScreen(onThemeToggle: _toggleTheme) 
          : SetupScreen(onThemeToggle: _toggleTheme),
    );
  }
}
