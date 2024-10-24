import 'package:flutter/material.dart';

class BottomSheetWidget extends StatelessWidget {
  static Color? defaultBackgroundColor;

  final String? title;
  final Widget child;
  final Widget? action;
  final double? height;
  final Widget? backIcon;
  final VoidCallback? onPop;
  final Color? backgroundColor;
  final FontWeight? titleFontWeight;
  final bool? isIntrinsicHeight;
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final EdgeInsetsGeometry? margin;
  final bool showHeader;
  final double radius;

  const BottomSheetWidget({
    Key? key,
    this.title,
    required this.child,
    this.action,
    this.height,
    this.backIcon,
    this.onPop,
    this.backgroundColor,
    this.titleFontWeight,
    this.isIntrinsicHeight = false,
    this.safeAreaTop = false,
    this.safeAreaBottom = true,
    this.margin,
    this.showHeader = true,
    this.radius = 10
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          isIntrinsicHeight == true ? null : height ?? MediaQuery.of(context).size.height * 2 / 3,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
        ),
      ),
      margin: margin,
      child: Stack(
        children: [
          isIntrinsicHeight == true ? IntrinsicHeight(child: _body(context)) : _body(context),
          if (showHeader)
            InkWell(
              onTap: onPop ?? () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                child: backIcon ??
                    Icon(
                      Icons.close_outlined,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
              ),
            ),
          Positioned(top: 0, right: 0, child: action ?? Container()),
        ],
      ),
    );
  }

  _body(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: showHeader
              ? Text(
                  title ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: titleFontWeight ?? FontWeight.w500),
                  textAlign: TextAlign.center,
                )
              : const SizedBox(),
        ),
        if (showHeader) const Divider(height: 1),
        Expanded(
          child: SafeArea(
            top: safeAreaTop,
            bottom: safeAreaBottom,
            child: child,
          ),
        ),
      ],
    );
  }
}
