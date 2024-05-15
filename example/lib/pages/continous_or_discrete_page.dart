import 'package:flutter/material.dart';
import 'package:flutter_multi_slider/flutter_multi_slider.dart';

class ContinousOrDiscretePage extends StatefulWidget {
  const ContinousOrDiscretePage({Key? key}) : super(key: key);

  @override
  State<ContinousOrDiscretePage> createState() => _ContinousOrDiscretePageState();
}

class _ContinousOrDiscretePageState extends State<ContinousOrDiscretePage> {
  var _continuousValue = <double>[10, 20, 30, 40];
  var _discreteValue = <double>[10, 20, 30, 40];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Continuous vs Discrete MultiSlider'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Continuous Value: ${_continuousValue.map((e) => e.toStringAsFixed(1))}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            MultiSlider(
              values: _continuousValue,
              min: 0.0,
              max: 100.0,
              onChanged: (values) {
                setState(() {
                  _continuousValue = values;
                });
              },
            ),
            const SizedBox(height: 32.0),
            Text(
              'Discrete Value: ${_discreteValue.map((e) => e.toStringAsFixed(1))}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            MultiSlider(
              values: _discreteValue,
              min: 0.0,
              max: 100.0,
              divisions: 10,
              onChanged: (values) {
                setState(() {
                  _discreteValue = values;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
