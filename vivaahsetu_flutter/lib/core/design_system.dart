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
  static const ivory = Color(0xFFFFFAF1);
  static const roseMist = Color(0xFFFFEEF1);
  static const goldMist = Color(0xFFFFF2D1);
  static const inkSoft = Color(0xFF5D4540);
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
  static const xl = 32.0;
}

class VSGradients {
  static const matrimonialHero = LinearGradient(
    colors: [VSColors.wineDark, VSColors.primary, VSColors.shaadiRose],
    stops: [0, 0.48, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const appBackground = LinearGradient(
    colors: [VSColors.ivory, VSColors.roseMist, VSColors.goldMist],
    begin: Alignment.topCenter,
    end: Alignment.bottomRight,
  );

  static const goldAccent = LinearGradient(
    colors: [VSColors.secondary, Color(0xFFFFD98A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
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
        gradient: const LinearGradient(
          colors: [Colors.white, VSColors.ivory],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.all(VSRadius.lg),
        border: Border.all(color: VSColors.border.withValues(alpha: 0.84)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class VSPageShell extends StatelessWidget {
  const VSPageShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: VSGradients.appBackground),
      child: child,
    );
  }
}

class VSStatusBadge extends StatelessWidget {
  const VSStatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.foreground = VSColors.primary,
    this.background = VSColors.roseMist,
  });

  final String label;
  final IconData? icon;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
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
