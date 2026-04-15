import 'package:flutter/material.dart';

class VSColors {
  static const primary = Color(0xFF9B1233);
  static const secondary = Color(0xFFF4B740);
  static const background = Color(0xFFFFFCFA);
  static const surface = Color(0xFFFFF1EA);
  static const text = Color(0xFF3A1F1D);
  static const textSecondary = Color(0xFF8B6F6A);
  static const border = Color(0xFFF0D4CC);
  static const postLoginBackground = Color(0xFFFFF7F2);
  static const shaadiRose = Color(0xFFD9475C);
}

class VSRadius {
  static const xs = Radius.circular(8);
  static const sm = Radius.circular(12);
  static const md = Radius.circular(16);
  static const lg = Radius.circular(20);
  static const xl = Radius.circular(24);
}

class VSSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
}

class VSCard extends StatelessWidget {
  const VSCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(VSSpacing.md),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(VSRadius.md),
        border: Border.all(color: VSColors.border),
      ),
      child: child,
    );
  }
}

class VSGatedContentCard extends StatelessWidget {
  const VSGatedContentCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(VSSpacing.lg),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF0F0),
        borderRadius: BorderRadius.all(VSRadius.sm),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock, size: 24, color: VSColors.primary),
          const SizedBox(height: VSSpacing.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: VSColors.primary,
            ),
          ),
          const SizedBox(height: VSSpacing.xs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: VSColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
