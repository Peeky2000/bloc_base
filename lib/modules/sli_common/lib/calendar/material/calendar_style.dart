import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CalendarStyle {
  TextStyle? dayNormalStyle;
  TextStyle? daySelectedStyle;
  TextStyle? dayDisableStyle;
  TextStyle? currentDayStyle;
  TextStyle? dayFocusStyle;
  TextStyle? weekTitleStyle;
  TextStyle? monthStyle;
  Color? arrowColor;
  Color? backgroundColor;
  BoxDecoration? daySelectedDecoration;
  BoxDecoration? dayFocusDecoration;
  BoxDecoration? dayRangeFocusDecoration;
  Color? dayRangeFocusColor;
  BoxDecoration? yearFocusDecoration;

  CalendarStyle(
      {this.backgroundColor = Colors.white,
      this.dayNormalStyle = const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Color(0xFF333333)),
      this.daySelectedStyle = const TextStyle(
          fontSize: 16, fontWeight: FontWeight.normal, color: Colors.red),
      this.dayDisableStyle = const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Color(0x33333333)),
      this.currentDayStyle,
      this.dayFocusStyle = const TextStyle(
          fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white),
      this.weekTitleStyle = const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500, color: Color(0x66333333)),
      this.monthStyle = const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF333333)),
      this.daySelectedDecoration = const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border(
              top: BorderSide(color: Color(0xFFF04F24), width: 1),
              left: BorderSide(color: Color(0xFFF04F24), width: 1),
              right: BorderSide(color: Color(0xFFF04F24), width: 1),
              bottom: BorderSide(color: Color(0xFFF04F24), width: 1))),
      this.dayFocusDecoration = const BoxDecoration(
        color: Color(0xFFF04F24),
      ),
      this.arrowColor = const Color(0xFFF04F24),
      this.dayRangeFocusColor = const Color(0x1AF04F24),
      this.dayRangeFocusDecoration =
          const BoxDecoration(color: Color(0x1AF04F24)),
      this.yearFocusDecoration = const BoxDecoration(color: Color(0x1AF04F24))});
}
