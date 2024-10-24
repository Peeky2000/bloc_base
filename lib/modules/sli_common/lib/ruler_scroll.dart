import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RulerScroll extends StatefulWidget {
  final RulerScrollController? controller;
  final int startValue;
  final int endValue;
  final Function(int) onChange;
  final int numberSubs;
  final double widthMain;
  final double heightManin;
  final double widthSubs;
  final double heightSubs;
  final double distance;
  final Color? colorMain;
  final Color? colorSubs;
  final LinearGradient linearGradient;
  final double? width;
  final double? height;
  final TextStyle? valueStyle;
  final bool isScaleCurrentValue;
  final double scale;
  final RulerScrollStartPoint startPoint;
  final Widget? currentPointWidget;
  final String unit;
  final TextStyle? unitStyle;
  final Widget? unitWidget;

  const RulerScroll(
      {Key? key,
      required this.startValue,
      required this.endValue,
      required this.onChange,
      this.controller,
      this.numberSubs = 4,
      this.widthMain = 3.0,
      this.heightManin = 16.0,
      this.widthSubs = 1.0,
      this.heightSubs = 8.0,
      this.distance = 10.0,
      this.colorMain = Colors.lightBlue,
      this.colorSubs = Colors.grey,
      this.linearGradient =
          const LinearGradient(colors: [Colors.transparent, Colors.white, Colors.transparent]),
      this.height,
      this.width,
      this.valueStyle,
      this.isScaleCurrentValue = false,
      this.scale = 2,
      this.startPoint = RulerScrollStartPoint.top,
      this.currentPointWidget,
      this.unit = '',
      this.unitStyle,
      this.unitWidget})
      : super(key: key);

  @override
  _RulerScrollState createState() => _RulerScrollState();
}

class _RulerScrollState extends State<RulerScroll> {
  RulerScrollController _scrollController = RulerScrollController();

  double totalLength = 0;
  int currentValue = 0;
  double _currentPosition = 0;

  @override
  void initState() {
    super.initState();
    _setupValue();
    _scrollController = widget.controller ?? RulerScrollController();
    _scrollController.setData(
        widthMain: widget.widthMain,
        widthSubs: widget.widthSubs,
        distance: widget.distance,
        numberSubs: widget.numberSubs,
        startValue: widget.startValue);
    _scrollController.addListener(() {
      if (widget.isScaleCurrentValue) {
        setState(() {
          _currentPosition = _scrollController.position.pixels;
        });
      }
      Future.delayed(const Duration(milliseconds: 50), () {
        _maybeCenterValue();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _setupValue() {
    totalLength = widget.widthMain +
        (widget.numberSubs + 1) * widget.distance +
        widget.widthSubs * widget.numberSubs;
    currentValue = widget.startValue;
  }

  Future<void> _maybeCenterValue() async {
    bool isScrolling = _scrollController.position.isScrollingNotifier.value;
    if (_scrollController.hasClients && !isScrolling) {
      double currentPosition = _scrollController.position.pixels;
      if (currentPosition % totalLength > totalLength / 2.0) {
        await _scrollController.animateTo(
          (_scrollController.position.pixels ~/ totalLength + 1).toDouble() * totalLength,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
        int newValue = _scrollController.position.pixels ~/ totalLength + widget.startValue;
        if (currentValue != newValue) {
          widget.onChange(newValue);
          currentValue = newValue;
        }
      } else {
        await _scrollController.animateTo(
          (_scrollController.position.pixels ~/ totalLength).toDouble() * totalLength,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
        int newValue = _scrollController.position.pixels ~/ totalLength + widget.startValue;
        if (currentValue != newValue) {
          widget.onChange(newValue);
          currentValue = newValue;
        }
      }
    }
  }

  double _getHeightMain(int index) {
    double height = widget.heightManin;
    if ((index / (widget.numberSubs + 1) * totalLength - _currentPosition).abs() > totalLength) {
      height = widget.heightManin;
    } else {
      height = widget.heightManin * widget.scale -
          ((widget.scale - 1) *
              (index / (widget.numberSubs + 1) * totalLength - _currentPosition).abs() /
              totalLength *
              widget.heightManin);
    }
    return height;
  }

  MainAxisAlignment _getMainAxis(RulerScrollStartPoint point) {
    switch (point) {
      case RulerScrollStartPoint.top:
        return MainAxisAlignment.start;
      case RulerScrollStartPoint.center:
        return MainAxisAlignment.center;
      case RulerScrollStartPoint.bottom:
        return MainAxisAlignment.end;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          SizedBox(
            height: widget.height ?? 100.0,
            width: widget.width ?? double.infinity,
            child: ShaderMask(
              shaderCallback: (rect) => widget.linearGradient
                  .createShader(Rect.fromLTWH(0.0, 0.0, rect.width, rect.height)),
              child: NotificationListener<ScrollEndNotification>(
                onNotification: (not) {
                  if (not.dragDetails?.primaryVelocity == 0) {
                    Future.microtask(() => _maybeCenterValue());
                  }
                  return true;
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ListView.separated(
                        controller: _scrollController,
                        itemCount:
                            (widget.endValue - widget.startValue) * (widget.numberSubs + 1) + 1,
                        separatorBuilder: (context, index) => SizedBox(width: widget.distance),
                        padding: EdgeInsets.symmetric(
                            horizontal: (widget.width ?? constraints.maxWidth) / 2.0 -
                                widget.widthMain / 2.0),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SizedBox(
                                  height: widget.heightManin * widget.scale,
                                  child: Column(
                                    mainAxisAlignment: _getMainAxis(widget.startPoint),
                                    children: [
                                      Container(
                                        width: index % (widget.numberSubs + 1) == 0
                                            ? widget.widthMain
                                            : widget.widthSubs,
                                        height: index % (widget.numberSubs + 1) == 0
                                            ? widget.isScaleCurrentValue
                                                ? _getHeightMain(index)
                                                : widget.heightManin
                                            : widget.heightSubs,
                                        color: index % (widget.numberSubs + 1) == 0
                                            ? widget.colorMain
                                            : widget.colorSubs,
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: 0.0,
                                  width: 50,
                                  left: -25,
                                  child: index % (widget.numberSubs + 1) == 0
                                      ? Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            (index ~/ (widget.numberSubs + 1) + widget.startValue)
                                                .toString(),
                                            style: widget.valueStyle ??
                                                TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: const Color(0xFF888888))
                                          ),
                                        )
                                      : Container(),
                                )
                              ],
                            )),
                    widget.currentPointWidget ??
                        Icon(
                          Icons.arrow_drop_up_outlined,
                          size: 32.0.w,
                        ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 8.0.h,
          ),
          widget.unitWidget ??
              Text(
                widget.unit,
                style: widget.unitStyle ??
                    TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: const Color(0xFF888888)),
              )
        ],
      );
    });
  }
}

enum RulerScrollStartPoint { top, center, bottom }

class RulerScrollController extends ScrollController {
  double widthMain = 3.0;
  double widthSubs = 1.0;
  double distance = 10.0;
  int numberSubs = 4;
  int startValue = 0;
  double totalLength = 0;

  void setData(
      {double widthMain = 3.0,
      double widthSubs = 1.0,
      double distance = 10.0,
      int numberSubs = 4,
      int startValue = 0}) {
    this.widthMain = widthMain;
    this.widthSubs = widthSubs;
    this.distance = distance;
    this.numberSubs = numberSubs;
    this.startValue = startValue;
    totalLength = widthMain + (numberSubs + 1) * distance + widthSubs * numberSubs;
  }

  Future<void> scrollToPoint(
    double point, {
    required Duration duration,
    required Curve curve,
  }) async {
    assert(point > startValue, 'Cannot scroll to point');
    double position = (point - startValue) * totalLength;
    await animateTo(position, duration: duration, curve: curve);
  }

  void jumpToPoint(double point) {
    double position = (point - startValue) * totalLength;
    jumpTo(position);
  }
}
