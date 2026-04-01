import 'package:flutter/material.dart';

// ===========================================================================
// AURA ANIMATIONS — Shared animation configs & route transitions
// ===========================================================================

class AuraAnimations {
  AuraAnimations._();

  // ─── Durations ────────────────────────────────────────────────────────────
  static const Duration instant    = Duration(milliseconds: 100);
  static const Duration fast       = Duration(milliseconds: 200);
  static const Duration normal     = Duration(milliseconds: 350);
  static const Duration slow       = Duration(milliseconds: 500);
  static const Duration verySlow   = Duration(milliseconds: 800);

  // ─── Curves ───────────────────────────────────────────────────────────────
  static const Curve standard  = Curves.easeInOut;
  static const Curve enter     = Curves.easeOut;
  static const Curve exit      = Curves.easeIn;
  static const Curve spring    = Curves.elasticOut;
  static const Curve smooth    = Curves.fastOutSlowIn;

  // ─── Stagger helper ───────────────────────────────────────────────────────
  /// Returns a delay for staggered list animations
  static Duration stagger(int index, {Duration step = const Duration(milliseconds: 60)}) {
    return step * index;
  }
}

// ===========================================================================
// PAGE ROUTE TRANSITIONS
// ===========================================================================

/// Fade + slight vertical slide — the Aura default transition
class AuraPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Offset beginOffset;

  AuraPageRoute({
    required this.page,
    this.beginOffset = const Offset(0.0, 0.04),
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AuraAnimations.normal,
          reverseTransitionDuration: AuraAnimations.fast,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fade = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            );
            final slide = Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ));

            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: slide, child: child),
            );
          },
        );
}

/// Horizontal slide left — for forward navigation
class AuraSlideRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  AuraSlideRoute({required this.page, super.settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AuraAnimations.normal,
          reverseTransitionDuration: AuraAnimations.fast,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slide = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ));
            final fade = Tween<double>(begin: 0.0, end: 1.0)
                .animate(CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
            ));

            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: slide, child: child),
            );
          },
        );
}

// ===========================================================================
// STAGGERED FADE-IN LIST ITEM
// ===========================================================================

class StaggeredFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset beginOffset;

  const StaggeredFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.beginOffset = const Offset(0, 0.08),
  });

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slide = Tween<Offset>(begin: widget.beginOffset, end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ===========================================================================
// ANIMATED NUMBER COUNTER
// ===========================================================================

class AnimatedCounter extends StatefulWidget {
  final double value;
  final int decimalPlaces;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.decimalPlaces = 1,
    this.style,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;
  double _from = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.duration);
    _anim = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _from = old.value;
      _anim = Tween<double>(begin: _from, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Text(
        _anim.value.toStringAsFixed(widget.decimalPlaces),
        style: widget.style,
      ),
    );
  }
}

// ===========================================================================
// PULSE ANIMATION WRAPPER
// ===========================================================================

class PulseWidget extends StatefulWidget {
  final Widget child;
  final double minOpacity;
  final Duration period;

  const PulseWidget({
    super.key,
    required this.child,
    this.minOpacity = 0.4,
    this.period = const Duration(milliseconds: 1400),
  });

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 1.0, end: widget.minOpacity)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _anim, child: widget.child);
  }
}

// ===========================================================================
// SHIMMER EFFECT
// ===========================================================================

class ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF252542)
        : const Color(0xFFE8E5FF);
    final highlightColor = isDark
        ? const Color(0xFF3D3B6E)
        : const Color(0xFFF0EFFF);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [
              (_anim.value - 1).clamp(0.0, 1.0),
              _anim.value.clamp(0.0, 1.0),
              (_anim.value + 1).clamp(0.0, 1.0),
            ],
            colors: [baseColor, highlightColor, baseColor],
          ),
        ),
      ),
    );
  }
}
