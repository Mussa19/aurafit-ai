import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/ai_service.dart';
import '../widgets/aurafit_logo.dart';
import 'analyze_screen.dart';

class NutritionScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const NutritionScreen({super.key, required this.onThemeToggle});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _scanFood() async {
    if (_isLoading) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Сфотографировать еду'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Выбрать фото из галереи'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final image = await _picker.pickImage(
      source: source,
      imageQuality: 92,
      maxWidth: 2200,
    );

    if (image == null) return;

    setState(() => _isLoading = true);

    try {
      final Uint8List imageBytes = await image.readAsBytes();
      final response = await AiService.analyzeImage(imageBytes, 'food');

      if (!mounted) return;

      await Navigator.push(
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition AI'),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AuraFitLogo(size: 100),
            const SizedBox(height: 20),
            Icon(
              Icons.fastfood_outlined,
              size: 92,
              color: scheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'Food Scanner',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Сфотографируй прием пищи или выбери фото,\nи AI рассчитает КБЖУ.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.75),
                  ),
            ),
            const SizedBox(height: 36),
            if (_isLoading)
              CircularProgressIndicator(color: scheme.primary)
            else
              ElevatedButton.icon(
                onPressed: _scanFood,
                icon: const Icon(Icons.photo_camera_rounded),
                label: const Text(
                  'СКАНИРОВАТЬ ЕДУ',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
