import 'package:flutter/material.dart';
import 'analyze_screen.dart'; // Import this to navigate after scanning

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Animation duration: 2 seconds to go from top to bottom
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // Makes it bounce up and down
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up the controller when leaving the screen
    super.dispose();
  }

  void _onCapture() {
    // Navigate to Analyze Screen to simulate AI processing
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnalyzeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("AI Food Scanner"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // 1. Dark Placeholder for Camera Feed
          Center(
            child: Icon(
              Icons.fastfood, 
              size: 150, 
              color: Colors.white.withOpacity(0.1),
            ),
          ),

          // 2. The Animated Scanning Line
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                // Use the animation value (0.0 to 1.0) to set the vertical position
                top: _controller.value * MediaQuery.of(context).size.height * 0.7,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.8),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 3. Capture Button Overlay
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  "Scanning for nutritional data...",
                  style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.w300),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _onCapture,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Icon(Icons.camera, color: Colors.white, size: 40),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}