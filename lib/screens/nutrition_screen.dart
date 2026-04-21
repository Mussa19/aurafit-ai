import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ai_service.dart';
import 'analyze_screen.dart'; // Добавляем импорт
import 'dart:typed_data';

class NutritionScreen extends StatefulWidget {
  final VoidCallback onThemeToggle; // Добавляем параметр
  const NutritionScreen({super.key, required this.onThemeToggle});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  bool _isLoading = false;

  Future<void> _scanFood() async {
    final picker = ImagePicker();
    // Для удобства пользователя лучше дать выбор или использовать галерею
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isLoading = true);
      
      try {
        final Uint8List imageBytes = await image.readAsBytes();
        
        // Анализируем изображение через сервис
        final response = await AiService.analyzeImage(imageBytes, "food");
        
        if (!mounted) return;

        // Вместо вывода текста здесь, переходим на экран результата
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AnalyzeScreen(
              result: response,
              onThemeToggle: widget.onThemeToggle,
              isBody: false,
            ),
          ),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${e.toString()}")),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        title: const Text("Nutrition AI", style: TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Делаем более привлекательный интерфейс для сканера
            Icon(
              Icons.fastfood_outlined,
              size: 100,
              color: Colors.deepPurpleAccent.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 30),
            const Text(
              "Food Scanner",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Take a photo of your meal to calculate\ncalories and macronutrients instantly.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 50),
            
            if (_isLoading) 
              const CircularProgressIndicator(color: Colors.deepPurpleAccent)
            else
              ElevatedButton.icon(
                onPressed: _scanFood,
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text("SCAN MY MEAL", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 5,
                ),
              ),
          ],
        ),
      ),
    );
  }
}