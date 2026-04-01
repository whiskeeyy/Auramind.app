import 'package:flutter/material.dart';
import '../utils/aura_theme.dart';

// ===========================================================================
// AURA LOADING WIDGET
// Replaces the generic CircularProgressIndicator throughout the app
// ===========================================================================

/// Full-screen loading state — use when initial data is loading
class AuraLoadingScreen extends StatelessWidget {
  final String? message;

  const AuraLoadingScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AuraSpinner(size: 56),
          if (message != null) ...[
            const SizedBox(height: 24),
            Text(
              message!,
              style: AuraTheme.bodyStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Inline loading indicator — use inside buttons or small areas
class AuraSpinner extends StatefulWidget {
  final double size;
  final List<Color>? colors;

  const AuraSpinner({
    super.key,
    this.size = 36,
    this.colors,
  });

  @override
  State<AuraSpinner> createState() => _AuraSpinnerState();
}

class _AuraSpinnerState extends State<AuraSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ??
        [
          AuraTheme.brandPrimary,
          AuraTheme.brandAccent,
          AuraTheme.moodMidStart,
          AuraTheme.brandPrimary,
        ];

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => CustomPaint(
          painter: _AuraSpinnerPainter(
            progress: _controller.value,
            colors: colors,
          ),
        ),
      ),
    );
  }
}

class _AuraSpinnerPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  _AuraSpinnerPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;
    final strokeWidth = size.width * 0.09;

    // Background arc (very subtle)
    final bgPaint = Paint()
      ..color = colors.first.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Gradient arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepAngle = 1.5 * 3.14159; // 270 degrees

    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: sweepAngle,
      colors: colors,
      tileMode: TileMode.repeated,
      transform: GradientRotation(progress * 2 * 3.14159),
    );

    final arcPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      progress * 2 * 3.14159 - 1.57, // start from top
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_AuraSpinnerPainter old) => old.progress != progress;
}

// ===========================================================================
// AI THINKING INDICATOR
// Aura "glowing" state when AI is processing — replaces "Aura is typing..."
// ===========================================================================

class AuraThinkingIndicator extends StatefulWidget {
  final String text;

  const AuraThinkingIndicator({
    super.key,
    this.text = 'Aura đang suy nghĩ...',
  });

  @override
  State<AuraThinkingIndicator> createState() => _AuraThinkingIndicatorState();
}

class _AuraThinkingIndicatorState extends State<AuraThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.3, end: 1.0).animate(
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated glowing orbs (3 dots)
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => Row(
                children: List.generate(3, (i) {
                  final offset = (i * 0.33);
                  final opacity = (((_controller.value + offset) % 1.0));
                  final smoothOpacity = (opacity < 0.5)
                      ? opacity * 2
                      : (1.0 - opacity) * 2;
                  return Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: Opacity(
                      opacity: smoothOpacity.clamp(0.2, 1.0),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: const RadialGradient(colors: [
                            AuraTheme.brandAccent,
                            AuraTheme.brandPrimary,
                          ]),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AuraTheme.brandPrimary.withOpacity(
                                  smoothOpacity.clamp(0.0, 0.6)),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedBuilder(
              animation: _glow,
              builder: (_, __) => Opacity(
                opacity: 0.4 + (_glow.value * 0.6),
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loading for dashboard cards
class AuraCardSkeleton extends StatelessWidget {
  final double height;
  final double? width;

  const AuraCardSkeleton({super.key, this.height = 120, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: AuraTheme.auraCard(context: context),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerRow(width: 120, height: 14),
          const SizedBox(height: 12),
          ShimmerRow(width: double.infinity, height: 10),
          const SizedBox(height: 8),
          ShimmerRow(width: 180, height: 10),
        ],
      ),
    );
  }
}

class ShimmerRow extends StatefulWidget {
  final double width;
  final double height;

  const ShimmerRow({super.key, required this.width, required this.height});

  @override
  State<ShimmerRow> createState() => _ShimmerRowState();
}

class _ShimmerRowState extends State<ShimmerRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
    _anim = Tween<double>(begin: -1.5, end: 2.5).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF252542) : const Color(0xFFE8E5FF);
    final hi = isDark ? const Color(0xFF3D3B6E) : const Color(0xFFF0EFFF);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(
            stops: [
              (_anim.value - 1).clamp(0.0, 1.0),
              _anim.value.clamp(0.0, 1.0),
              (_anim.value + 1).clamp(0.0, 1.0),
            ],
            colors: [base, hi, base],
          ),
        ),
      ),
    );
  }
}
