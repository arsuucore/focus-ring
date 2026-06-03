import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../shared/widgets/ring_config.dart';

class FocusRingWidget extends StatefulWidget {
  const FocusRingWidget({
    super.key,
    required this.config,
    required this.enabled,
    required this.combo,
    this.onResult,
  });

  final RingConfig config;
  final bool enabled;
  final int combo;
  final void Function(TapResult)? onResult;

  @override
  State<FocusRingWidget> createState() => _FocusRingWidgetState();
}

class _FocusRingWidgetState extends State<FocusRingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationCtrl;

  @override
  void initState() {
    super.initState();
    _rotationCtrl = _buildController();
    if (widget.enabled) _rotationCtrl.repeat();
  }

  AnimationController _buildController() {
    final cfg = widget.config.withCombo(widget.combo);
    return AnimationController(
      vsync: this,
      duration: Duration(milliseconds: cfg.rotationDurationMs),
    );
  }

  @override
  void didUpdateWidget(FocusRingWidget old) {
    super.didUpdateWidget(old);

    // Speed changed — rebuild controller preserving position.
    if (widget.combo != old.combo && widget.enabled) {
      final value = _rotationCtrl.value;
      _rotationCtrl.dispose();
      _rotationCtrl = _buildController();
      _rotationCtrl.value = value;
      _rotationCtrl.repeat();
      return;
    }

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

  /// Combo-driven accent color: white → yellow → orange → red.
  static Color _comboColor(int combo) {
    if (combo >= 7) return const Color(0xFFFF3333);
    if (combo >= 5) return const Color(0xFFFF8800);
    if (combo >= 3) return const Color(0xFFFFDD00);
    return const Color(0xFFE0E0FF);
  }

  @override
  Widget build(BuildContext context) {
    final cfg  = widget.config;
    final size = cfg.ringDiameter + cfg.trackWidth;

    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: widget.enabled ? SystemMouseCursors.click : MouseCursor.defer,
        child: SizedBox(
          width: size,
          height: size,
          child: AnimatedBuilder(
            animation: _rotationCtrl,
            builder: (_, __) => CustomPaint(
              painter: _RingPainter(
                config:        cfg,
                progress:      _rotationCtrl.value,
                enabled:       widget.enabled,
                indicatorColor: _comboColor(widget.combo),
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
    required this.indicatorColor,
  });

  final RingConfig config;
  final double progress;
  final bool enabled;
  final Color indicatorColor;

  static const Color _trackColor    = Color(0xFF1A1A2E);
  static const Color _targetPerfect = Color(0xFFFFFFFF);
  static const Color _targetGood    = Color(0xFF555570);
  static const Color _disabledColor = Color(0xFF2A2A3E);

  @override
  void paint(Canvas canvas, Size size) {
    final center  = Offset(size.width / 2, size.height / 2);
    final radius  = config.ringDiameter / 2;
    final strokeW = config.trackWidth;

    canvas.drawCircle(center, radius,
        Paint()..color = _trackColor..style = PaintingStyle.stroke..strokeWidth = strokeW);

    if (!enabled) {
      canvas.drawCircle(center, radius,
          Paint()..color = _disabledColor..style = PaintingStyle.stroke..strokeWidth = strokeW);
      return;
    }

    final goodHalf    = (config.goodWindowFraction    / 2) * 2 * math.pi;
    final perfectHalf = (config.perfectWindowFraction / 2) * 2 * math.pi;
    const topAngle    = -math.pi / 2;
    final arcRect     = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(arcRect, topAngle - goodHalf, goodHalf * 2, false,
        Paint()..color = _targetGood..style = PaintingStyle.stroke..strokeWidth = strokeW..strokeCap = StrokeCap.butt);
    canvas.drawArc(arcRect, topAngle - perfectHalf, perfectHalf * 2, false,
        Paint()..color = _targetPerfect..style = PaintingStyle.stroke..strokeWidth = strokeW..strokeCap = StrokeCap.butt);

    final angle  = (progress * 2 * math.pi) - math.pi / 2;
    final dotPos = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));

    // Trail
    final trailColor = indicatorColor.withValues(alpha: 0.25);
    canvas.drawArc(arcRect, angle - 0.08 * 2 * math.pi, 0.08 * 2 * math.pi, false,
        Paint()..color = trailColor..style = PaintingStyle.stroke..strokeWidth = strokeW * 0.6..strokeCap = StrokeCap.round);

    // Glow
    canvas.drawCircle(dotPos, strokeW * 0.7,
        Paint()..color = indicatorColor.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // Dot
    canvas.drawCircle(dotPos, strokeW * 0.46, Paint()..color = indicatorColor);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.enabled != enabled || old.indicatorColor != indicatorColor;
}
