import 'package:easy_localization/easy_localization.dart';
import 'package:openreads/generated/locale_keys.g.dart';

class ReadingTime {
  int days;
  int hours;
  int minutes;

  int timeInMilliSeconds;

  ReadingTime(
      {required this.timeInMilliSeconds,
      required this.days,
      required this.minutes,
      required this.hours});

  factory ReadingTime.fromMilliSeconds(int milliSeconds) {
    int timeInSeconds = milliSeconds ~/ 1000;
    int days = timeInSeconds ~/ (24 * 3600);

    timeInSeconds = timeInSeconds % (24 * 3600);
    int hours = timeInSeconds ~/ 3600;

    timeInSeconds %= 3600;
    int minutes = timeInSeconds ~/ 60;

    return ReadingTime(
        timeInMilliSeconds: milliSeconds,
        days: days,
        minutes: minutes,
        hours: hours);
  }

  factory ReadingTime.toMilliSeconds(int days, hours, minutes) {
    int seconds = ((days * 86400) + (hours * 3600) + (minutes * 60)).toInt();
    return ReadingTime(
        timeInMilliSeconds: seconds * 1000,
        days: days,
        minutes: minutes,
        hours: hours);
  }

  @override
  String toString() {
    String result = "";
    if (days != 0) {
      result += "$days ${LocaleKeys.days.tr()}";
    }
    if (hours != 0) {
      result += " $hours ${LocaleKeys.hours.tr()}";
    }
    if (minutes != 0) {
      result += " $minutes ${LocaleKeys.minutes.tr()}";
    }
    return result;
  }
}
