// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

import 'calendar_style.dart';
import 'date_picker_common.dart' as common;
import 'date_utils.dart' as utils;
import 'date_utils.dart';
import 'month_widget.dart';
import 'year_widget.dart';

/// Displays a grid of days for a given month and allows the user to select a date.
///
/// Days are arranged in a rectangular grid with one column for each day of the
/// week. Controls are provided to change the year and month that the grid is
/// showing.
///
/// The calendar picker widget is rarely used directly. Instead, consider using
/// [showMaterialDatePicker], which will create a dialog that uses this as well as provides
/// a text entry option.
class SliCalendarDatePicker extends StatefulWidget {
  /// Creates a calender date picker
  ///
  /// It will display a grid of days for the [initialDate]'s month. The day
  /// indicated by [initialDate] will be selected.
  ///
  /// The optional [onDisplayedMonthChanged] callback can be used to track
  /// the currently displayed month.
  ///
  /// The user interface provides a way to change the year of the month being
  /// displayed. By default it will show the day grid, but this can be changed
  /// to start in the year selection interface with [initialCalendarMode] set
  /// to [DatePickerMode.year].
  ///
  /// The [initialDate], [firstDate], [lastDate], [onDateChanged], and
  /// [initialCalendarMode] must be non-null.
  ///
  /// [lastDate] must be after or equal to [firstDate].
  ///
  /// [initialDate] must be between [firstDate] and [lastDate] or equal to
  /// one of them.
  ///
  /// [currentDate] represents the current day (i.e. today). This
  /// date will be highlighted in the day grid. If null, the date of
  /// `DateTime.now()` will be used.
  ///
  /// If [selectableDayPredicate] is non-null, it must return `true` for the
  /// [initialDate].
  SliCalendarDatePicker({
    Key? key,
    this.initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    this.onDateChanged,
    this.onEndDateChanged,
    this.onStartDateChanged,
    this.onDisplayedMonthChanged,
    this.initialCalendarMode = DatePickerMode.day,
    this.selectableDayPredicate,
    this.calendarStyle,
    this.dayBuilder,
    this.selectionMode,
    this.selectedStartDate,
    this.selectedEndDate,
    this.borderRadius = 0,
  })  : firstDate = utils.dateOnly(firstDate),
        lastDate = utils.dateOnly(lastDate),
        currentDate = utils.dateOnly(currentDate ?? DateTime.now()),
        super(key: key) {
    assert(
      !this.lastDate.isBefore(this.firstDate),
      'lastDate ${this.lastDate} must be on or after firstDate ${this.firstDate}.',
    );
    // assert(
    //   !this.initialDate.isBefore(this.firstDate),
    //   'initialDate ${this.initialDate} must be on or after firstDate ${this.firstDate}.',
    // );
    // assert(
    //   !this.initialDate.isAfter(this.lastDate),
    //   'initialDate ${this.initialDate} must be on or before lastDate ${this.lastDate}.',
    // );
    // assert(
    //   selectableDayPredicate == null ||
    //       selectableDayPredicate!(this.initialDate),
    //   'Provided initialDate ${this.initialDate} must satisfy provided selectableDayPredicate.',
    // );
  }

  /// The initially selected [DateTime] that the picker should display.
  final DateTime? initialDate;

  /// The earliest allowable [DateTime] that the user can select.
  final DateTime firstDate;

  /// The latest allowable [DateTime] that the user can select.
  final DateTime lastDate;

  /// The [DateTime] representing today. It will be highlighted in the day grid.
  final DateTime currentDate;

  /// Called when the user selects a date in the picker.
  final ValueChanged<DateTime?>? onDateChanged;

  final ValueChanged<DateTime?>? onStartDateChanged;

  final ValueChanged<DateTime?>? onEndDateChanged;

  /// Called when the user navigates to a new month/year in the picker.
  final ValueChanged<DateTime>? onDisplayedMonthChanged;

  /// The initial display of the calendar picker.
  final DatePickerMode initialCalendarMode;

  /// Builds the widget for particular day.
  final Widget Function(DateTime)? dayBuilder;

  final CalendarStyle? calendarStyle;

  final SelectionMode? selectionMode;

  final DateTime? selectedStartDate;

  final DateTime? selectedEndDate;

  final double borderRadius;

  /// Function to provide full control over which dates in the calendar can be selected.
  final common.SelectableDayPredicate? selectableDayPredicate;

  @override
  _SliCalendarDatePickerState createState() => _SliCalendarDatePickerState();
}

class _SliCalendarDatePickerState extends State<SliCalendarDatePicker> {
  bool _announcedInitialDate = false;
  late DatePickerMode _mode;
  DateTime _currentDisplayedMonthDate = DateTime.now();
  DateTime? _selectedDate;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  final GlobalKey _monthPickerKey = GlobalKey();
  final GlobalKey _yearPickerKey = GlobalKey();
  late TextDirection _textDirection;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialCalendarMode;
    if (widget.initialDate != null) {
      _currentDisplayedMonthDate = DateTime(
        widget.initialDate!.year,
        widget.initialDate!.month,
      );
      _selectedDate = widget.initialDate!;
    }
    _selectedStartDate = widget.selectedStartDate;
    _selectedEndDate = widget.selectedEndDate;
  }

  @override
  void didUpdateWidget(SliCalendarDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCalendarMode != oldWidget.initialCalendarMode) {
      _mode = widget.initialCalendarMode;
    }
    if (widget.initialDate != null) {
      if (!DateUtils.isSameDay(widget.initialDate, oldWidget.initialDate)) {
        _currentDisplayedMonthDate = DateTime(
          widget.initialDate!.year,
          widget.initialDate!.month,
        );
        _selectedDate = widget.initialDate;
      }
    }
    _selectedStartDate = widget.selectedStartDate;
    _selectedEndDate = widget.selectedEndDate;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasDirectionality(context));
    _textDirection = Directionality.of(context);
    if (_selectedDate != null && !_announcedInitialDate) {
      _announcedInitialDate = true;
      SemanticsService.announce(
        intl.DateFormat.yMMMMEEEEd().format(_selectedDate!),
        _textDirection,
      );
    }
  }

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        HapticFeedback.vibrate();
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
  }

  void _handleModeChanged(DatePickerMode mode) {
    _vibrate();
    if (_selectedDate != null) {
      setState(() {
        _mode = mode;
        if (_mode == DatePickerMode.day) {
          SemanticsService.announce(
            intl.DateFormat.yMMMM().format(_selectedDate!),
            _textDirection,
          );
        } else {
          SemanticsService.announce(
            intl.DateFormat.y().format(_selectedDate!),
            _textDirection,
          );
        }
      });
    }
  }

  void _handleMonthChanged(DateTime date) {
    setState(() {
      if (_currentDisplayedMonthDate.year != date.year ||
          _currentDisplayedMonthDate.month != date.month) {
        _currentDisplayedMonthDate = DateTime(date.year, date.month);
        widget.onDisplayedMonthChanged?.call(_currentDisplayedMonthDate);
      }
    });
  }

  void _handleYearChanged(DateTime value) {
    _vibrate();

    if (value.isBefore(widget.firstDate)) {
      value = widget.firstDate;
    } else if (value.isAfter(widget.lastDate)) {
      value = widget.lastDate;
    }

    setState(() {
      _mode = DatePickerMode.day;
      _handleMonthChanged(value);
    });
  }

  void _handleDayChanged(DateTime value) {
    _vibrate();
    setState(() {
      _selectedDate = value;
      widget.onDateChanged?.call(_selectedDate);
    });
  }

  void _handleStartDayChanged(DateTime? value) {
    _vibrate();
    setState(() {
      _selectedStartDate = value;
      widget.onStartDateChanged?.call(_selectedStartDate);
    });
  }

  void _handleEndDayChanged(DateTime? value) {
    _vibrate();
    setState(() {
      _selectedEndDate = value;
      widget.onEndDateChanged?.call(_selectedEndDate);
    });
  }

  Widget _buildPicker() {
    switch (_mode) {
      case DatePickerMode.day:
        return MonthWidget(
          key: _monthPickerKey,
          initialMonth: _currentDisplayedMonthDate,
          currentDate: widget.currentDate,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          selectedDate: _selectedDate,
          selectedStartDate: _selectedStartDate,
          selectedEndDate: _selectedEndDate,
          onChanged: _handleDayChanged,
          onDisplayedMonthChanged: _handleMonthChanged,
          selectableDayPredicate: widget.selectableDayPredicate,
          calendarStyle: widget.calendarStyle,
          dayBuilder: widget.dayBuilder,
          onEndDateChanged: _handleEndDayChanged,
          onStartDateChanged: _handleStartDayChanged,
          selectionMode: widget.selectionMode,
        );
      case DatePickerMode.year:
        return Padding(
          padding: const EdgeInsets.only(top: subHeaderHeight),
          child: YearWidget(
            key: _yearPickerKey,
            currentDate: widget.currentDate,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            initialDate: _currentDisplayedMonthDate,
            selectedDate: _selectedDate,
            calendarStyle: widget.calendarStyle,
            onChanged: _handleYearChanged,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: widget.calendarStyle?.backgroundColor,
      ),
      child: Stack(
        children: <Widget>[
          SizedBox(
            height: subHeaderHeight + maxDayPickerHeight,
            child: _buildPicker(),
          ),
          _DatePickerModeToggleButton(
            mode: _mode,
            title:
                intl.DateFormat("MM/yyyy").format(_currentDisplayedMonthDate),
            calendarStyle: widget.calendarStyle,
            onTitlePressed: () {
              // Toggle the day/year mode.
              _handleModeChanged(
                _mode == DatePickerMode.day
                    ? DatePickerMode.year
                    : DatePickerMode.day,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A button that used to toggle the [DatePickerMode] for a date picker.
///
/// This appears above the calendar grid and allows the user to toggle the
/// [DatePickerMode] to display either the calendar view or the year list.
class _DatePickerModeToggleButton extends StatefulWidget {
  const _DatePickerModeToggleButton({
    required this.mode,
    required this.title,
    required this.onTitlePressed,
    this.calendarStyle,
  });

  /// The current display of the calendar picker.
  final DatePickerMode mode;

  /// The text that displays the current month/year being viewed.
  final String title;

  /// The callback when the title is pressed.
  final VoidCallback onTitlePressed;

  final CalendarStyle? calendarStyle;

  @override
  _DatePickerModeToggleButtonState createState() =>
      _DatePickerModeToggleButtonState();
}

class _DatePickerModeToggleButtonState
    extends State<_DatePickerModeToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: widget.mode == DatePickerMode.year ? 0.5 : 0,
      upperBound: 0.5,
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(_DatePickerModeToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode == widget.mode) {
      return;
    }

    if (widget.mode == DatePickerMode.year) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = widget.calendarStyle?.monthStyle;
    final controlColor = Color(0xFF333333);

    return Container(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
      height: subHeaderHeight,
      child: Row(
        children: <Widget>[
          Flexible(
            child: Semantics(
              label: 'Select year',
              excludeSemantics: true,
              button: true,
              child: Container(
                height: subHeaderHeight,
                child: InkWell(
                  onTap: widget.onTitlePressed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(widget.title, style: textTheme),
                        ),
                        RotationTransition(
                          turns: _controller,
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: controlColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.mode == DatePickerMode.day)
            // Give space for the prev/next month buttons that are underneath this row
            const SizedBox(width: monthNavButtonsWidth),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// InheritedWidget indicating what the current focused date is for its children.
///
/// This is used by the [_MonthPicker] to let its children [_DayPicker]s know
/// what the currently focused date (if any) should be.
class FocusedDate extends InheritedWidget {
  const FocusedDate({Key? key, required Widget child, this.date})
      : super(key: key, child: child);

  final DateTime? date;

  @override
  bool updateShouldNotify(FocusedDate oldWidget) {
    return !DateUtils.isSameDay(date, oldWidget.date);
  }

  static DateTime? of(BuildContext context) {
    final focusedDate =
        context.dependOnInheritedWidgetOfExactType<FocusedDate>();
    return focusedDate?.date;
  }
}
