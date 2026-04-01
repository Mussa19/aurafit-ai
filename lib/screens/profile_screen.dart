import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'setup_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(title: const Text("Profile"), backgroundColor: Colors.transparent),
      body: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final prefs = snapshot.data as SharedPreferences;
          
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildInfoTile("Email", prefs.getString('user_email') ?? "Not set"),
              _buildInfoTile("Weight", "${prefs.getString('user_weight')} kg"),
              _buildInfoTile("Height", "${prefs.getString('user_height')} cm"),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () async {
                  await prefs.clear(); // Сброс всех данных
                  Navigator.pushAndRemoveUntil(context, 
                    MaterialPageRoute(builder: (_) => const SetupScreen()), (route) => false);
                },
                child: const Text("Logout & Reset"),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.grey)),
      trailing: Text(value, style: const TextStyle(color: Colors.white, fontSize: 18)),
    );
  }
}