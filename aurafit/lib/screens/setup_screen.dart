import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class SetupScreen extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  const SetupScreen({super.key, this.onThemeToggle});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    // Обязательно освобождаем ресурсы
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (_emailController.text.isEmpty || 
        _passwordController.text.length < 6 || 
        _nameController.text.isEmpty ||
        _weightController.text.isEmpty || 
        _heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Заполните все поля (пароль мин. 6 симв.)!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Регистрация в Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Сохранение в Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'username': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'weight': _weightController.text.trim(),
        'height': _heightController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Локальное сохранение данных
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_setup_complete', true);
      await prefs.setString('user_name', _nameController.text.trim());
      await prefs.setString('user_weight', _weightController.text.trim());
      await prefs.setString('user_height', _heightController.text.trim());

      if (!mounted) return;

      // 4. Переход на HomeScreen
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (_) => HomeScreen(onThemeToggle: widget.onThemeToggle ?? () {})
        )
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ошибка: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F13),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.wb_sunny_outlined, color: Colors.white),
              onPressed: widget.onThemeToggle,
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "AuraFit AI",
                style: TextStyle(
                  color: Colors.deepPurpleAccent, 
                  fontSize: 32, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2
                )
              ),
              const SizedBox(height: 8),
              const Text(
                "Create your fitness profile", 
                style: TextStyle(color: Colors.white70, fontSize: 16)
              ),
              const SizedBox(height: 40),
              _buildField(_nameController, "Username", Icons.person_outline),
              const SizedBox(height: 15),
              _buildField(_emailController, "Email", Icons.email_outlined, type: TextInputType.emailAddress),
              const SizedBox(height: 15),
              _buildField(_passwordController, "Password", Icons.lock_outline, isPass: true),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildField(_weightController, "Weight (kg)", Icons.monitor_weight_outlined, type: TextInputType.number)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildField(_heightController, "Height (cm)", Icons.height, type: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, 
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                onPressed: _isLoading ? null : _saveAndContinue,
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text("Get Started", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, 
      {bool isPass = false, TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      obscureText: isPass,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
        filled: true,
        // ИСПРАВЛЕНО: .withValues вместо .withOpacity
        fillColor: Colors.white.withValues(alpha: 0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), 
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), 
          borderSide: const BorderSide(color: Colors.deepPurpleAccent)
        ),
      ),
    );
  }
}