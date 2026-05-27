import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/ai_service.dart';
import 'analyze_screen.dart';

class CameraScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const CameraScreen({super.key, required this.onThemeToggle});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker picker = ImagePicker();
  final bool isBodyMode = true;
  bool isLoading = false;

  Future<void> _chooseSourceAndAnalyze() async {
    if (isLoading) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Сфотографировать'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Выбрать из галереи'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;
    await _captureAndAnalyze(source);
  }

  Future<void> _captureAndAnalyze(ImageSource source) async {
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 92,
      maxWidth: 2200,
    );
    if (image == null) return;

    setState(() => isLoading = true);

    try {
      final Uint8List imageBytes = await image.readAsBytes();

      final result = await AiService.analyzeImage(
        imageBytes,
        'body',
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalyzeScreen(
            result: result,
            isBody: true,
            onThemeToggle: widget.onThemeToggle,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Camera'),
      ),
      body: Stack(
        children: [
          Center(
            child: isLoading
                ? CircularProgressIndicator(color: scheme.primary)
                : Icon(
                    Icons.camera_alt,
                    color: scheme.onSurface.withValues(alpha: 0.2),
                    size: 110,
                  ),
          ),
          if (!isLoading)
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                width: 260,
                height: 520,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.cyanAccent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(130),
                ),
                child: Center(
                  child: Text(
                    'ALIGN BODY',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 56,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _chooseSourceAndAnalyze,
                      child: Container(
                        height: 82,
                        width: 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: scheme.onSurface, width: 3),
                        ),
                        child: Center(
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: isLoading ? Colors.transparent : scheme.onSurface,
                              shape: BoxShape.circle,
                            ),
                            child: isLoading
                                ? CircularProgressIndicator(color: scheme.primary)
                                : Icon(Icons.photo_camera, color: scheme.surface),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    OutlinedButton.icon(
                      onPressed: _chooseSourceAndAnalyze,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Галерея/Камера'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
