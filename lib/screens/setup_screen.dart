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
  final TextEditingController _nameController = TextEditingController(); // Для Username
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _saveAndContinue() async {
    if (_emailController.text.isEmpty || 
        _passwordController.text.length < 6 || 
        _nameController.text.isEmpty ||
        _weightController.text.isEmpty || 
        _heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Заполните все поля!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Регистрация
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Сохранение в Firestore (теперь внутри функции!)
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'username': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'weight': _weightController.text.trim(),
        'height': _heightController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ошибка: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text("Create Profile", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildField(_nameController, "Username", Icons.person_outline),
            const SizedBox(height: 15),
            _buildField(_emailController, "Email", Icons.email_outlined),
            const SizedBox(height: 15),
            _buildField(_passwordController, "Password", Icons.lock_outline, isPass: true),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildField(_weightController, "Weight", Icons.monitor_weight_outlined)),
                const SizedBox(width: 15),
                Expanded(child: _buildField(_heightController, "Height", Icons.height)),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, minimumSize: const Size(double.infinity, 55)),
              onPressed: _isLoading ? null : _saveAndContinue,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool isPass = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPass,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}