import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Не забудь добавить пакет в pubspec.yaml
import 'home_screen.dart';

class SetupScreen extends StatefulWidget {
  final VoidCallback? onThemeToggle;

  const SetupScreen({super.key, this.onThemeToggle});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  // Функция сохранения данных
  Future<void> _saveAndContinue() async {
    // 1. Валидация
    if (_weightController.text.isEmpty || _heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your weight and height")),
      );
      return;
    }

    // 2. Сохранение в память телефона
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', _emailController.text);
    await prefs.setString('user_weight', _weightController.text);
    await prefs.setString('user_height', _heightController.text);
    await prefs.setBool('is_setup_complete', true); // Флаг, что вход выполнен

    // 3. Переход на главный экран без возможности вернуться назад
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        title: const Text("AuraFit AI"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Create Your Profile",
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text("This helps the AI personalize your plan", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),

              _buildTextField(_emailController, "Email", Icons.email_outlined, false),
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
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _saveAndContinue,
                child: const Text("Continue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isNumber) {
    return TextField(
      controller: controller,
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