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
  List<double> values1 = [1 / 2];
  List<double> values2 = [1 / 3, 2 / 3];
  List<double> values3 = [1 / 4, 2 / 4, 3 / 4];
  List<double> values4 = [1 / 5, 2 / 5, 3 / 5, 4 / 5];
  double singleValue = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MultiSlider :)'),
      ),
      body: Column(
        children: <Widget>[
          Slider(
            value: singleValue,
            onChanged: (value) => setState(() => singleValue = value),
          ),
          Slider(
            value: singleValue,
            onChanged: null, //(value) => setState(() => singleValue = value),
          ),
          MultiSlider(
            values: values1,
            onChanged: (values) => setState(() => values1 = values),
          ),
          MultiSlider(
            values: values1,
            onChanged: null, // (values) => setState(() => values1 = values),
          ),
          MultiSlider(
            color: Colors.green,
            values: values2,
            onChanged: (values) => setState(() => values2 = values),
            onChangeStart: (values) {
              setState(() => values2 = values);
              print('going from $values');
            },
            onChangeEnd: (values) {
              setState(() => values2 = values);
              print('to $values');
            },
          ),
          MultiSlider(
            values: values3,
            onChanged: null,
          ),
          MultiSlider(
            values: values4,
            onChanged: (values) => setState(() => values4 = values),
            color: Colors.red,
            divisionPainterCallback: (division) => division.index % 2 == 1,
          ),
          MultiSlider(
            values: values4,
            onChanged: (values) => setState(() => values4 = values),
            color: Colors.red,
            divisionPainterCallback: (division) => division.index % 2 == 0,
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
