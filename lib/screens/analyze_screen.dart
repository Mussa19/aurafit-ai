import 'package:flutter/material.dart';

import 'home_screen.dart';

class AnalyzeScreen extends StatelessWidget {
  final dynamic result;
  final bool isBody;
  final VoidCallback onThemeToggle;

  const AnalyzeScreen({
    super.key,
    required this.result,
    required this.onThemeToggle,
    this.isBody = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined),
            onPressed: onThemeToggle,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isBody ? Colors.blue : Colors.orange).withValues(alpha: 0.12),
              ),
              child: Icon(
                isBody ? Icons.accessibility_new_rounded : Icons.fastfood_rounded,
                size: 60,
                color: isBody ? Colors.blueAccent : Colors.orangeAccent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isBody ? 'Body Composition' : 'Nutrition Detected',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 26),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: scheme.outline.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: scheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'AI ANALYSIS',
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.65),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 30, color: scheme.outline.withValues(alpha: 0.3)),
                  Text(
                    result.toString(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(onThemeToggle: onThemeToggle),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Done', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Retake Photo'),
            ),
          ],
        ),
      ),
    );
  }
}
