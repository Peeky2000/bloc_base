import 'package:flutter/material.dart';

class HorizontalProgress extends StatelessWidget {
  final double height;
  final double width;
  final double progress;
  final Color? colorProgress;
  final Color? backgroundColorProgress;
  final double? strokeWidth;
  final EdgeInsets insert;
  final BorderRadius? borderRadius;

  const HorizontalProgress({
    Key? key,
    required this.progress,
    this.colorProgress,
    this.backgroundColorProgress,
    this.height = 16.0,
    this.width = double.infinity,
    this.strokeWidth,
    this.insert = const EdgeInsets.all(4.0),
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CustomPaint(
        painter: _HorizontalProgressPainter(
            progress: progress,
            progressColor: colorProgress,
            backgroundProgressColor: backgroundColorProgress,
            strokeWidth: strokeWidth,
            padding: insert,
            borderRadius: borderRadius,
        ),
      ),
    );
  }
}

class AnimationHorizontalProgress extends StatefulWidget {
  final double height;
  final double width;
  final double fromValue;
  final double toValue;
  final Color? colorProgress;
  final Color? backgroundColorProgress;
  final double? strokeWidth;
  final EdgeInsets insert;
  final Duration duration;
  final bool repeat;
  final BorderRadius? borderRadius;

  const AnimationHorizontalProgress({
    Key? key,
    required this.fromValue,
    required this.toValue,
    this.colorProgress,
    this.backgroundColorProgress,
    this.height = 16.0,
    this.width = double.infinity,
    this.strokeWidth,
    this.insert = const EdgeInsets.all(4.0),
    this.duration = const Duration(seconds: 30),
    this.repeat = false,
    this.borderRadius,
  }) : super(key: key);

  @override
  _AnimationHorizontalProgressState createState() => _AnimationHorizontalProgressState();
}

class _AnimationHorizontalProgressState extends State<AnimationHorizontalProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween(begin: widget.fromValue, end: widget.toValue).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    _animationController.forward();
    if (widget.repeat) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: CustomPaint(
        painter: _HorizontalProgressPainter(
          progress: _animation.value,
          progressColor: widget.colorProgress,
          backgroundProgressColor: widget.backgroundColorProgress,
          strokeWidth: widget.strokeWidth,
          padding: widget.insert,
          borderRadius: widget.borderRadius,
        ),
      ),
    );
  }
}

class _HorizontalProgressPainter extends CustomPainter {
  final double progress;
  final Color? progressColor;
  final Color? backgroundProgressColor;
  final double? strokeWidth;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;

  _HorizontalProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundProgressColor,
    this.strokeWidth,
    required this.padding,
    this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundProgressPaint = Paint()
      ..color = backgroundProgressColor ?? Colors.blue.withOpacity(0.25)
      ..strokeWidth = size.height;

    Paint progressPaint = Paint()
      ..color = progressColor ?? Colors.blue
      ..strokeWidth = strokeWidth ?? size.height - padding.top - padding.bottom;

    canvas.drawRRect(
        RRect.fromLTRBAndCorners(0.0, 0.0, size.width, size.height,
            topRight: borderRadius?.topRight ?? Radius.circular(size.height / 4.0),
            bottomLeft: borderRadius?.bottomLeft ?? Radius.circular(size.height / 4.0),
            topLeft: borderRadius?.topLeft ?? Radius.circular(size.height / 4.0),
            bottomRight: borderRadius?.bottomRight ?? Radius.circular(size.height / 4.0)),
        backgroundProgressPaint);

    canvas.drawRRect(
        RRect.fromLTRBAndCorners(
            padding.left,
            padding.top,
            (size.width - padding.left) * progress / 100.0 +
                (100.0 - progress) / 100.0 * padding.left,
            size.height - padding.bottom,
            topRight: borderRadius?.topRight ?? Radius.circular((size.height - padding.bottom - padding.top) / 4.0),
            bottomLeft: borderRadius?.bottomLeft ?? Radius.circular((size.height - padding.bottom - padding.top) / 4.0),
            topLeft: borderRadius?.topLeft ?? Radius.circular((size.height - padding.bottom - padding.top) / 4.0),
            bottomRight: borderRadius?.bottomRight ?? Radius.circular((size.height - padding.bottom - padding.top) / 4.0)),
        progressPaint);
  }

  @override
  bool shouldRepaint(covariant _HorizontalProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
