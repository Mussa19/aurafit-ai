import 'package:flutter/material.dart';

class AnalyzeScreen extends StatelessWidget {

  const AnalyzeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Analysis"),
      ),
      body: const Center(
        child: Text(
          "AI analysis results will appear here",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );

  }
}