import 'package:flutter/material.dart';
import 'home_screen.dart';

class AnalyzeScreen extends StatelessWidget {
  final dynamic result; 
  final bool isBody;    

  const AnalyzeScreen({
    super.key, 
    required this.result, 
    this.isBody = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13), 
      appBar: AppBar(
        title: const Text("AI Insights"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isBody ? Colors.blue : Colors.orange).withOpacity(0.1),
              ),
              child: Icon(
                isBody ? Icons.accessibility_new_rounded : Icons.fastfood_rounded,
                size: 60,
                color: isBody ? Colors.blueAccent : Colors.orangeAccent,
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              isBody ? "Body Composition" : "Nutrition Detected",
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 24, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 30),

            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.purpleAccent[100], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        "AI ANALYSIS",
                        style: TextStyle(color: Colors.grey, letterSpacing: 1.2, fontSize: 12),
                      ),
                    ],
                  ),
                  const Divider(height: 30, color: Colors.white10),
                  Text(
                    result.toString(),
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 18, 
                      height: 1.6,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false, 
                );
              },
              child: const Text("Done", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Retake Photo", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}