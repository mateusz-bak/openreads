import 'package:easy_localization/easy_localization.dart';
import 'package:openreads/generated/locale_keys.g.dart';

// Converts milliseconds to days, hours, minutes to exactly what has been set.
// This is needed because built-in DateTime returns the whole duration either in days or hours but not both
class ReadingTime {
  int days;
  int hours;
  int minutes;

  int milliSeconds;

  ReadingTime(
      {required this.milliSeconds,
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
        milliSeconds: milliSeconds, days: days, minutes: minutes, hours: hours);
  }

  factory ReadingTime.toMilliSeconds(int days, hours, minutes) {
    int seconds = ((days * 86400) + (hours * 3600) + (minutes * 60)).toInt();
    return ReadingTime(
        milliSeconds: seconds * 1000,
        days: days,
        minutes: minutes,
        hours: hours);
  }

  @override
  String toString() {
    String result = "";
    if (days != 0) {
      result += LocaleKeys.day.plural(days).tr();
    }

    if (hours != 0) {
      if (result.isNotEmpty) {
        result += " ";
      }

      result += LocaleKeys.hour.plural(hours).tr();
    }

    if (minutes != 0) {
      if (result.isNotEmpty) {
        result += " ";
      }

      result += LocaleKeys.minute.plural(minutes).tr();
    }
    return result;
  }
}
