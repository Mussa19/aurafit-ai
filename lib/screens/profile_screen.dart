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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        setState(() {
          _nameController.text = doc.data()?['username'] ?? "";
          _weightController.text = doc.data()?['weight'] ?? "";
          _heightController.text = doc.data()?['height'] ?? "";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "PRO-FILE", 
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900) // Исправлено здесь
        ),
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Стильный статичный аватар
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.deepPurpleAccent, blurRadius: 20, spreadRadius: -5)
                        ],
                        gradient: LinearGradient(colors: [Colors.deepPurpleAccent, Colors.cyanAccent]),
                      ),
                      child: const CircleAvatar(
                        radius: 55,
                        backgroundColor: Color(0xFF1A1A23),
                        child: Icon(Icons.bolt, size: 50, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Блоки данных
                  _buildGlassField(_nameController, "NICKNAME", Icons.person_outline),
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Expanded(child: _buildGlassField(_weightController, "WEIGHT", Icons.fitness_center)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildGlassField(_heightController, "HEIGHT", Icons.straighten)),
                    ],
                  ),
                  
                  const SizedBox(height: 40),

                  // Кнопка сохранения
                  GestureDetector(
                    onTap: () async {
                      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
                        'username': _nameController.text,
                        'weight': _weightController.text,
                        'height': _heightController.text,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Profile Synced ⚡"),
                          backgroundColor: Colors.deepPurpleAccent,
                        )
                      );
                    },
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: const LinearGradient(colors: [Colors.deepPurpleAccent, Colors.purple]),
                        boxShadow: [
                          BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                        ],
                      ),
                      child: const Center(
                        child: Text("UPDATE DATA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  
                  // Кнопка выхода
                  TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SetupScreen()), (route) => false);
                    },
                    child: Text(
                      "SIGN OUT", 
                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12, letterSpacing: 1)
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGlassField(TextEditingController ctrl, String label, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: const TextStyle(color: Colors.deepPurpleAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: ctrl,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white38, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}