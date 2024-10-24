import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimationGradientText extends StatefulWidget {
  final String texts;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool isRepeat;
  final bool isReverse;
  final List<Color> colors;
  final Duration duration;

  const AnimationGradientText(
    this.texts, {
    Key? key,
    this.style,
    this.textAlign,
    this.isRepeat = true,
    this.isReverse = true,
    this.colors = const [Color(0xFFFAA742), Colors.green, Colors.blue, Color(0xFFEF264F)],
    this.duration = const Duration(milliseconds: 2000),
  })  : assert(colors.length > 2),
        super(key: key);

  @override
  State<AnimationGradientText> createState() => _AnimationGradientTextState();
}

class _AnimationGradientTextState extends State<AnimationGradientText>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animationColor;
  List<Color> colors = [];

  @override
  void initState() {
    super.initState();
    colors = widget.colors;
    _animationController =
        AnimationController(vsync: this, duration: widget.duration);
    _animationColor = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
    if (widget.isRepeat) {
      _animationController.repeat(reverse: widget.isReverse);
    }
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<double> get stops {
    List<double> stopPoints = [];
    for (int i = 0; i < widget.colors.length; i++) {
      stopPoints.add(_animationColor.value + (1.5 - (i + 1) * 1.5 / (widget.colors.length - 1)));
    }
    return stopPoints.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationColor,
      builder: (context, child) => ShaderMask(
        shaderCallback: (rect) =>
            LinearGradient(colors: widget.colors, stops: stops).createShader(rect),
        child: Text(widget.texts,
            textAlign: widget.textAlign,
            style: widget.style ??
                TextStyle(color: Colors.white, fontSize: 14.0.sp, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
