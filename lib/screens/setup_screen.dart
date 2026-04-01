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

await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
  'username': _nameController.text.trim(), // Добавь это
  'email': _emailController.text.trim(),
  'weight': _weightController.text,
  'height': _heightController.text,
  'createdAt': FieldValue.serverTimestamp(),
});

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // Для пароля
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _saveAndContinue() async {
    // 1. Валидация полей
    if (_emailController.text.isEmpty || 
        _passwordController.text.length < 6 || 
        _weightController.text.isEmpty || 
        _heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Заполните всё! Пароль минимум 6 символов.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Создание пользователя в Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 3. Сохранение веса и роста в Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': _emailController.text.trim(),
        'weight': _weightController.text,
        'height': _heightController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4. Локальное сохранение (SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', _emailController.text);
      await prefs.setBool('is_setup_complete', true);

      if (!mounted) return;
      
      // Переход на главный экран
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );

    } on FirebaseAuthException catch (e) {
      String message = "Ошибка";
      if (e.code == 'email-already-in-use') message = "Этот Email уже занят";
      if (e.code == 'weak-password') message = "Слишком слабый пароль";
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ошибка сервера")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        title: const Text("AuraFit AI"),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.brightness_6), onPressed: widget.onThemeToggle),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text("Create Your Profile", 
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),

              _buildTextField(_emailController, "Email", Icons.email_outlined, false),
              const SizedBox(height: 16),
              
              // НОВОЕ ПОЛЕ: ПАРОЛЬ
              _buildTextField(_passwordController, "Password", Icons.lock_outline, false, isPassword: true),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: _buildTextField(_weightController, "Weight (kg)", Icons.monitor_weight_outlined, true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_heightController, "Height (cm)", Icons.height, true)),
                ],
              ),

              const SizedBox(height: 50),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _isLoading ? null : _saveAndContinue,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isNumber, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.number : TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}