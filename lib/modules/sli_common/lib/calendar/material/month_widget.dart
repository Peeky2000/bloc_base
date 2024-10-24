import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

import 'calendar_date_picker.dart';
import 'calendar_style.dart';
import 'date_picker_common.dart' as common;
import 'date_utils.dart' as utils;
import 'date_utils.dart';
import 'day_widget.dart';

class MonthWidget extends StatefulWidget {
  /// Creates a month picker.
  MonthWidget({
    Key? key,
    required this.initialMonth,
    required this.currentDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDisplayedMonthChanged,
    this.selectedDate,
    this.onChanged,
    this.selectedEndDate,
    this.selectedStartDate,
    this.calendarStyle,
    this.dayBuilder,
    this.selectableDayPredicate,
    this.selectionMode = SelectionMode.single,
    this.onEndDateChanged,
    this.onStartDateChanged,
  })  : assert(!firstDate.isAfter(lastDate)),
        super(key: key);

  /// The initial month to display
  final DateTime initialMonth;

  /// The current date.
  ///
  /// This date is subtly highlighted in the picker.
  final DateTime currentDate;

  /// The earliest date the user is permitted to pick.
  ///
  /// This date must be on or before the [lastDate].
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  ///
  /// This date must be on or after the [firstDate].
  final DateTime lastDate;

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime? selectedDate;

  final DateTime? selectedEndDate;

  final DateTime? selectedStartDate;

  /// Called when the user picks a day.
  final ValueChanged<DateTime>? onChanged;

  /// Called when the user navigates to a new month
  final ValueChanged<DateTime> onDisplayedMonthChanged;

  /// Builds the widget for particular day.
  final Widget Function(DateTime)? dayBuilder;

  final CalendarStyle? calendarStyle;

  final common.SelectableDayPredicate? selectableDayPredicate;

  final SelectionMode? selectionMode;

  /// Called when the user changes the start date of the selected range.
  final ValueChanged<DateTime>? onStartDateChanged;

  /// Called when the user changes the end date of the selected range.
  final ValueChanged<DateTime?>? onEndDateChanged;

  @override
  State<StatefulWidget> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<MonthWidget> {
  final GlobalKey _pageViewKey = GlobalKey();
  late DateTime _currentMonth;
  late DateTime _nextMonthDate;
  late DateTime _previousMonthDate;
  late PageController _pageController;
  late TextDirection _textDirection;
  Map<LogicalKeySet, Intent>? _shortcutMap;
  Map<Type, Action<Intent>>? _actionMap;
  late FocusNode _dayGridFocus;
  DateTime? _focusedDay;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialMonth;
    _previousMonthDate = utils.addMonthsToMonthDate(_currentMonth, -1);
    _nextMonthDate = utils.addMonthsToMonthDate(_currentMonth, 1);
    _pageController = PageController(
        initialPage: utils.monthDelta(widget.firstDate, _currentMonth));
    _shortcutMap = <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.arrowLeft):
          const DirectionalFocusIntent(TraversalDirection.left),
      LogicalKeySet(LogicalKeyboardKey.arrowRight):
          const DirectionalFocusIntent(TraversalDirection.right),
      LogicalKeySet(LogicalKeyboardKey.arrowDown):
          const DirectionalFocusIntent(TraversalDirection.down),
      LogicalKeySet(LogicalKeyboardKey.arrowUp):
          const DirectionalFocusIntent(TraversalDirection.up),
    };
    _actionMap = <Type, Action<Intent>>{
      NextFocusIntent:
          CallbackAction<NextFocusIntent>(onInvoke: _handleGridNextFocus),
      PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
          onInvoke: _handleGridPreviousFocus),
      DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
          onInvoke: _handleDirectionFocus),
    };
    _startDate = widget.selectedStartDate;
    _endDate = widget.selectedEndDate;
    _dayGridFocus = FocusNode(debugLabel: 'Day Grid');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textDirection = Directionality.of(context);
  }

  @override
  void didUpdateWidget(MonthWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _startDate = widget.selectedStartDate;
    _endDate = widget.selectedEndDate;
    if (widget.initialMonth != oldWidget.initialMonth) {
      // We can't interrupt this widget build with a scroll, so do it next frame
      WidgetsBinding.instance.addPostFrameCallback(
        (Duration timeStamp) => _showMonth(widget.initialMonth, jump: true),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dayGridFocus.dispose();
    super.dispose();
  }

  void _updateSelection(DateTime date) {
    setState(() {
      if (_startDate != null &&
          _endDate == null &&
          !date.isBefore(_startDate!)) {
        _endDate = date;
        widget.onEndDateChanged?.call(_endDate!);
      } else {
        _startDate = date;
        widget.onStartDateChanged?.call(_startDate!);
        if (_endDate != null) {
          _endDate = null;
          widget.onEndDateChanged?.call(_endDate);
        }
      }
    });
  }

  void _handleDateSelected(DateTime selectedDate) {
    if (widget.selectionMode == SelectionMode.range) {
      _updateSelection(selectedDate);
    } else {
      _focusedDay = selectedDate;
      widget.onChanged?.call(selectedDate);
    }
  }

  void _handleMonthPageChanged(int monthPage) {
    setState(() {
      final monthDate = utils.addMonthsToMonthDate(widget.firstDate, monthPage);
      if (!utils.isSameMonth(_currentMonth, monthDate)) {
        _currentMonth = DateTime(monthDate.year, monthDate.month);
        _previousMonthDate = utils.addMonthsToMonthDate(_currentMonth, -1);
        _nextMonthDate = utils.addMonthsToMonthDate(_currentMonth, 1);
        widget.onDisplayedMonthChanged(_currentMonth);
        if (_focusedDay != null &&
            !utils.isSameMonth(_focusedDay!, _currentMonth)) {
          // We have navigated to a new month with the grid focused, but the
          // focused day is not in this month. Choose a new one trying to keep
          // the same day of the month.
          _focusedDay = _focusableDayForMonth(_currentMonth, _focusedDay!.day);
        }
      }
    });
  }

  /// Returns a focusable date for the given month.
  ///
  /// If the preferredDay is available in the month it will be returned,
  /// otherwise the first selectable day in the month will be returned. If
  /// no dates are selectable in the month, then it will return null.
  DateTime? _focusableDayForMonth(DateTime month, int preferredDay) {
    final daysInMonth = utils.getDaysInMonth(month.year, month.month);

    // Can we use the preferred day in this month?
    if (preferredDay <= daysInMonth) {
      final newFocus = DateTime(month.year, month.month, preferredDay);
      if (_isSelectable(newFocus)) return newFocus;
    }

    // Start at the 1st and take the first selectable date.
    for (var day = 1; day <= daysInMonth; day++) {
      final newFocus = DateTime(month.year, month.month, day);
      if (_isSelectable(newFocus)) return newFocus;
    }
    return null;
  }

  /// Navigate to the next month.
  void _handleNextMonth() {
    if (!_isDisplayingLastMonth) {
      SemanticsService.announce(
        intl.DateFormat.yMMMM().format(_nextMonthDate),
        _textDirection,
      );
      _pageController.nextPage(
        duration: monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  /// Navigate to the previous month.
  void _handlePreviousMonth() {
    if (!_isDisplayingFirstMonth) {
      SemanticsService.announce(
        intl.DateFormat.yMMMM().format(_previousMonthDate),
        _textDirection,
      );
      _pageController.previousPage(
        duration: monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  /// Navigate to the given month.
  void _showMonth(DateTime month, {bool jump = false}) {
    final monthPage = utils.monthDelta(widget.firstDate, month);
    if (jump) {
      _pageController.jumpToPage(monthPage);
    } else {
      _pageController.animateToPage(
        monthPage,
        duration: monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  /// True if the earliest allowable month is displayed.
  bool get _isDisplayingFirstMonth {
    return !_currentMonth.isAfter(
      DateTime(widget.firstDate.year, widget.firstDate.month),
    );
  }

  /// True if the latest allowable month is displayed.
  bool get _isDisplayingLastMonth {
    return !_currentMonth.isBefore(
      DateTime(widget.lastDate.year, widget.lastDate.month),
    );
  }

  /// Handler for when the overall day grid obtains or loses focus.
  void _handleGridFocusChange(bool focused) {
    setState(() {
      if (focused && _focusedDay == null) {
        if (utils.isSameMonth(widget.selectedDate, _currentMonth)) {
          _focusedDay = widget.selectedDate;
        } else if (utils.isSameMonth(widget.currentDate, _currentMonth)) {
          _focusedDay =
              _focusableDayForMonth(_currentMonth, widget.currentDate.day);
        } else {
          _focusedDay = _focusableDayForMonth(_currentMonth, 1);
        }
      }
    });
  }

  /// Move focus to the next element after the day grid.
  void _handleGridNextFocus(NextFocusIntent intent) {
    _dayGridFocus.requestFocus();
    _dayGridFocus.nextFocus();
  }

  /// Move focus to the previous element before the day grid.
  void _handleGridPreviousFocus(PreviousFocusIntent intent) {
    _dayGridFocus.requestFocus();
    _dayGridFocus.previousFocus();
  }

  /// Move the internal focus date in the direction of the given intent.
  ///
  /// This will attempt to move the focused day to the next selectable day in
  /// the given direction. If the new date is not in the current month, then
  /// the page view will be scrolled to show the new date's month.
  ///
  /// For horizontal directions, it will move forward or backward a day (depending
  /// on the current [TextDirection]). For vertical directions it will move up and
  /// down a week at a time.
  void _handleDirectionFocus(DirectionalFocusIntent intent) {
    assert(_focusedDay != null);
    setState(() {
      final nextDate = _nextDateInDirection(_focusedDay!, intent.direction);
      if (nextDate != null) {
        _focusedDay = nextDate;
        if (!utils.isSameMonth(_focusedDay!, _currentMonth)) {
          _showMonth(_focusedDay!);
        }
      }
    });
  }

  static const Map<TraversalDirection, Duration> _directionOffset =
      <TraversalDirection, Duration>{
    TraversalDirection.up: Duration(days: -DateTime.daysPerWeek),
    TraversalDirection.right: Duration(days: 1),
    TraversalDirection.down: Duration(days: DateTime.daysPerWeek),
    TraversalDirection.left: Duration(days: -1),
  };

  Duration _dayDirectionOffset(
      TraversalDirection traversalDirection, TextDirection textDirection) {
    // Swap left and right if the text direction if RTL
    if (textDirection == TextDirection.rtl) {
      if (traversalDirection == TraversalDirection.left) {
        traversalDirection = TraversalDirection.right;
      } else if (traversalDirection == TraversalDirection.right) {
        traversalDirection = TraversalDirection.left;
      }
    }
    return _directionOffset[traversalDirection]!;
  }

  DateTime? _nextDateInDirection(DateTime date, TraversalDirection direction) {
    final textDirection = Directionality.of(context);
    var nextDate = date.add(_dayDirectionOffset(direction, textDirection));
    while (!nextDate.isBefore(widget.firstDate) &&
        !nextDate.isAfter(widget.lastDate)) {
      if (_isSelectable(nextDate)) {
        return nextDate;
      }
      nextDate = nextDate.add(_dayDirectionOffset(direction, textDirection));
    }
    return null;
  }

  bool _isSelectable(DateTime date) {
    return widget.selectableDayPredicate == null ||
        widget.selectableDayPredicate!.call(date);
  }

  Widget _buildItems(BuildContext context, int index) {
    final month = utils.addMonthsToMonthDate(widget.firstDate, index);
    return DayWidget(
      key: ValueKey<DateTime>(month),
      selectedDate: widget.selectedDate,
      selectedStartDate: _startDate,
      selectedEndDate: _endDate,
      selectionMode: widget.selectionMode,
      currentDate: widget.currentDate,
      onChanged: _handleDateSelected,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayedMonth: month,
      selectableDayPredicate: widget.selectableDayPredicate,
      dayBuilder: widget.dayBuilder,
      calendarStyle: widget.calendarStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final previousTooltipText =
        'Previous Month ${intl.DateFormat.yMMMM().format(_previousMonthDate)}';
    final nextTooltipText =
        'Next Month ${intl.DateFormat.yMMMM().format(_nextMonthDate)}';
    final controlColor = widget.calendarStyle?.arrowColor;

    return Semantics(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
            height: subHeaderHeight,
            child: Row(
              children: <Widget>[
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: controlColor,
                  tooltip: _isDisplayingFirstMonth ? null : previousTooltipText,
                  onPressed:
                      _isDisplayingFirstMonth ? null : _handlePreviousMonth,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: controlColor,
                  tooltip: _isDisplayingLastMonth ? null : nextTooltipText,
                  onPressed: _isDisplayingLastMonth ? null : _handleNextMonth,
                ),
              ],
            ),
          ),
          Expanded(
            child: FocusableActionDetector(
              shortcuts: _shortcutMap,
              actions: _actionMap,
              focusNode: _dayGridFocus,
              onFocusChange: _handleGridFocusChange,
              child: FocusedDate(
                date: _dayGridFocus.hasFocus ? _focusedDay : null,
                child: Container(
                  color: _dayGridFocus.hasFocus
                      ? Theme.of(context).focusColor
                      : null,
                  child: PageView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    key: _pageViewKey,
                    controller: _pageController,
                    itemBuilder: _buildItems,
                    itemCount:
                        utils.monthDelta(widget.firstDate, widget.lastDate) + 1,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: _handleMonthPageChanged,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
