import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'ring_config.dart';

class FocusRingWidget extends StatefulWidget {
  const FocusRingWidget({
    super.key,
    required this.config,
    required this.enabled,
    required this.combo,
    required this.colors,
    this.onResult,
  });

  final RingConfig config;
  final bool       enabled;
  final int        combo;
  final AppColors  colors;
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

  AnimationController _buildController() => AnimationController(
    vsync: this,
    duration: Duration(milliseconds: widget.config.withCombo(widget.combo).rotationDurationMs),
  );

  @override
  void didUpdateWidget(FocusRingWidget old) {
    super.didUpdateWidget(old);
    if (widget.combo != old.combo && widget.enabled) {
      final v = _rotationCtrl.value;
      _rotationCtrl.dispose();
      _rotationCtrl = _buildController();
      _rotationCtrl.value = v;
      _rotationCtrl.repeat();
      return;
    }
    if (widget.enabled && !old.enabled)       _rotationCtrl.repeat();
    else if (!widget.enabled && old.enabled)  _rotationCtrl.stop();
  }

  @override
  void dispose() { _rotationCtrl.dispose(); super.dispose(); }

  TapResult _classify(double value) {
    double dist = value > 0.5 ? 1.0 - value : value;
    if (dist <= widget.config.perfectWindowFraction / 2) return TapResult.perfect;
    if (dist <= widget.config.goodWindowFraction    / 2) return TapResult.good;
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
        cursor: widget.enabled ? SystemMouseCursors.click : MouseCursor.defer,
        child: SizedBox(
          width: size, height: size,
          child: AnimatedBuilder(
            animation: _rotationCtrl,
            builder: (_, __) => CustomPaint(
              painter: _RingPainter(
                config:         cfg,
                progress:       _rotationCtrl.value,
                enabled:        widget.enabled,
                colors:         widget.colors,
                indicatorColor: widget.colors.comboColor(widget.combo),
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
    required this.colors,
    required this.indicatorColor,
  });

  final RingConfig config;
  final double     progress;
  final bool       enabled;
  final AppColors  colors;
  final Color      indicatorColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center  = Offset(size.width / 2, size.height / 2);
    final radius  = config.ringDiameter / 2;
    final strokeW = config.trackWidth;

    // Track
    canvas.drawCircle(center, radius,
        Paint()..color = colors.trackColor..style = PaintingStyle.stroke..strokeWidth = strokeW);

    if (!enabled) {
      canvas.drawCircle(center, radius,
          Paint()..color = colors.trackColor.withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = strokeW);
      return;
    }

    final goodHalf    = (config.goodWindowFraction    / 2) * 2 * math.pi;
    final perfectHalf = (config.perfectWindowFraction / 2) * 2 * math.pi;
    const topAngle    = -math.pi / 2;
    final arcRect     = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(arcRect, topAngle - goodHalf, goodHalf * 2, false,
        Paint()..color = colors.targetGood..style = PaintingStyle.stroke..strokeWidth = strokeW..strokeCap = StrokeCap.butt);
    canvas.drawArc(arcRect, topAngle - perfectHalf, perfectHalf * 2, false,
        Paint()..color = colors.targetPerfect..style = PaintingStyle.stroke..strokeWidth = strokeW..strokeCap = StrokeCap.butt);

    final angle  = (progress * 2 * math.pi) - math.pi / 2;
    final dotPos = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));

    // Trail
    canvas.drawArc(arcRect, angle - 0.08 * 2 * math.pi, 0.08 * 2 * math.pi, false,
        Paint()..color = indicatorColor.withValues(alpha: 0.25)..style = PaintingStyle.stroke..strokeWidth = strokeW * 0.6..strokeCap = StrokeCap.round);

    // Glow
    canvas.drawCircle(dotPos, strokeW * 0.7,
        Paint()..color = indicatorColor.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // Dot
    canvas.drawCircle(dotPos, strokeW * 0.46, Paint()..color = indicatorColor);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.enabled != enabled ||
      old.indicatorColor != indicatorColor || old.colors != colors;
}
