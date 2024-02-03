import 'package:openreads/model/reading_time.dart';

class Reading {
  DateTime? startDate;
  DateTime? finishDate;
  ReadingTime? customReadingTime;

  Reading({
    this.startDate,
    this.finishDate,
    this.customReadingTime,
  });

  factory Reading.fromString(String input) {
    List<String> dateAndValue = input.split('|');

    if (dateAndValue.length != 3) {
      return Reading();
    }

    DateTime? startDate =
        dateAndValue[0] != '' ? DateTime.parse(dateAndValue[0]) : null;
    DateTime? finishDate =
        dateAndValue[1] != '' ? DateTime.parse(dateAndValue[1]) : null;
    final customReadingTime = dateAndValue[2] != ''
        ? ReadingTime.fromMilliSeconds(
            int.parse(dateAndValue[2]),
          )
        : null;

    return Reading(
      startDate: startDate,
      finishDate: finishDate,
      customReadingTime: customReadingTime,
    );
  }

  @override
  String toString() {
    final startDate =
        this.startDate != null ? this.startDate!.toIso8601String() : '';
    final finishDate =
        this.finishDate != null ? this.finishDate!.toIso8601String() : '';
    final customReadingTime = this.customReadingTime != null
        ? this.customReadingTime!.milliSeconds.toString()
        : '';

    return '$startDate|$finishDate|$customReadingTime';
  }

  Reading copyWith({
    DateTime? startDate,
    DateTime? finishDate,
    ReadingTime? customReadingTime,
  }) {
    return Reading(
      startDate: startDate ?? this.startDate,
      finishDate: finishDate ?? this.finishDate,
      customReadingTime: customReadingTime ?? this.customReadingTime,
    );
  }
}
