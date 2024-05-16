import 'package:flutter/material.dart';
import 'package:flutter_multi_slider/flutter_multi_slider.dart';

class ThemeDataTest extends StatefulWidget {
  const ThemeDataTest({Key? key}) : super(key: key);
  @override
  _ThemeDataTestState createState() => _ThemeDataTestState();
}

class _ThemeDataTestState extends State<ThemeDataTest> {
  double _slider = 10;
  var _multiSliderValues = <double>[10,  20, 30, 40];
  var _rangeSliderValues = const RangeValues(10, 20);

  @override
  Widget build(BuildContext context) {
    final testTheme = const SliderThemeData(
      activeTickMarkColor: Colors.brown,
      inactiveTickMarkColor: Colors.yellow,
      // disabledActiveTickMarkColor: ,
      // trackHeight: ,

      activeTrackColor: Colors.red,
      inactiveTrackColor: Colors.green,
      thumbColor: Colors.blue,
      // disabledThumbColor: ,
      overlayColor: Colors.amber,
    );
    final children = [
      const Text(
        'Slider',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      Slider(
        value: _slider,
        onChanged: (value) => setState(() => _slider = value),
        min: 0,
        max: 100,
        divisions: 10,
        label: '$_slider',
      ),
      Slider(
        value: _slider,
        onChanged: null,
        min: 0,
        max: 100,
        divisions: 10,
        label: '$_slider',
      ),
      const Text(
        'Range Slider',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      RangeSlider(
        values: _rangeSliderValues,
        onChanged: (values) {
          setState(() {
            _rangeSliderValues = values;
          });
        },
        min: 0,
        max: 100,
        divisions: 10,
        labels: RangeLabels(
          _rangeSliderValues.start.toString(),
          _rangeSliderValues.end.toString(),
        ),
      ),
      RangeSlider(
        values: _rangeSliderValues,
        onChanged: null,
        min: 0,
        max: 100,
        divisions: 10,
        labels: RangeLabels(
          _rangeSliderValues.start.toString(),
          _rangeSliderValues.end.toString(),
        ),
      ),
      const Text(
        'Multi Slider',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      MultiSlider(
        values: _multiSliderValues,
        onChanged: (values) {
          setState(() {
            _multiSliderValues = values;
          });
        },
        min: 0,
        max: 100,
        divisions: 10,
        indicator: (value) => IndicatorOptions(
            draw: true,
            formatter: (v) => v.toStringAsFixed(0),
            style: const TextStyle(fontSize: 16, color: Colors.black)),
      ),
      MultiSlider(
        values: _multiSliderValues,
        onChanged: null,
        min: 0,
        max: 100,
        divisions: 10,
        indicator: (value) => IndicatorOptions(
            draw: true,
            formatter: (v) => v.toStringAsFixed(0),
            style: const TextStyle(fontSize: 16, color: Colors.black)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme data test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test without theme data',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...children,
            const SizedBox(height: 16),
            const Text(
              'Test with theme data',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SliderTheme(
              data: testTheme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
