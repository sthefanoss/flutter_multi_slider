import 'package:example/pages/continous_or_discrete_page.dart';
import 'package:example/pages/schedule_input_page.dart';
import 'package:flutter/material.dart';

class PageItem {
  final String title;
  final String description;
  final Widget Function() page;

  const PageItem({
    required this.title,
    required this.description,
    required this.page,
  });
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final options = [
      PageItem(
        title: 'Continouts or Discrete  Input',
        description: 'This example shows how to use the MultiSlider with continuous or discrete values.',
        page: () => const ContinousOrDiscretePage(),
      ),
      PageItem(
        title: 'Schedule Input',
        description: 'This example shows how to use the MultiSlider to input a schedule.',
        page: () => const SchedulePage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Multislider Catalog')),
      body: ListView.separated(
        itemCount: options.length,
        separatorBuilder: (context, index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(height: 0),
        ),
        itemBuilder: (context, index) => ListTile(
          title: Text(options[index].title),
          subtitle: Text(options[index].description),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => options[index].page(),
            ),
          ),
        ),
      ),
    );
  }
}
