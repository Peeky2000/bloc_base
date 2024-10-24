// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Signature for predicating dates for enabled date selections.
typedef SelectableDayPredicate = bool Function(DateTime day);

/// Encapsulates a start and end [DateTime] that represent the range of dates
/// between them.
@immutable
class CustomDateTimeRange {
  /// Creates a date range for the given start and end [DateTime].
  ///
  /// [start] and [end] must be non-null.
  const CustomDateTimeRange({
    required this.start,
    required this.end,
  });

  /// The start of the range of dates.
  final DateTime start;

  /// The end of the range of dates.
  final DateTime end;

  /// Returns a [Duration] of the time between [start] and [end].
  ///
  /// See [DateTime.difference] for more details.
  Duration get duration => end.difference(start);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is CustomDateTimeRange &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => hashValues(start, end);

  @override
  String toString() => '$start - $end';
}
