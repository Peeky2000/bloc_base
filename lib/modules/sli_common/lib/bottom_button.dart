import 'package:flutter/material.dart';

import 'ink_well_button.dart';

class BottomButton extends StatelessWidget {
  final String? title;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool isDisable;
  final bool? isDivider;
  final Color? textColor;
  final Color? buttonColor;
  final Color? backgroundColor;
  final Widget? hint;
  final Widget? titleWidget;
  final double? radius;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? elevation;
  final Color? disableButtonColor;
  final Color? disabledTextColor;

  const BottomButton({
    Key? key,
    required this.title,
    required this.onTap,
    this.width,
    this.height,
    this.isDisable = false,
    this.isDivider = true,
    this.textColor,
    this.buttonColor,
    this.backgroundColor,
    this.hint,
    this.titleWidget,
    this.radius,
    this.fontSize,
    this.fontWeight,
    this.elevation,
    this.disableButtonColor,
    this.disabledTextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Theme.of(context).cardColor,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            isDivider == true ? const Divider(height: 1) : Container(),
            const SizedBox(height: 15),
            if (hint != null) hint!,
            Container(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: InkWellButton(
                title: title ?? '',
                width: width,
                height: height,
                labelWidget: titleWidget,
                textColor: textColor ?? Colors.white,
                buttonColor: buttonColor,
                fontSize: fontSize,
                fontWeight: fontWeight,
                isDisable: isDisable,
                onTap: onTap,
                radius: radius,
                elevation: elevation,
                disableButtonColor: disableButtonColor,
                disabledTextColor: disabledTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
