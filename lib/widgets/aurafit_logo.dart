import 'package:flutter/material.dart';

class AuraFitLogo extends StatelessWidget {
  static const String assetPath = 'assets/images/aurafit_logo.png';

  final double size;
  final bool showWordmark;

  const AuraFitLogo({
    super.key,
    this.size = 120,
    this.showWordmark = true,
  });

  @override
  Widget build(BuildContext context) {
    final logo = ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.15),
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallback(context),
      ),
    );

    if (!showWordmark) return logo;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildFallback(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF53D8FB), Color(0xFFB45CFF), Color(0xFFFF4DA6)],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(7),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF11131D),
        ),
        child: Center(
          child: Icon(
            Icons.accessibility_new_rounded,
            size: size * 0.45,
            color: const Color(0xFF8BE9FF),
          ),
        ),
      ),
    );
  }
}
