import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'setup_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const ProfileScreen({super.key, required this.onThemeToggle});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, String> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          userData = {
            'name': prefs.getString('user_name') ?? 'User',
            'goal': prefs.getString('user_goal') ?? 'Fitness',
            'weight': prefs.getString('user_weight') ?? '70',
            'height': prefs.getString('user_height') ?? '175',
          };
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F13),
        body: Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        title: const Text("PRO-FILE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurpleAccent,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            
            _buildInfoCard("Name", userData['name'] ?? 'User'),
            _buildInfoCard("Goal", userData['goal'] ?? 'Fitness'),
            
            Row(
              children: [
                Expanded(child: _buildInfoCard("Weight", "${userData['weight']} kg")),
                const SizedBox(width: 10),
                Expanded(child: _buildInfoCard("Height", "${userData['height']} cm")),
              ],
            ),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // ИСПРАВЛЕНО: с .withOpacity на .withValues
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () async {
                  // Очищаем Firebase Auth
                  await FirebaseAuth.instance.signOut();
                  // Очищаем локальные данные
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  
                  if (!mounted) return;
                  
                  // Возвращаем на SetupScreen и очищаем историю навигации
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => SetupScreen(onThemeToggle: widget.onThemeToggle)),
                    (route) => false,
                  );
                },
                child: const Text("LOG OUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A23),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}