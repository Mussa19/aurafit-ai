import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; 
import '../services/ai_service.dart';
import 'analyze_screen.dart';

class CameraScreen extends StatefulWidget {
  final VoidCallback onThemeToggle; // Добавлено
  const CameraScreen({super.key, required this.onThemeToggle});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool isBodyMode = false;
  bool isLoading = false;
  final ImagePicker picker = ImagePicker();

  Future<void> _captureAndAnalyze() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => isLoading = true);

    try {
      final Uint8List imageBytes = await image.readAsBytes();
      
      String result = await AiService.analyzeImage(
        imageBytes, 
        isBodyMode ? "body" : "food"
      );

      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalyzeScreen(
            result: result, 
            isBody: isBodyMode,
            onThemeToggle: widget.onThemeToggle, // Передаем функцию темы
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка: ${e.toString()}"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      body: Stack(
        children: [
          Center(
            child: isLoading 
              ? const CircularProgressIndicator(color: Colors.deepPurpleAccent)
              : const Icon(Icons.camera_alt, color: Colors.white12, size: 100),
          ),
          if (!isLoading) Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isBodyMode ? 260 : 300,
              height: isBodyMode ? 520 : 300,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isBodyMode ? Colors.cyanAccent : Colors.orangeAccent, 
                  width: 2
                ),
                borderRadius: BorderRadius.circular(isBodyMode ? 130 : 30),
              ),
              child: Center(
                child: Text(
                  isBodyMode ? "ALIGN BODY" : "PLACE FOOD",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModeButton("FOOD", !isBodyMode),
                    const SizedBox(width: 40),
                    _buildModeButton("BODY", isBodyMode),
                  ],
                ),
                const SizedBox(height: 35),
                GestureDetector(
                  onTap: isLoading ? null : _captureAndAnalyze,
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: isLoading ? Colors.transparent : Colors.white, 
                          shape: BoxShape.circle
                        ),
                        child: isLoading 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : const Icon(Icons.photo_library, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => isBodyMode = label == "BODY"),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.white38,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}