import 'package:flutter/material.dart';

class VSColors {
  static const primary = Color(0xFF8F102F);
  static const secondary = Color(0xFFE6A93A);
  static const background = Color(0xFFFFFBF5);
  static const surface = Color(0xFFFFEFE7);
  static const text = Color(0xFF2F1716);
  static const textSecondary = Color(0xFF846A63);
  static const border = Color(0xFFEFD2C4);
  static const postLoginBackground = Color(0xFFFFF5ED);
  static const shaadiRose = Color(0xFFE44C62);
  static const wineDark = Color(0xFF5F0924);
  static const sandal = Color(0xFFFFE3B0);
  static const blush = Color(0xFFFFDCE3);
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
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
