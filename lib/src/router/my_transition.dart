import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

CustomTransitionPage<T> buildTransition<T>({
  required Widget child,
  required Color color,
  String? name,
  Object? arguments,
  String? restorationId,
  LocalKey? key,
}) =>
    CustomTransitionPage<T>(
      key: key,
      name: name,
      child: child,
      arguments: arguments,
      restorationId: restorationId,
      transitionDuration: const Duration(milliseconds: 700),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          _MyReveal(animation: animation, color: color, child: child),
    );

class _MyReveal extends StatefulWidget {
  const _MyReveal({
    required this.animation,
    required this.color,
    required this.child,
  });

  final Animation<double> animation;
  final Color color;
  final Widget child;

  @override
  State<_MyReveal> createState() => _MyRevealState();
}

class _MyRevealState extends State<_MyReveal> {
  static final _log = Logger('_InkRevealState');
  final _tween = Tween(begin: const Offset(0, -1), end: Offset.zero);

  bool _finished = false;

  @override
  void initState() {
    super.initState();
    widget.animation.addStatusListener(_statusListener);
  }

  @override
  void didUpdateWidget(covariant _MyReveal oldWidget) {
    if (oldWidget.animation != widget.animation) {
      oldWidget.animation.removeStatusListener(_statusListener);
      widget.animation.addStatusListener(_statusListener);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_statusListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      SlideTransition(
        position: _tween.animate(CurvedAnimation(
          parent: widget.animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeOutCubic,
        )),
        child: Container(color: widget.color),
      ),
      AnimatedOpacity(
        opacity: _finished ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: widget.child,
      ),
    ]);
  }

  void _statusListener(AnimationStatus status) {
    _log.fine(() => 'status: $status');
    setState(() => _finished = status == AnimationStatus.completed);
  }
}
