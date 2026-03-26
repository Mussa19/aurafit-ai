import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/ai_service.dart';
import 'analyze_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker picker = ImagePicker();
  bool isLoading = false; // Added to track AI status

  Future<void> pickImage() async {
    // 1. Changed to .gallery because you are on Windows
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      isLoading = true; // Show loading spinner
    });

    try {
      final File imageFile = File(image.path);

      // 🔥 AI анализ
      final result = await AiService.analyzeFood(imageFile);

      // 👉 переход на анализ
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalyzeScreen(result: result),
        ),
      );
    } catch (e) {
      // Handle errors (like bad API key or no internet)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false; // Hide loading spinner
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Food"),
      ),
      body: Center(
        child: isLoading 
          ? const CircularProgressIndicator() // Show spinner when busy
          : ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text("Pick Food Image (Gallery)"),
            ),
      ),
    );
  }
}