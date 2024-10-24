import 'package:flutter/material.dart';

class BlinkText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Color? beginColor;
  final Color? endColor;
  final Duration? duration;
  final Curve curve;
  final TextAlign? textAlign;
  final bool isRepeat;

  const BlinkText(
    this.text, {
    Key? key,
    this.style,
    this.beginColor,
    this.endColor,
    this.duration,
    this.curve = Curves.easeInOut,
    this.textAlign,
    this.isRepeat = true,
  }) : super(key: key);

  @override
  State<BlinkText> createState() => _BlinkTextState();
}

class _BlinkTextState extends State<BlinkText> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _animationColor;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationColor = ColorTween(
            begin: widget.beginColor ?? Colors.white,
            end: widget.endColor ?? const Color(0xFFFD3549))
        .animate(CurvedAnimation(parent: _animationController, curve: widget.curve));
    _animationColor.addListener(() {
    });
    _animationController.forward();
    if (widget.isRepeat) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationColor,
        builder: (context, child) {
          return Text(
            widget.text,
            style: widget.style?.copyWith(color: _animationColor.value),
            textAlign: widget.textAlign,
          );
        });
  }
}
