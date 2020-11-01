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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MultiSlider :)'),
      ),
      body: Column(
        children: <Widget>[
          MultiSlider(
            values: values1,
            onChanged: (values) => setState(() => values1 = values),
          ),
          MultiSlider(
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
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
