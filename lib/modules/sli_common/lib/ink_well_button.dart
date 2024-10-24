import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InkWellButton extends StatelessWidget {
  final String? title;
  final bool isDisable;
  final Color? buttonColor;
  final Color? borderColor;
  final Color? textColor;
  final double? fontSize;
  final double? radius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Widget? labelWidget;
  final bool isWrapContentChild;
  final FontWeight? fontWeight;
  final Color? disabledTextColor;
  final double? elevation;
  final double? borderWidth;
  final Color? disableButtonColor;

  const InkWellButton({
    Key? key,
    this.title,
    this.isDisable = false,
    this.buttonColor,
    this.borderColor,
    this.textColor,
    this.fontSize,
    this.radius,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    this.labelWidget,
    this.isWrapContentChild = false,
    this.fontWeight,
    this.disabledTextColor,
    this.elevation,
    this.borderWidth,
    this.disableButtonColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? (isWrapContentChild ? null : double.infinity),
      height: height,
      child: ElevatedButton(
        onPressed: isDisable ? null : onTap,
        style: ElevatedButton.styleFrom(
            elevation: elevation,
            padding: padding ?? EdgeInsets.zero,
            backgroundColor: isDisable ? const Color(0xFF333333).withOpacity(0.2) : buttonColor,
            minimumSize: Size(50.w, 50.w),
            disabledBackgroundColor: disableButtonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius ?? 8.r),
              side: borderColor != null
                  ? BorderSide(color: borderColor!, width: borderWidth ?? 1)
                  : BorderSide.none,
            )),
        child: labelWidget ??
            Text(
              title ?? '',
              style: TextStyle(
                  fontSize: fontSize,
                  color: isDisable
                      ? disabledTextColor ?? const Color(0xFF333333).withOpacity(0.6)
                      : textColor,
                  fontWeight: fontWeight ?? FontWeight.w700),
            ),
      ),
    );
  }
}
