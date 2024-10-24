import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart' as intl;

import 'calendar_date_picker.dart';
import 'calendar_style.dart';
import 'date_picker_common.dart' as common;
import 'date_utils.dart' as utils;
import 'date_utils.dart';

class DayWidget extends StatefulWidget {
  /// Creates a day picker.
  DayWidget({
    Key? key,
    required this.currentDate,
    required this.displayedMonth,
    required this.firstDate,
    required this.lastDate,
    this.selectedDate,
    this.onChanged,
    this.calendarStyle,
    this.dayBuilder,
    this.selectableDayPredicate,
    this.selectionMode = SelectionMode.single,
    this.onEndDateChanged,
    this.onStartDateChanged,
    this.selectedEndDate,
    this.selectedStartDate,
  })  : assert(!firstDate.isAfter(lastDate)),
        super(key: key);

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime? selectedDate;

  final DateTime? selectedStartDate;

  final DateTime? selectedEndDate;

  /// The current date at the time the picker is displayed.
  final DateTime currentDate;

  /// Called when the user picks a day.
  final ValueChanged<DateTime>? onChanged;

  /// The earliest date the user is permitted to pick.
  ///
  /// This date must be on or before the [lastDate].
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  ///
  /// This date must be on or after the [firstDate].
  final DateTime lastDate;

  /// The month whose days are displayed by this picker.
  final DateTime displayedMonth;

  /// Builds the widget for particular day.
  final Widget Function(DateTime)? dayBuilder;

  final CalendarStyle? calendarStyle;

  /// Optional user supplied predicate function to customize selectable days.
  final common.SelectableDayPredicate? selectableDayPredicate;

  final SelectionMode? selectionMode;

  /// Called when the user changes the start date of the selected range.
  final ValueChanged<DateTime>? onStartDateChanged;

  /// Called when the user changes the end date of the selected range.
  final ValueChanged<DateTime>? onEndDateChanged;

  @override
  _DayPickerState createState() => _DayPickerState();
}

class _DayPickerState extends State<DayWidget> {
  /// List of [FocusNode]s, one for each day of the month.
  late List<FocusNode> _dayFocusNodes;

  @override
  void initState() {
    super.initState();
    final daysInMonth = utils.getDaysInMonth(
        widget.displayedMonth.year, widget.displayedMonth.month);
    _dayFocusNodes = List<FocusNode>.generate(
      daysInMonth,
      (index) => FocusNode(skipTraversal: true, debugLabel: 'Day ${index + 1}'),
    );
  }

  @override
  void didUpdateWidget(covariant DayWidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check to see if the focused date is in this month, if so focus it.
    final focusedDate = FocusedDate.of(context);
    if (focusedDate != null &&
        utils.isSameMonth(widget.displayedMonth, focusedDate)) {
      _dayFocusNodes[focusedDate.day - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    for (final node in _dayFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Builds widgets showing abbreviated days of week. The first widget in the
  /// returned list corresponds to the first day of week for the current locale.
  List<Widget> _dayHeaders(TextStyle? headerStyle) {
    return ['TH 2', 'TH 3', 'TH 4', 'TH 5', 'TH 6', 'TH 7', 'CN']
        .map<Widget>(
          (label) => ExcludeSemantics(
            child: Center(
              child: Text(label, style: headerStyle),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final year = widget.displayedMonth.year;
    final month = widget.displayedMonth.month;
    final daysInMonth = utils.getDaysInMonth(year, month);
    final dayOffset = utils.firstDayOffset(year, month);
    bool isRangeSelected = false;
    bool isSelectedDayStart = false;
    bool isSelectedDayEnd = false;
    bool isInRange = false;
    bool isSelectedDay = false;
    bool isToday = false;
    final dayItems = _dayHeaders(widget.calendarStyle?.weekTitleStyle);
    var day = -dayOffset;
    while (day < daysInMonth) {
      day++;
      if (day < 1) {
        dayItems.add(Container());
      } else {
        final dayToBuild = DateTime(year, month, day);
        final isDisabled = dayToBuild.isAfter(widget.lastDate) ||
            dayToBuild.isBefore(widget.firstDate) ||
            (widget.selectableDayPredicate != null &&
                !widget.selectableDayPredicate!(dayToBuild));
        if (widget.selectedDate != null && widget.selectionMode != SelectionMode.range) {
          isSelectedDay = utils.isSameDay(widget.selectedDate, dayToBuild);
        }

        isToday = utils.isSameDay(widget.currentDate, dayToBuild);

        BoxDecoration? decoration;
        BoxDecoration? decorationRange;
        Color? dayRangeFocusColor;
        var dayStyle = widget.calendarStyle?.dayNormalStyle;
        if (widget.selectionMode == SelectionMode.range) {
          isRangeSelected = widget.selectedEndDate != null;
          isSelectedDayStart =
              utils.isSameDay(widget.selectedStartDate, dayToBuild);
          isSelectedDayEnd = widget.selectedEndDate != null &&
              utils.isSameDay(widget.selectedEndDate!, dayToBuild);
          isInRange = isRangeSelected &&
              dayToBuild.isAfter(widget.selectedStartDate!) &&
              dayToBuild.isBefore(widget.selectedEndDate!);
        }
        dayRangeFocusColor = widget.calendarStyle?.dayRangeFocusColor;

        if (isSelectedDay || isSelectedDayStart || isSelectedDayEnd) {
          // The selected day gets a circle background highlight, and a
          // contrasting text color.
          dayStyle = widget.calendarStyle?.daySelectedStyle;
          decoration = widget.calendarStyle?.daySelectedDecoration;
          if (isRangeSelected &&
              widget.selectedStartDate != widget.selectedEndDate) {
            dayStyle = widget.calendarStyle?.daySelectedStyle;
            if (isSelectedDayStart) {
              decorationRange = BoxDecoration(
                  color: dayRangeFocusColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(100),
                      bottomLeft: Radius.circular(100)));
            } else {
              decorationRange = BoxDecoration(
                  color: dayRangeFocusColor,
                  borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(100),
                      topRight: Radius.circular(100)));
            }
          }
        } else if (isDisabled) {
          dayStyle = widget.calendarStyle?.dayDisableStyle;
        } else if (isInRange) {
          // The days within the range get a light background highlight.
          dayStyle = widget.calendarStyle?.dayNormalStyle;
          decorationRange = BoxDecoration(
            color: dayRangeFocusColor,
          );
        } else if (isToday) {
          dayStyle = widget.calendarStyle?.currentDayStyle;
        }

        Widget dayWidget = Container(
          decoration: decorationRange,
          child: Container(
            margin: const EdgeInsets.only(top: 6,bottom: 6, left: 4, right: 4),
            decoration: decoration,
            child: widget.dayBuilder == null
                ? Center(
                    child: Text(
                      day.toString(),
                      style: dayStyle,
                    ),
                  )
                : widget.dayBuilder!(dayToBuild),
          ),
        );

        if (isDisabled) {
          dayWidget = ExcludeSemantics(
            child: dayWidget,
          );
        } else {
          dayWidget = InkResponse(
            focusNode: _dayFocusNodes[day - 1],
            onTap: () => widget.onChanged?.call(dayToBuild),
            radius: dayPickerRowHeight / 2 + 4,
            //splashColor: selectedDayBackground.withOpacity(0.38),
            child: Semantics(
              // We want the day of month to be spoken first irrespective of the
              // locale-specific preferences or TextDirection. This is because
              // an accessibility user is more likely to be interested in the
              // day of month before the rest of the date, as they are looking
              // for the day of month. To do that we prepend day of month to the
              // formatted full date.
              label:
                  '${intl.NumberFormat().format(day)}, ${intl.DateFormat.yMMMMEEEEd().format(dayToBuild)}',
              selected: isSelectedDay,
              excludeSemantics: true,
              child: dayWidget,
            ),
          );
        }
        dayItems.add(dayWidget);
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: monthPickerHorizontalPadding,
      ),
      child: GridView.custom(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 9.0,
            childAspectRatio: 1,
            mainAxisExtent: dayPickerRowHeight,
            crossAxisCount: DateTime.daysPerWeek),
        childrenDelegate: SliverChildListDelegate(
          dayItems,
          addRepaintBoundaries: false,
        ),
      ),
    );
  }
}

class DayPickerGridDelegate extends SliverGridDelegate {
  const DayPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const columnCount = DateTime.daysPerWeek;
    final tileWidth = constraints.crossAxisExtent / columnCount;
    final tileHeight = dayPickerRowHeight;
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: tileHeight,
      crossAxisCount: columnCount,
      crossAxisStride: tileWidth,
      mainAxisStride: tileHeight,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(DayPickerGridDelegate oldDelegate) => false;
}

const DayPickerGridDelegate _dayPickerGridDelegate = DayPickerGridDelegate();
enum _HighlightPainterStyle {
  /// Paints nothing.
  none,

  /// Paints a rectangle that occupies the leading half of the space.
  highlightLeading,

  /// Paints a rectangle that occupies the trailing half of the space.
  highlightTrailing,

  /// Paints a rectangle that occupies all available space.
  highlightAll,
}

class _HighlightPainter extends CustomPainter {
  _HighlightPainter({
    required this.color,
    this.style = _HighlightPainterStyle.none,
    this.textDirection,
  });

  final Color color;
  final _HighlightPainterStyle style;
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    if (style == _HighlightPainterStyle.none) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final rectLeft = Rect.fromLTWH(0, 0, size.width / 2, size.height);
    final rectRight =
        Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height);

    switch (style) {
      case _HighlightPainterStyle.highlightTrailing:
        canvas.drawRect(
          textDirection == TextDirection.ltr ? rectRight : rectLeft,
          paint,
        );
        break;
      case _HighlightPainterStyle.highlightLeading:
        canvas.drawRect(
          textDirection == TextDirection.ltr ? rectLeft : rectRight,
          paint,
        );
        break;
      case _HighlightPainterStyle.highlightAll:
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          paint,
        );
        break;
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
