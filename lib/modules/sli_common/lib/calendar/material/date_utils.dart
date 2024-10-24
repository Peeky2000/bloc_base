// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:core';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'date_picker_common.dart';

const Duration monthScrollDuration = Duration(milliseconds: 200);
const double dayPickerRowHeight = 50.0;
const int maxDayPickerRowCount = 7; // A 31 day month that starts on Saturday.
// One extra row for the day-of-week header.
const double maxDayPickerHeight =
    dayPickerRowHeight * (maxDayPickerRowCount + 1);
const double monthPickerHorizontalPadding = 8.0;

const int yearPickerColumnCount = 3;
const double yearPickerPadding = 16.0;
const double yearPickerRowHeight = 52.0;
const double yearPickerRowSpacing = 8.0;

const double subHeaderHeight = 52.0;
const double monthNavButtonsWidth = 108.0;

const double monthItemHeaderHeight = 58.0;
const double monthItemFooterHeight = 12.0;
const double monthItemRowHeight = 42.0;
const double monthItemSpaceBetweenRows = 8.0;
const double horizontalPadding = 8.0;
const double maxCalendarWidthLandscape = 384.0;
const double maxCalendarWidthPortrait = 480.0;

enum SelectionMode { single, range }

class Language {
  static const String vietnamese = 'vi';
  static const String english = 'en';
}

/// Returns a [DateTime] with just the date of the original, but no time set.
DateTime dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

/// Returns true if the two [DateTime] objects have the same day, month, and
/// year, or are both null.
bool isSameDay(DateTime? dateA, DateTime? dateB) {
  return dateA?.year == dateB?.year &&
      dateA?.month == dateB?.month &&
      dateA?.day == dateB?.day;
}

/// Returns true if the two [DateTime] objects have the same month, and
/// year, or are both null.
bool isSameMonth(DateTime? dateA, DateTime? dateB) {
  return dateA?.year == dateB?.year && dateA?.month == dateB?.month;
}

/// Determines the number of months between two [DateTime] objects.
int monthDelta(DateTime startDate, DateTime endDate) {
  return (endDate.year - startDate.year) * 12 + endDate.month - startDate.month;
}

/// Returns a [DateTime] with the added number of months and truncates any day
/// and time information.
DateTime addMonthsToMonthDate(DateTime monthDate, int monthsToAdd) {
  var _year = monthDate.year;
  var _month = monthDate.month + monthsToAdd;

  _year += (_month - 1) ~/ 12;
  _month = _month % 12;
  if (_month == 0) _month = 12;
  return DateTime(_year, _month);
}

/// Computes the offset from the first day of the week that the first day of
/// the [month] falls on.
int firstDayOffset(int year, int month) {
  return (DateTime(year, month, 1).weekday - 1) % 7;
}

/// Returns the number of days in a month.
int getDaysInMonth(int year, int month) {
  DateTime thisMonth = DateTime(year, month, 0);
  DateTime nextMonth = DateTime(year, month + 1, 0);
  return nextMonth.difference(thisMonth).inDays;
}

/// Returns a locale-appropriate string to describe the start of a date range.
///
/// If `startDate` is null, then it defaults to 'Start Date', otherwise if it
/// is in the same year as the `endDate` then it will use the short month
/// day format (i.e. 'Asr 21'). Otherwise it will return the short date format
/// (i.e. 'Asr 21, 2077').
String formatRangeStartDate(MaterialLocalizations localizations,
    DateTime? startDate, DateTime? endDate) {
  return startDate == null
      ? localizations.dateRangeStartLabel
      : (endDate == null || startDate.year == endDate.year)
          ? DateFormat('MMMM d').format(startDate)
          : DateFormat.yMd().format(startDate);
}

/// Returns an locale-appropriate string to describe the end of a date range.
///
/// If `endDate` is null, then it defaults to 'End Date', otherwise if it
/// is in the same year as the `startDate` and the `currentDate` then it will
/// just use the short month day format (i.e. 'Asr 21'), otherwise it will
/// include the year (i.e. 'Asr 21, 2077').
String formatRangeEndDate(MaterialLocalizations localizations,
    DateTime? startDate, DateTime? endDate, DateTime currentDate) {
  return endDate == null
      ? localizations.dateRangeEndLabel
      : (startDate != null &&
              startDate.year == endDate.year &&
              startDate.year == currentDate.year)
          ? DateFormat('MMMM d').format(endDate)
          : DateFormat.yMd().format(endDate);
}

/// Returns a [DateTimeRange] with the dates of the original without any times set.
CustomDateTimeRange datesOnly(CustomDateTimeRange range) {
  return CustomDateTimeRange(
      start: dateOnly(range.start), end: dateOnly(range.end));
}
