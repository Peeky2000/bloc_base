import 'dart:ui';

import 'package:intl/intl.dart';

final _dateFormatFull = DateFormat('dd/MM/yyyy HH:mm:ss');
final _dateFormatDMYHHmm = DateFormat('dd/MM/yyyy HH:mm');
final _dateFormatDMY = DateFormat('dd/MM/yyyy');
final _formatYMDHMS = DateFormat('yyyyMMddHHmmss');
final _dateFormatDM = DateFormat('dd/MM');
final _dateFormatY = DateFormat('yyyy');
final _dateFormatM = DateFormat('MM');
final _dateFormatD = DateFormat('dd');
final _dateFormatDMYcf = DateFormat('yyyy-MM-ddTHH:mm:ss');
final _dateFormat24h = DateFormat('HH:mm dd/MM/yyyy');
final _formatDate = DateFormat('dd-MM-yyyy');
final _formatHours = DateFormat('hh:mm a');
final _formatDateTime = DateFormat('hh:mm a dd/MM/yyyy');
final _formatMMMYYYY = DateFormat('MMMM yyyy');
final _formatMMYYYY = DateFormat('MM/yyyy');
final _formatEEE = DateFormat('EEE');
final _formatWithOutYY = DateFormat('HH:mm dd MMM');
final formatTime24h = DateFormat('HH:mm');
final formatDMYHHmm = DateFormat('dd/MM/yyyy HH:mm');
final _dateFormatYMD = DateFormat('yyyy-MM-dd');
final _formatTime24h = DateFormat('HH:mm');
final _dateFormatDMYHHmma = DateFormat('dd/MM/yyyy HH:mm a');
final _dateFormatDDMMYY = DateFormat('dd/MM/yy');
final _dateFormatyyyyMMddPlusHHmmss = DateFormat('yyyy-MM-dd+HH:mm:ss');
final _dateFormatyyyyMMddHHmmssSub = DateFormat('yyyy-MM-dd HH:mm:ss');

extension DateTimeExtension on DateTime? {
  String get formatDM => (this != null) ? _dateFormatDM.format(this!) : '';

  String get formatYY => (this != null) ? _dateFormatY.format(this!) : '';

  String get formatMM => (this != null) ? _dateFormatM.format(this!) : '';

  String get formatDD => (this != null) ? _dateFormatD.format(this!) : '';

  String get formatDMY => (this != null) ? _dateFormatDMY.format(this!) : '';

  String get formatYMDHMS => (this != null) ? _formatYMDHMS.format(this!) : '';

  String get formatDMYHHmm => (this != null) ? _dateFormatDMYHHmm.format(this!) : '';

  String get formatFull => (this != null) ? _dateFormatFull.format(this!) : '';

  String get format24h => (this != null) ? _dateFormat24h.format(this!) : '';

  String get formatMMMYYYY => (this != null) ? _formatMMMYYYY.format(this!) : '';

  String get formatEEE => (this != null) ? _formatEEE.format(this!) : '';

  String get formatMMYYYY => (this != null) ? _formatMMYYYY.format(this!) : '';

  String get formatWithOutYY => (this != null) ? _formatWithOutYY.format(this!) : '';

  String get formatYMD => (this != null) ? _dateFormatYMD.format(this!) : '';

  String get formatDMYHHmma => (this != null) ? _dateFormatDMYHHmma.format(this!) : '';

  String get formatHHMM => (this != null) ? _formatTime24h.format(this!) : '';

  String get formatDDMMYY => (this != null) ? _dateFormatDDMMYY.format(this!) : '';
  
  String get format12H => (this != null) ? _formatDateTime.format(this!) : '';
  
  String get formatDate => (this != null) ? _formatDate.format(this!) : '';
  
  String get formatDMYcf => (this != null) ? _dateFormatDMYcf.format(this!) : '';

  String get formatyyyyMMddPlusHHmmss => (this != null) ? _dateFormatyyyyMMddPlusHHmmss.format(this!) : '';

  String get formatyyyyMMddHHmmssSub => (this != null) ? _dateFormatyyyyMMddHHmmssSub.format(this!) : '';

  String get chatTime {
    if (this == null) return '';
    final now = DateTime.now();
    if (now.formatDMY == formatDMY) {
      return _formatHours.format(this!);
    }
    return DateFormat('hh:mm a dd/MM').format(this!);
  }

  String chatTime24h(Locale locale) {
    if (this == null) return '';
    final now = DateTime.now();
    final tomorrow = this!.startDay?.add(const Duration(days: 1));
    if (now.formatDMY == formatDMY || tomorrow.formatDMY == formatDMY) {
      return _formatHours.format(this!);
    }
    return DateFormat('HH:mm, dd MMMM, yyyy', locale.languageCode).format(this!);
  }

  DateTime? get startDay {
    return this == null ? null : DateTime(this!.year, this!.month, this!.day, 0, 0, 0, 0, 0);
  }

  DateTime? get endDay {
    return this == null ? null : DateTime(this!.year, this!.month, this!.day, 23, 59, 59, 0, 0);
  }

  String customFormatDate({required String format, String? locale}) {
    DateFormat dateFormat = DateFormat(format, locale);
    return (this != null) ? dateFormat.format(this!) : '';
  }
}
