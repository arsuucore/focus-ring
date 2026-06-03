import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ComboDisplay extends StatefulWidget {
  const ComboDisplay({super.key, required this.combo, required this.colors});
  final int       combo;
  final AppColors colors;

  @override
  State<ComboDisplay> createState() => _ComboDisplayState();
}

class _ComboDisplayState extends State<ComboDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _scale = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(ComboDisplay old) {
    super.didUpdateWidget(old);
    if (widget.combo != old.combo && widget.combo > 0) {
      _ctrl.forward(from: 0).then((_) => _ctrl.reverse());
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (widget.combo == 0) return const SizedBox.shrink();
    final color = widget.colors.comboColor(widget.combo);
    return ScaleTransition(
      scale: _scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('×${widget.combo}',
              style: TextStyle(fontFamily: 'monospace', fontSize: 32, fontWeight: FontWeight.w800, color: color, height: 1)),
          const SizedBox(height: 2),
          Text('COMBO',
              style: TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 3, color: color.withValues(alpha: 0.55))),
        ],
      ),
    );
  }
}
