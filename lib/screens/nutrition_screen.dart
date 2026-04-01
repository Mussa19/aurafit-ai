import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/ai_service.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  String _result = "Scan your food to see calories.";
  bool _isLoading = false;

  Future<void> _scanFood() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() => _isLoading = true);
      // Вызываем наш обновленный сервис
      final response = await AiService.analyzeFood(File(image.path));
      setState(() {
        _result = response;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(title: const Text("Nutrition AI"), backgroundColor: Colors.transparent),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) const CircularProgressIndicator(color: Colors.deepPurpleAccent),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(_result, style: const TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _scanFood,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Scan Food"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
            ),
          ],
        ),
      ),
    );
  }
}