import 'package:flutter/material.dart';
import 'package:sli_common/ink_well_button.dart';

class Bottom2Button extends StatelessWidget {
  final String? title1;
  final String? title2;
  final VoidCallback? onTapButton1;
  final VoidCallback? onTapButton2;
  final double? height;
  final bool isDisableButton1;
  final bool isDisableButton2;
  final bool? isDivider;
  final Color? textColorButton1;
  final Color? textColorButton2;
  final Color? button1Color;
  final Color? button2Color;
  final Color? backgroundColor;
  final Widget? hint;
  final Widget? titleWidget1;
  final Widget? titleWidget2;
  final double? radius;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? elevation;
  final Color? disableButton1Color;
  final Color? disableButton2Color;
  final Color? borderButton1Color;
  final Color? borderButton2Color;

  const Bottom2Button({Key? key,
    required this.title1,
    required this.title2,
    required this.onTapButton1,
    required this.onTapButton2,
    this.height,
    this.isDisableButton1 = false,
    this.isDisableButton2 = false,
    this.isDivider = true,
    this.textColorButton1,
    this.textColorButton2,
    this.button1Color,
    this.button2Color,
    this.backgroundColor,
    this.hint,
    this.titleWidget1,
    this.titleWidget2,
    this.radius,
    this.fontSize,
    this.fontWeight,
    this.elevation,
    this.disableButton1Color,
    this.disableButton2Color,
    this.borderButton1Color,
    this.borderButton2Color,
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
              child: Row(
                children: [
                  Expanded(
                    child: InkWellButton(
                      title: title1 ?? '',
                      height: height,
                      labelWidget: titleWidget1,
                      textColor: textColorButton1 ?? Colors.white,
                      buttonColor: button1Color,
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      isDisable: isDisableButton1,
                      onTap: onTapButton1,
                      radius: radius,
                      elevation: elevation,
                      disableButtonColor: disableButton1Color,
                      borderColor: borderButton1Color,
                    ),
                  ),
                  const SizedBox(width: 12,),
                  Expanded(
                    child: InkWellButton(
                      title: title2 ?? '',
                      height: height,
                      labelWidget: titleWidget2,
                      textColor: textColorButton2 ?? Colors.blue,
                      buttonColor: button2Color,
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      isDisable: isDisableButton2,
                      onTap: onTapButton2,
                      radius: radius,
                      elevation: elevation,
                      disableButtonColor: disableButton2Color,
                      borderColor: borderButton2Color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
