import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String get toDateDisplay => DateFormat('dd/MM/yyyy').format(this);

  String get toDateTimeDisplay => DateFormat('dd/MM/yyyy HH:mm').format(this);

  String get toTimeDisplay => DateFormat('HH:mm').format(this);

  String get toIso8601Display => toUtc().toIso8601String();

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  String get toRelativeDisplay {
    if (isToday) return toTimeDisplay;
    if (isYesterday) return 'Hôm qua $toTimeDisplay';
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return toDateDisplay;
  }

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}

extension NullableDateTimeExtensions on DateTime? {
  String get toDateDisplayOrDash => this?.toDateDisplay ?? '—';

  String get toDateTimeDisplayOrDash => this?.toDateTimeDisplay ?? '—';
}
