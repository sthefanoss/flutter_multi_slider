# MultiSlider

A custom Slider which accepts a list of ordered values. It's meant to be as simple as the original Slider!

# UI with it

<img src="https://raw.githubusercontent.com/sthefanoss/flutter_multi_slider/main/giphy.gif" width="250">

# Usages
## Continuous slider.
```dart
MultiSlider(
    values: _myList,
    onChanged: (values) => setState(()=> _myList = values),
),
```
## Discrete slider. 
```dart
MultiSlider(
    values: _myList,
    onChanged: (values) => setState(()=> _myList = values),
    divisions: 10,
),
```
## With custom trace pattern. 
```dart
MultiSlider(
    values: _myList,
    onChanged: (values) => setState(()=> _myList = values),
    valueRangePainterCallback: (range) => range.index % 2 == 1,
),
```

# Thanks
- [savadodesigns](https://github.com/savadodesigns)