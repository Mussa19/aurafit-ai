
import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Take Photo")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.camera_alt, size: 100),
            SizedBox(height: 20),
            Text("Camera will analyze your body form", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
