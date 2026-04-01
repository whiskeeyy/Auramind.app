import 'dart:ui';
import 'package:flutter/material.dart';

// ===========================================================================
// AURA THEME — Digital Soul Mirror Design System
// Implements: Aurora UI, Claymorphism, Glassmorphism
// ===========================================================================

class AuraTheme {
  AuraTheme._();

  // ─── Brand Colors ────────────────────────────────────────────────────────

  /// Primary violet/purple — brand color
  static const Color brandPrimary = Color(0xFF6C63FF);
  static const Color brandSecondary = Color(0xFF9C8FFF);
  static const Color brandAccent = Color(0xFFA78BFA);

  // ─── Dark Palette (replaces pure black) ──────────────────────────────────
  /// Use these instead of Colors.black

  static const Color darkNavy = Color(0xFF0F0E2A);       // deepest dark
  static const Color darkMidnight = Color(0xFF1B1A3B);   // navigation bg
  static const Color darkDeepBlue = Color(0xFF1E2040);   // card bg dark
  static const Color darkViolet = Color(0xFF2D1B4E);     // tinted dark purple
  static const Color darkSlate = Color(0xFF252542);      // surface dark

  // ─── Mood Color Palettes ─────────────────────────────────────────────────
  /// Tích cực (8–10): Sunny warmth

  static const Color moodHighStart = Color(0xFFFFD700);  // Golden
  static const Color moodHighMid   = Color(0xFFFF8FAB);  // Coral rose
  static const Color moodHighEnd   = Color(0xFFFFA94D);  // Warm amber

  /// Bình yên (5–7): Calm teal-lavender
  static const Color moodMidStart  = Color(0xFF5EEAD4);  // Teal
  static const Color moodMidMid    = Color(0xFFE0F2FE);  // Pale sky
  static const Color moodMidEnd    = Color(0xFFC4B5FD);  // Lavender

  /// Cần xoa dịu (1–4): Deep calming blues
  static const Color moodLowStart  = Color(0xFF1E3A5F);  // Deep blue
  static const Color moodLowMid    = Color(0xFF2C4A7C);  // Navy blue
  static const Color moodLowEnd    = Color(0xFF3D3B6E);  // Warm navy

  // ─── Neutral Palette ──────────────────────────────────────────────────────
  static const Color textOnDark     = Color(0xFFF0EFFF);
  static const Color textSubtle     = Color(0xFFB0ADDF);
  static const Color surfaceLight   = Color(0xFFF8F7FF);
  static const Color outlineLight   = Color(0xFFE8E5FF);

  // ─── Mood Gradient Helpers ───────────────────────────────────────────────

  /// Returns gradient based on mood score (1–10)
  static LinearGradient moodGradient(double moodScore, {bool isDark = false}) {
    if (moodScore >= 7.5) {
      // Tích cực
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFE66D), Color(0xFFFF8FAB), Color(0xFFFF6B6B)],
        stops: [0.0, 0.5, 1.0],
      );
    } else if (moodScore >= 5.0) {
      // Bình yên
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF5EEAD4), Color(0xFF93C5FD), Color(0xFFC4B5FD)],
        stops: [0.0, 0.5, 1.0],
      );
    } else {
      // Cần xoa dịu
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [const Color(0xFF0F1729), const Color(0xFF1E2D4F), const Color(0xFF2D1B4E)]
            : [const Color(0xFF1E3A5F), const Color(0xFF2C4A7C), const Color(0xFF3D3B6E)],
        stops: const [0.0, 0.5, 1.0],
      );
    }
  }

  /// Aurora overlay colors (semi-transparent, animated)
  static List<Color> auroraColors(double moodScore) {
    if (moodScore >= 7.5) {
      return [
        const Color(0xFFFFD700).withOpacity(0.3),
        const Color(0xFFFF8FAB).withOpacity(0.25),
        const Color(0xFF6C63FF).withOpacity(0.2),
      ];
    } else if (moodScore >= 5.0) {
      return [
        const Color(0xFF5EEAD4).withOpacity(0.3),
        const Color(0xFF93C5FD).withOpacity(0.25),
        const Color(0xFFC4B5FD).withOpacity(0.2),
      ];
    } else {
      return [
        const Color(0xFF1E3A5F).withOpacity(0.5),
        const Color(0xFF2C4A7C).withOpacity(0.4),
        const Color(0xFF3D3B6E).withOpacity(0.3),
      ];
    }
  }

  // ─── Glassmorphism ──────────────────────────────────────────────────────

  /// Standard glassmorphism decoration
  static BoxDecoration glassMorphism({
    Color? tint,
    double opacity = 0.15,
    double blur = 20.0,
    double borderRadius = 20.0,
    double borderOpacity = 0.2,
  }) {
    return BoxDecoration(
      color: (tint ?? Colors.white).withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(borderOpacity),
        width: 1.0,
      ),
    );
  }

  /// Richer glassmorphism with box shadow
  static BoxDecoration glassMorphismElevated({
    Color? tint,
    double opacity = 0.12,
    double borderRadius = 24.0,
    Color? shadowColor,
  }) {
    return BoxDecoration(
      color: (tint ?? Colors.white).withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(0.25),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: (shadowColor ?? const Color(0xFF6C63FF)).withOpacity(0.08),
          blurRadius: 24,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // ─── Claymorphism ────────────────────────────────────────────────────────

  /// Claymorphism for floating elements (Avatar, Badges, CTAs)
  static BoxDecoration clayMorphism({
    required Color color,
    double borderRadius = 28.0,
    double outerShadowOpacity = 0.12,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        // Outer shadow (depth)
        BoxShadow(
          color: color.withOpacity(outerShadowOpacity),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
        // Inner highlight (top-left bright)
        BoxShadow(
          color: Colors.white.withOpacity(0.35),
          blurRadius: 12,
          spreadRadius: -4,
          offset: const Offset(-4, -4),
        ),
        // Inner shadow (bottom-right subtle depth)
        BoxShadow(
          color: color.withOpacity(0.25),
          blurRadius: 8,
          spreadRadius: -4,
          offset: const Offset(4, 4),
        ),
      ],
    );
  }

  /// Claymorphism gradient button style
  static BoxDecoration clayButton({
    required List<Color> gradientColors,
    double borderRadius = 20.0,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: gradientColors.last.withOpacity(0.4),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.3),
          blurRadius: 8,
          spreadRadius: -2,
          offset: const Offset(-2, -2),
        ),
      ],
    );
  }

  // ─── Card Decorations ────────────────────────────────────────────────────

  /// Standard Aura card (glass surface)
  static BoxDecoration auraCard({
    required BuildContext context,
    double borderRadius = 24.0,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1E2040).withOpacity(0.8)
          : Colors.white.withOpacity(0.85),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : const Color(0xFF6C63FF).withOpacity(0.08),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF6C63FF).withOpacity(isDark ? 0.12 : 0.06),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  // ─── Typography Helpers ──────────────────────────────────────────────────

  static TextStyle headlineStyle({
    Color? color,
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: -0.5,
      height: 1.2,
    );
  }

  static TextStyle bodyStyle({
    Color? color,
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height ?? 1.6,
    );
  }

  // ─── Color from Mood Score ────────────────────────────────────────────────

  static Color moodColor(double score) {
    if (score >= 8) return const Color(0xFF22C55E);   // Emerald green
    if (score >= 6) return const Color(0xFF3B82F6);   // Blue
    if (score >= 4) return const Color(0xFFF59E0B);   // Amber
    return const Color(0xFF8B5CF6);                    // Purple (soothing, not alarming red)
  }

  static Color stressColor(double score) {
    if (score <= 3) return const Color(0xFF22C55E);
    if (score <= 5) return const Color(0xFF3B82F6);
    if (score <= 7) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  static Color energyColor(double score) {
    if (score >= 7) return const Color(0xFFFFD700);
    if (score >= 5) return const Color(0xFF60A5FA);
    return const Color(0xFF94A3B8);
  }

  // ─── Semantic Colors (Empathy-first) ─────────────────────────────────────
  static const Color successSoft  = Color(0xFF34D399);  // Soft emerald
  static const Color warningSoft  = Color(0xFFFBBF24);  // Soft amber
  static const Color errorSoft    = Color(0xFFF87171);  // Soft rose (not alarming red)
  static const Color infoSoft     = Color(0xFF60A5FA);  // Soft blue
}

// ===========================================================================
// GLASSMORPHISM CLIPPER WIDGET
// Convenience wrapper with BackdropFilter + glass decoration
// ===========================================================================

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color? tint;
  final double opacity;
  final double borderOpacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? shadowColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20.0,
    this.blur = 20.0,
    this.tint,
    this.opacity = 0.12,
    this.borderOpacity = 0.22,
    this.padding,
    this.margin,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (tint ?? Colors.white).withOpacity(opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(borderOpacity),
                width: 1.0,
              ),
              boxShadow: shadowColor != null
                  ? [
                      BoxShadow(
                        color: shadowColor!.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// CLAY PRESS WRAPPER
// Wraps any widget with claymorphism press-down animation
// ===========================================================================

class ClayPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressScale;

  const ClayPressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressScale = 0.96,
  });

  @override
  State<ClayPressable> createState() => _ClayPressableState();
}

class _ClayPressableState extends State<ClayPressable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: widget.pressScale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) {
    _controller.reverse();
    widget.onTap?.call();
  }
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(scale: _scaleAnim, child: widget.child),
    );
  }
}
