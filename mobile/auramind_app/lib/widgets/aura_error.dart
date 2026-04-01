import 'package:flutter/material.dart';
import '../utils/aura_theme.dart';

// ===========================================================================
// AURA ERROR WIDGET — Empathy-first error states
// Following ui_ux_guidelines.md: "Lỗi cũng phải tinh tế"
// NO red scary banners, use illustrations + gentle tone
// ===========================================================================

enum AuraErrorType {
  network,    // Mất kết nối
  server,     // Lỗi server
  empty,      // Không có dữ liệu
  auth,       // Chưa đăng nhập
  generic,    // Lỗi khác
}

class AuraErrorView extends StatelessWidget {
  final AuraErrorType type;
  final String? customMessage;
  final String? customAction;
  final VoidCallback? onRetry;
  final bool compact; // compact = true for inline, false for full screen

  const AuraErrorView({
    super.key,
    this.type = AuraErrorType.generic,
    this.customMessage,
    this.customAction,
    this.onRetry,
    this.compact = false,
  });

  _ErrorContent _buildContent() {
    switch (type) {
      case AuraErrorType.network:
        return _ErrorContent(
          emoji: '🌐',
          title: 'Mạng đang chập chờn...',
          message: customMessage ??
              'Không sao đâu, bạn cứ nghỉ ngơi. Hệ thống sẽ thử kết nối lại sau nhé!',
          actionLabel: customAction ?? 'Thử lại',
        );
      case AuraErrorType.server:
        return _ErrorContent(
          emoji: '🤖',
          title: 'Aura đang nghỉ ngơi...',
          message: customMessage ??
              'Hệ thống đang bận xíu. Bạn hãy thư giãn một lúc, mình sẽ quay lại ngay!',
          actionLabel: customAction ?? 'Thử lại',
        );
      case AuraErrorType.empty:
        return _ErrorContent(
          emoji: '🌱',
          title: 'Chưa có dữ liệu',
          message: customMessage ??
              'Hành trình của bạn đang chờ để bắt đầu. Hãy thực hiện check-in đầu tiên nhé!',
          actionLabel: customAction ?? 'Bắt đầu nào',
        );
      case AuraErrorType.auth:
        return _ErrorContent(
          emoji: '🔒',
          title: 'Cần đăng nhập',
          message: customMessage ??
              'Phiên đăng nhập của bạn đã hết hạn. Đăng nhập lại để tiếp tục nhé!',
          actionLabel: customAction ?? 'Đăng nhập',
        );
      case AuraErrorType.generic:
        return _ErrorContent(
          emoji: '💫',
          title: 'Có điều gì đó...',
          message: customMessage ??
              'Đã xảy ra sự cố nhỏ. Đừng lo, bạn hãy thử lại sau nhé!',
          actionLabel: customAction ?? 'Thử lại',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();

    if (compact) {
      return _CompactError(content: content, onRetry: onRetry);
    }

    return _FullError(content: content, onRetry: onRetry);
  }
}

// ─── Full-screen error ────────────────────────────────────────────────────

class _FullError extends StatelessWidget {
  final _ErrorContent content;
  final VoidCallback? onRetry;

  const _FullError({required this.content, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji illustration with glow
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AuraTheme.brandPrimary.withOpacity(0.08),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AuraTheme.brandPrimary.withOpacity(0.12),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  content.emoji,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Title
            Text(
              content.title,
              style: AuraTheme.headlineStyle(
                fontSize: 20,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              content.message,
              style: AuraTheme.bodyStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ClayPressable(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  decoration: AuraTheme.clayButton(
                    gradientColors: [
                      AuraTheme.brandSecondary,
                      AuraTheme.brandPrimary,
                    ],
                  ),
                  child: Text(
                    content.actionLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Compact inline error ─────────────────────────────────────────────────

class _CompactError extends StatelessWidget {
  final _ErrorContent content;
  final VoidCallback? onRetry;

  const _CompactError({required this.content, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: AuraTheme.glassMorphism(
        tint: AuraTheme.brandPrimary,
        opacity: 0.06,
        borderRadius: 16,
      ),
      child: Row(
        children: [
          Text(content.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  content.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AuraTheme.brandPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                textStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
              ),
              child: Text(content.actionLabel),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Data class ───────────────────────────────────────────────────────────

class _ErrorContent {
  final String emoji;
  final String title;
  final String message;
  final String actionLabel;

  const _ErrorContent({
    required this.emoji,
    required this.title,
    required this.message,
    required this.actionLabel,
  });
}

// ===========================================================================
// AURA TOAST — Replaces SnackBar with a glass floating notification
// ===========================================================================

enum AuraToastType { success, warning, error, info }

class AuraToast {
  static void show(
    BuildContext context, {
    required String message,
    AuraToastType type = AuraToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _AuraToastWidget(
        message: message,
        type: type,
        onDismiss: () => entry.remove(),
        duration: duration,
      ),
    );

    overlay.insert(entry);
  }

  static String _emojiForType(AuraToastType type) {
    switch (type) {
      case AuraToastType.success: return '✨';
      case AuraToastType.warning: return '🌤️';
      case AuraToastType.error:   return '💫';
      case AuraToastType.info:    return '🌿';
    }
  }

  static Color _colorForType(AuraToastType type) {
    switch (type) {
      case AuraToastType.success: return AuraTheme.successSoft;
      case AuraToastType.warning: return AuraTheme.warningSoft;
      case AuraToastType.error:   return AuraTheme.errorSoft;
      case AuraToastType.info:    return AuraTheme.infoSoft;
    }
  }
}

class _AuraToastWidget extends StatefulWidget {
  final String message;
  final AuraToastType type;
  final VoidCallback onDismiss;
  final Duration duration;

  const _AuraToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_AuraToastWidget> createState() => _AuraToastWidgetState();
}

class _AuraToastWidgetState extends State<_AuraToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();

    Future.delayed(widget.duration, () async {
      if (mounted) {
        await _ctrl.reverse();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AuraToast._colorForType(widget.type);
    final emoji = AuraToast._emojiForType(widget.type);

    return Positioned(
      bottom: MediaQuery.of(context).viewInsets.bottom + 80,
      left: 24,
      right: 24,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Material(
            color: Colors.transparent,
            child: GlassContainer(
              borderRadius: 16,
              blur: 20,
              tint: color,
              opacity: 0.15,
              borderOpacity: 0.25,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
