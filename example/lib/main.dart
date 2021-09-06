import 'package:example/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_slider/flutter_multi_slider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        home: MyHomePage(),
      );
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<double> monday = [0.1, 0.2];
  List<double> tuesday = [0.1, 0.2, 0.4, 0.5];
  List<double> wednesday = [0.1, 0.2];
  List<double> thursday = [0.1, 0.2, 0.4, 0.5, 0.6, 0.7];
  List<double> friday = [0.1, 0.2, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9];
  bool mondayEnabled = true;
  bool tuesdayEnabled = true;
  bool wednesdayEnabled = true;
  bool thursdayEnabled = true;
  bool fridayEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MultiSlider'),
      ),
      body: ListView(
        children: <Widget>[
          WeekDaySchedule(
            weekDay: 'Monday',
            values: monday,
            onChanged: (value) => setState(() => monday = value),
            enabled: mondayEnabled,
            onToggle: (value) => setState(() => mondayEnabled = value),
          ),
          WeekDaySchedule(
            weekDay: 'Tuesday',
            values: tuesday,
            onChanged: (value) => setState(() => tuesday = value),
            enabled: tuesdayEnabled,
            onToggle: (value) => setState(() => tuesdayEnabled = value),
          ),
          WeekDaySchedule(
            weekDay: 'Wednesday',
            values: wednesday,
            onChanged: (value) => setState(() => wednesday = value),
            enabled: wednesdayEnabled,
            onToggle: (value) => setState(() => wednesdayEnabled = value),
          ),
          WeekDaySchedule(
            weekDay: 'Thursday',
            values: thursday,
            onChanged: (value) => setState(() => thursday = value),
            enabled: thursdayEnabled,
            onToggle: (value) => setState(() => thursdayEnabled = value),
          ),
          WeekDaySchedule(
            weekDay: 'Friday',
            values: friday,
            onChanged: (value) => setState(() => friday = value),
            enabled: fridayEnabled,
            onToggle: (value) => setState(() => fridayEnabled = value),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class WeekDaySchedule extends StatelessWidget {
  const WeekDaySchedule({
    required this.values,
    required this.weekDay,
    required this.onChanged,
    required this.onToggle,
    required this.enabled,
    Key? key,
  }) : super(key: key);

  final List<double> values;

  final String weekDay;

  final ValueChanged<List<double>> onChanged;

  final ValueChanged<bool> onToggle;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final chartTextFont = TextStyle(fontSize: 12);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    weekDay + ' schedule',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                  ),
                ),
                Switch(value: enabled, onChanged: onToggle),
              ],
            ),
          ),
          MultiSlider(
            values: values,
            onChanged: enabled ? onChanged : null,
            valueRangePainterCallback: (range) => range.index % 2 == 1,
            divisions: 48,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19.0, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0h', style: chartTextFont),
                Text('6h', style: chartTextFont),
                Text('12h', style: chartTextFont),
                Text('18h', style: chartTextFont),
                Text('24h', style: chartTextFont),
              ],
            ),
          ),
          SizedBox(height: 8),
          if (enabled) ...[
            for (int index = 0; index < values.length; index += 2)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Text(
                  'Shift ${index ~/ 2 + 1} starts at ${lerpTime(values[index])} and ends at ${lerpTime(values[index + 1])}.',
                ),
              ),
          ] else
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 2),
              child: Text('No shifts today.'),
            ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}

final start = Time(hours: 0, minutes: 0);

final end = Time(hours: 24, minutes: 0);

Time lerpTime(double x) => start + (end - start) * x;
