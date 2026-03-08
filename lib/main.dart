import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AuraFitAI());
}

class AuraFitAI extends StatelessWidget {
  const AuraFitAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuraFit AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1E), // Dark modern feel
      ),
      home: const HomeScreen(),
    );
  }
}а