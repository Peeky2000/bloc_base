import 'dart:math';

import 'package:flutter/material.dart';

class CircleProgress extends StatelessWidget {
  final double value;
  final Color? progressColor;
  final Color? backgroundProgressColor;
  final double strokeWidth;
  final double backgroundStrokeWidth;
  final double size;
  final List<Color> gradientColor;

  const CircleProgress({
    Key? key,
    required this.value,
    this.progressColor,
    this.backgroundProgressColor,
    this.strokeWidth = 8.0,
    this.backgroundStrokeWidth = 8.0,
    this.size = 56.0,
    this.gradientColor = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _CircleProgressCirclePainter(
            value: value,
            progressColor: progressColor,
            backgroundColor: backgroundProgressColor,
            strokeWidth: strokeWidth,
            backgroundStrokeWidth: backgroundStrokeWidth,
            gradientColor: gradientColor,
          ),
        ),
      ),
    );
  }
}

class AnimationCircleProgress extends StatefulWidget {
  final double fromValue;
  final double toValue;
  final Color? progressColor;
  final Color? backgroundProgressColor;
  final double strokeWidth;
  final double size;
  final Duration duration;
  final bool repeat;
  final double backgroundStrokeWidth;
  final List<Color> gradientColor;

  const AnimationCircleProgress({
    Key? key,
    required this.fromValue,
    required this.toValue,
    this.progressColor,
    this.backgroundProgressColor,
    this.strokeWidth = 8.0,
    this.size = 56.0,
    this.duration = const Duration(seconds: 30),
    this.repeat = false,
    this.backgroundStrokeWidth = 8.0,
    this.gradientColor = const [],
  }) : super(key: key);

  @override
  _AnimationCircleProgressState createState() => _AnimationCircleProgressState();
}

class _AnimationCircleProgressState extends State<AnimationCircleProgress>
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
      width: widget.size,
      height: widget.size,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _CircleProgressCirclePainter(
              value: _animation.value,
              progressColor: widget.progressColor,
              backgroundColor: widget.backgroundProgressColor,
              strokeWidth: widget.strokeWidth,
              backgroundStrokeWidth: widget.backgroundStrokeWidth,
              gradientColor: widget.gradientColor,
          ),
        ),
      ),
    );
  }
}

class _CircleProgressCirclePainter extends CustomPainter {
  final double value;
  final Color? progressColor;
  final Color? backgroundColor;
  final double strokeWidth;
  final double backgroundStrokeWidth;
  final List<Color> gradientColor;

  const _CircleProgressCirclePainter({
    required this.value,
    this.progressColor,
    this.backgroundColor,
    this.strokeWidth = 8.0,
    this.backgroundStrokeWidth = 8.0,
    this.gradientColor = const [],
  });

  double get percent => value / 100.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final minDiameter = min(size.width, size.height);
    Paint progressCircle;
    if (gradientColor.isEmpty) {
      progressCircle = Paint()
        ..color = progressColor ?? Colors.blue
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
    } else {
      final gradient = SweepGradient(
        startAngle: 3 * pi / 2,
        endAngle: 7 * pi / 2,
        tileMode: TileMode.repeated,
        colors: gradientColor,
      );
      final rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);
      progressCircle = Paint()
        ..shader = gradient.createShader(rect)
        ..strokeCap = StrokeCap.round // StrokeCap.round is not recommended.
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
    }

    canvas.drawCircle(
        center,
        minDiameter / 2 - strokeWidth / 2,
        Paint()
          ..color = backgroundColor ?? Colors.blue.withOpacity(0.25)
          ..strokeWidth = backgroundStrokeWidth
          ..style = PaintingStyle.stroke);

    canvas.drawArc(
      Rect.fromCenter(
        center: center,
        height: minDiameter - strokeWidth,
        width: minDiameter - strokeWidth,
      ),
      -pi / 2 + (gradientColor.isEmpty ? 0 : 0.2),
      percent * 2 * pi * (gradientColor.isEmpty ? 1.0 : 0.94),
      false,
      progressCircle,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressCirclePainter oldDelegate) => true;
}
