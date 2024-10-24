import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isWrapContent;
  final double? radius;
  final LinearGradient? gradient;
  final LinearGradient? gradientDisable;
  final String? title;
  final bool isDisable;
  final Color? textColor;
  final double? fontSize;
  final Widget? labelWidget;
  final Color? disabledTextColor;
  final double? elevation;
  final FontWeight? fontWeight;
  final double? width;
  final double? height;
  final List<BoxShadow>? shadows;
  final EdgeInsetsGeometry? padding;

  const GradientButton({
    Key? key,
    this.title,
    this.onTap,
    this.isWrapContent = false,
    this.radius,
    this.gradient,
    this.gradientDisable,
    this.isDisable = false,
    this.textColor,
    this.fontSize,
    this.labelWidget,
    this.elevation,
    this.disabledTextColor,
    this.fontWeight,
    this.width,
    this.height,
    this.shadows,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 25.0.r),
        boxShadow: shadows,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 25.0.r),
          ),
        ),
        onPressed: isDisable ? null : onTap,
        child: Ink(
          width: width ?? (isWrapContent ? null : double.infinity),
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(radius ?? 25.0.r),
            gradient: isDisable
                ? gradientDisable ??
                    const LinearGradient(
                      colors: [
                        Color(0xFF333333),
                        Color(0xFF333333),
                      ],
                    )
                : gradient ??
                    const LinearGradient(
                      colors: [
                        Color(0xFFFAA742),
                        Color(0xFFEF264F),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              labelWidget ??
                  Text(
                    title ?? '',
                    style: TextStyle(
                      fontSize: fontSize,
                      color: isDisable
                          ? disabledTextColor ?? const Color(0xFF333333).withOpacity(0.6)
                          : textColor,
                      fontWeight: fontWeight ?? FontWeight.w700,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
