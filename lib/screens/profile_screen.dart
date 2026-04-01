import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'setup_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  
  // Контроллеры для редактирования
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Загружаем текущие данные из Firestore
  Future<void> _loadUserData() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        setState(() {
          _nameController.text = doc.data()?['username'] ?? "";
          _emailController.text = user!.email ?? "";
          _weightController.text = doc.data()?['weight'] ?? "";
          _heightController.text = doc.data()?['height'] ?? "";
          _isLoading = false;
        });
      }
    }
  }

  // Функция сохранения обновлений
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      // 1. Обновляем почту в Firebase Auth (если она изменилась)
      if (_emailController.text != user!.email) {
        await user!.updateEmail(_emailController.text.trim());
      }

      // 2. Обновляем данные в Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'username': _nameController.text.trim(),
        'weight': _weightController.text.trim(),
        'height': _heightController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Профиль успешно обновлен!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.greenAccent),
            onPressed: _updateProfile,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.deepPurpleAccent,
              child: Icon(Icons.edit, color: Colors.white),
            ),
            const SizedBox(height: 30),
            
            _buildEditField(_nameController, "Username", Icons.person_outline),
            const SizedBox(height: 16),
            _buildEditField(_emailController, "Email", Icons.email_outlined),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: _buildEditField(_weightController, "Weight (kg)", Icons.monitor_weight_outlined, isNumber: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildEditField(_heightController, "Height (cm)", Icons.height, isNumber: true)),
              ],
            ),
            
            const SizedBox(height: 40),
            
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
            ),
            
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SetupScreen()), (route) => false);
              },
              child: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}