import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../shared/widgets/ring_config.dart';

/// The core gameplay widget.  Identical hit-detection logic to the original;
/// web-compatible because [GestureDetector.onTap] fires on mouse-click too.
class FocusRingWidget extends StatefulWidget {
  const FocusRingWidget({
    super.key,
    required this.config,
    required this.enabled,
    this.onResult,
  });

  final RingConfig config;
  final bool enabled;
  final void Function(TapResult)? onResult;

  @override
  State<FocusRingWidget> createState() => _FocusRingWidgetState();
}

class _FocusRingWidgetState extends State<FocusRingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationCtrl;

  @override
  void initState() {
    super.initState();
    _rotationCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.config.rotationDurationMs),
    );
    if (widget.enabled) _rotationCtrl.repeat();
  }

  @override
  void didUpdateWidget(FocusRingWidget old) {
    super.didUpdateWidget(old);
    if (widget.enabled && !old.enabled) {
      _rotationCtrl.repeat();
    } else if (!widget.enabled && old.enabled) {
      _rotationCtrl.stop();
    }
  }

  @override
  void dispose() {
    _rotationCtrl.dispose();
    super.dispose();
  }

  TapResult _classify(double value) {
    double dist = value > 0.5 ? 1.0 - value : value;
    if (dist <= widget.config.perfectWindowFraction / 2) return TapResult.perfect;
    if (dist <= widget.config.goodWindowFraction / 2)    return TapResult.good;
    return TapResult.miss;
  }

  void _onTap() {
    if (!widget.enabled || widget.onResult == null) return;
    widget.onResult!(_classify(_rotationCtrl.value));
  }

  @override
  Widget build(BuildContext context) {
    final cfg  = widget.config;
    final size = cfg.ringDiameter + cfg.trackWidth;

    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        // Show a pointer cursor on web so the ring feels clickable.
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : MouseCursor.defer,
        child: SizedBox(
          width: size,
          height: size,
          child: AnimatedBuilder(
            animation: _rotationCtrl,
            builder: (_, __) => CustomPaint(
              painter: _RingPainter(
                config: cfg,
                progress: _rotationCtrl.value,
                enabled: widget.enabled,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.config,
    required this.progress,
    required this.enabled,
  });

  final RingConfig config;
  final double progress;
  final bool enabled;

  static const Color _trackColor     = Color(0xFF1A1A2E);
  static const Color _targetPerfect  = Color(0xFFFFFFFF);
  static const Color _targetGood     = Color(0xFF555570);
  static const Color _indicatorColor = Color(0xFFE0E0FF);
  static const Color _indicatorTrail = Color(0x33E0E0FF);
  static const Color _disabledColor  = Color(0xFF2A2A3E);

  @override
  void paint(Canvas canvas, Size size) {
    final center  = Offset(size.width / 2, size.height / 2);
    final radius  = config.ringDiameter / 2;
    final strokeW = config.trackWidth;

    canvas.drawCircle(
      center, radius,
      Paint()
        ..color       = _trackColor
        ..style       = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    if (!enabled) {
      canvas.drawCircle(
        center, radius,
        Paint()
          ..color       = _disabledColor
          ..style       = PaintingStyle.stroke
          ..strokeWidth = strokeW,
      );
      return;
    }

    final goodHalf    = (config.goodWindowFraction    / 2) * 2 * math.pi;
    final perfectHalf = (config.perfectWindowFraction / 2) * 2 * math.pi;
    const topAngle    = -math.pi / 2;
    final arcRect     = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      arcRect, topAngle - goodHalf, goodHalf * 2, false,
      Paint()
        ..color       = _targetGood
        ..style       = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap   = StrokeCap.butt,
    );

    canvas.drawArc(
      arcRect, topAngle - perfectHalf, perfectHalf * 2, false,
      Paint()
        ..color       = _targetPerfect
        ..style       = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap   = StrokeCap.butt,
    );

    final angle  = (progress * 2 * math.pi) - math.pi / 2;
    final dotPos = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    const trailFraction = 0.08;
    final trailSweep    = trailFraction * 2 * math.pi;
    canvas.drawArc(
      arcRect, angle - trailSweep, trailSweep, false,
      Paint()
        ..color       = _indicatorTrail
        ..style       = PaintingStyle.stroke
        ..strokeWidth = strokeW * 0.6
        ..strokeCap   = StrokeCap.round,
    );

    canvas.drawCircle(dotPos, strokeW * 0.46, Paint()..color = _indicatorColor);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.enabled != enabled;
}
