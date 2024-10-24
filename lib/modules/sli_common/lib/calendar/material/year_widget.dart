import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'calendar_style.dart';
import 'date_utils.dart';

/// Displays the days of a given month and allows choosing a day.
///
/// The days are arranged in a rectangular grid with one column for each day of
/// the week.

/// A scrollable list of years to allow picking a year.
class YearWidget extends StatefulWidget {
  /// Creates a year picker.
  ///
  /// The [currentDate, [firstDate], [lastDate], [selectedDate], and [onChanged]
  /// arguments must be non-null. The [lastDate] must be after the [firstDate].
  YearWidget({
    Key? key,
    required this.currentDate,
    required this.firstDate,
    required this.lastDate,
    required this.initialDate,
    this.calendarStyle,
    this.selectedDate,
    this.onChanged,
  })  : assert(!firstDate.isAfter(lastDate)),
        super(key: key);

  /// The current date.
  ///
  /// This date is subtly highlighted in the picker.
  final DateTime currentDate;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// The initial date to center the year display around.
  final DateTime initialDate;

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime? selectedDate;

  final CalendarStyle? calendarStyle;

  /// Called when the user picks a year.
  final ValueChanged<DateTime>? onChanged;

  @override
  _YearPickerState createState() => _YearPickerState();
}

class _YearPickerState extends State<YearWidget> {
  late ScrollController scrollController;

  // The approximate number of years necessary to fill the available space.
  static const int minYears = 18;
  int? initialYearIndex;
  int? initialYearRow;
  @override
  void initState() {
    super.initState();

    // Set the scroll position to approximately center the initial year.
    if (widget.selectedDate!=null) {
      initialYearIndex = widget.selectedDate!.year - widget.firstDate.year;
      initialYearRow = initialYearIndex! ~/ yearPickerColumnCount;
      final centeredYearRow = initialYearRow! - 2;
      final scrollOffset =
      _itemCount < minYears ? 0.0 : centeredYearRow * yearPickerRowHeight;
      scrollController = ScrollController(initialScrollOffset: scrollOffset);
    }
    // Move the offset down by 2 rows to approximately center it.
  }

  Widget _buildYearItem(BuildContext context, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Backfill the _YearPicker with disabled years if necessary.
    final offset = _itemCount < minYears ? (minYears - _itemCount) ~/ 2 : 0;
    final year = widget.firstDate.year + index - offset;
    final isSelected = year == widget.selectedDate?.year;
    final isCurrentYear = year == widget.currentDate.year;
    final isDisabled =
        year < widget.firstDate.year || year > widget.lastDate.year;
    const decorationHeight = 36.0;
    const decorationWidth = 72.0;

    Color textColor;
    if (isSelected) {
      textColor = colorScheme.onPrimary;
    } else if (isDisabled) {
      textColor = colorScheme.onSurface.withOpacity(0.38);
    } else if (isCurrentYear) {
      textColor = colorScheme.primary;
    } else {
      textColor = colorScheme.onSurface.withOpacity(0.87);
    }
    final itemStyle = textTheme.bodyLarge?.apply(color: textColor);

    BoxDecoration? decoration;
    if (isSelected) {
      decoration = widget.calendarStyle?.yearFocusDecoration ?? BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(decorationHeight / 2),
        shape: BoxShape.rectangle,
      );
    } else if (isCurrentYear && !isDisabled) {
      decoration = BoxDecoration(
        border: Border.all(
          color: colorScheme.primary,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(decorationHeight / 2),
        shape: BoxShape.rectangle,
      );
    }

    Widget yearItem = Center(
      child: Container(
        decoration: decoration,
        height: decorationHeight,
        width: decorationWidth,
        child: Center(
          child: Semantics(
            selected: isSelected,
            child: Text(
              year.toString(),
              style: itemStyle,
            ),
          ),
        ),
      ),
    );

    if (isDisabled) {
      yearItem = ExcludeSemantics(
        child: yearItem,
      );
    } else {
      yearItem = InkWell(
        key: ValueKey<int>(year),
        onTap: () {
          widget.onChanged?.call(
            DateTime(
              year,
              widget.initialDate.month,
              widget.initialDate.day,
            ),
          );
        },
        child: yearItem,
      );
    }

    return yearItem;
  }

  int get _itemCount {
    return widget.lastDate.year - widget.firstDate.year + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Divider(),
        Expanded(
          child: GridView.builder(
            controller: scrollController,
            gridDelegate: _yearPickerGridDelegate,
            itemBuilder: _buildYearItem,
            itemCount: math.max(_itemCount, minYears),
            padding: const EdgeInsets.symmetric(horizontal: yearPickerPadding),
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class _YearPickerGridDelegate extends SliverGridDelegate {
  const _YearPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final tileWidth = (constraints.crossAxisExtent -
        (yearPickerColumnCount - 1) * yearPickerRowSpacing) /
        yearPickerColumnCount;
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: yearPickerRowHeight,
      crossAxisCount: yearPickerColumnCount,
      crossAxisStride: tileWidth + yearPickerRowSpacing,
      mainAxisStride: yearPickerRowHeight,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_YearPickerGridDelegate oldDelegate) => false;
}

const _YearPickerGridDelegate _yearPickerGridDelegate =
_YearPickerGridDelegate();
