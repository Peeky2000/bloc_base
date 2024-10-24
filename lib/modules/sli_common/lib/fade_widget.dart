import 'package:flutter/material.dart';

class FadeWidget extends StatefulWidget {
  final Widget? child;
  final bool show;
  final Curve curve;
  final Duration duration;
  final double beginOpacity;
  final double endOpacity;

  const FadeWidget({
    Key? key,
    this.child,
    this.show = false,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 500),
    this.beginOpacity = 0.0,
    this.endOpacity = 1.0,
  }) : super(key: key);

  @override
  State<FadeWidget> createState() => _FadeWidgetState();
}

class _FadeWidgetState extends State<FadeWidget> with TickerProviderStateMixin {
  late AnimationController fadeController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
  }

  ///Setting up the animation
  void prepareAnimations() {
    fadeController = AnimationController(vsync: this, duration: widget.duration);
    animation = Tween(
      begin: widget.beginOpacity,
      end: widget.endOpacity,
    ).animate(fadeController);
  }

  void _runExpandCheck() {
    if (widget.show) {
      fadeController.forward();
    } else {
      fadeController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: widget.child,
    );
  }
}
