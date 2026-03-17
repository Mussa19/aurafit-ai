import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AuraFitApp());
}

class AuraFitApp extends StatelessWidget {
  const AuraFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "AuraFit AI",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}