import 'package:flutter/material.dart';

class TabBarWidget extends StatelessWidget {
  final TabController tabController;
  final List<String>? titles;
  final List<Widget>? widgets;
  final Color? selectedColor;
  final Color? unselectedLabelColor;
  final TextStyle? selectedLabelStyle;
  final TextStyle? unSelectedLabelStyle;
  final bool isTextLabel;
  final bool isShowDivider;
  final bool isScrollable;
  final EdgeInsetsGeometry? labelPadding;
  final EdgeInsetsGeometry? indicatorPadding;
  final Function(int)? onTap;

  const TabBarWidget({
    Key? key,
    required this.tabController,
    this.titles,
    this.widgets,
    this.selectedColor,
    this.unselectedLabelColor,
    this.selectedLabelStyle,
    this.unSelectedLabelStyle,
    this.isTextLabel = true,
    this.isShowDivider = true,
    this.isScrollable = false,
    this.labelPadding,
    this.indicatorPadding,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TabBar(
            controller: tabController,
            indicatorColor: selectedColor ?? Colors.white,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: selectedColor ?? Colors.white,
            automaticIndicatorColorAdjustment: true,
            unselectedLabelColor: unselectedLabelColor,
            isScrollable: isScrollable,
            indicatorPadding: indicatorPadding ?? EdgeInsets.zero,
            labelPadding: labelPadding,
            labelStyle: selectedLabelStyle,
            unselectedLabelStyle: unSelectedLabelStyle,
            tabs: isTextLabel && titles?.isNotEmpty == true
                ? List<Tab>.generate(
              titles!.length,
                  (index) {
                return Tab(text: titles![index]);
              },
            )
                : widgets ?? [Container()],
            onTap: onTap,
          ),
        ),
        if (isShowDivider) const Divider(height: 0.5),
      ],
    );
  }
}
