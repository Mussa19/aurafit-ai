import 'package:flutter/material.dart';
import '../widgets/aurafit_logo.dart';
import 'home_screen.dart';
import 'setup_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool isSetupComplete;
  final VoidCallback onThemeToggle;

  const SplashScreen({
    super.key,
    required this.isSetupComplete,
    required this.onThemeToggle,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _moveNext();
  }

  Future<void> _moveNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => widget.isSetupComplete
            ? HomeScreen(onThemeToggle: widget.onThemeToggle)
            : SetupScreen(onThemeToggle: widget.onThemeToggle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF080A12), Color(0xFF101728)],
          ),
        ),
        child: const Center(
          child: AuraFitLogo(size: 170),
        ),
      ),
    );
  }
}
