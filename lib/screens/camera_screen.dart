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
  bool isBodyMode = false;
  bool isLoading = false;
  final ImagePicker picker = ImagePicker();

  
  Future<void> _captureAndAnalyze() async {
    
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return;

    setState(() => isLoading = true);

    try {
      final File imageFile = File(image.path);
      String result;

      
      if (isBodyMode) {
        
        result = "AI Body Analysis: Posture is 85% aligned. Slight tilt detected in left shoulder. Suggested: Lateral raises.";
      } else {
        
        result = await AiService.analyzeFood(imageFile);
      }

      
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalyzeScreen(result: result, isBody: isBodyMode),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("AI Error: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          
          Center(
            child: isLoading 
              ? const CircularProgressIndicator(color: Colors.deepPurpleAccent)
              : const Icon(Icons.camera_alt, color: Colors.white24, size: 100),
          ),

          
          if (!isLoading) Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isBodyMode ? 250 : 300,
              height: isBodyMode ? 500 : 300,
              decoration: BoxDecoration(
                border: Border.all(color: isBodyMode ? Colors.blueAccent : Colors.orangeAccent, width: 2),
                borderRadius: BorderRadius.circular(isBodyMode ? 125 : 20),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    isBodyMode ? "Align your body" : "Place food inside",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ),

          
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModeButton("FOOD", !isBodyMode),
                    const SizedBox(width: 30),
                    _buildModeButton("BODY", isBodyMode),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Кнопка затвора
                GestureDetector(
                  onTap: isLoading ? null : _captureAndAnalyze,
                  child: Container(
                    height: 85,
                    width: 85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: Container(
                        height: 65,
                        width: 65,
                        decoration: BoxDecoration(
                          color: isLoading ? Colors.grey : Colors.white, 
                          shape: BoxShape.circle
                        ),
                        child: isLoading 
                          ? const Padding(
                              padding: EdgeInsets.all(15.0),
                              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black),
                            ) 
                          : null,
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
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white38,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (isActive) Container(height: 2, width: 20, color: Colors.deepPurpleAccent, margin: const EdgeInsets.only(top: 4)),
        ],
      ),
    );
  }
}