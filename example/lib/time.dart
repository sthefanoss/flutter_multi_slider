import 'package:flutter/foundation.dart';

@immutable
class Time {
  const Time({this.hours = 0, this.minutes = 0});

  factory Time.fromMinutes(int minutes) {
    return Time(hours: minutes ~/ 60, minutes: minutes % 60);
  }

  static Time parse(String source) {
    final slices = source.split(':');
    return Time(
      hours: int.parse(slices[0]),
      minutes: int.parse(slices[1]),
    );
  }

  static const firstTimeOfDay = Time(hours: 0, minutes: 0);

  static const lastTimeOfDay = Time(hours: 23, minutes: 59);

  final int hours;

  final int minutes;

  int get inMinutes => hours * 60 + minutes;

  Time operator +(Time other) => Time.fromMinutes(
        inMinutes + other.inMinutes,
      );

  Time operator -(Time other) => Time.fromMinutes(
        inMinutes - other.inMinutes,
      );

  Time operator -() => Time.fromMinutes(-inMinutes);

  Time operator *(num factor) => Time.fromMinutes(
        (inMinutes * factor).round(),
      );

  Time operator /(num factor) => Time.fromMinutes(
        (inMinutes / factor).round(),
      );

  @override
  bool operator ==(other) {
    if (other is Time) {
      return minutes == other.minutes && //
          hours == other.hours;
    }
    return false;
  }

  bool operator <(Time other) {
    return hours < other.hours || (hours == other.hours && minutes < other.minutes);
  }

  @override
  String toString() {
    final hoursSegments = hours.toString().padLeft(2, '0');
    final minutesSegments = minutes.toString().padLeft(2, '0');
    return hoursSegments + ':' + minutesSegments;
  }

  @override
  int get hashCode => inMinutes.hashCode;

  static List<Time> linSpace({
    required Time start,
    required Time end,
    required Time increment,
  }) {
    final generatedValues = <Time>[];
    Time sum = start;
    while (sum < end) {
      generatedValues.add(sum);
      sum += increment;
    }

    return generatedValues..add(end);
  }
}
