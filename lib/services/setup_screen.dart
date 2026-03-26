import 'package:flutter/material.dart';
import 'camera_screen.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter your info",
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(labelText: "Weight"),
            ),
            TextField(
              decoration: InputDecoration(labelText: "Height"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CameraScreen(),
                  ),
                );
              },
              child: const Text("Continue"),
            )
          ],
        ),
      ),
    );
  }
}