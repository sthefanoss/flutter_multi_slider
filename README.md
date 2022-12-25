# MultiSlider

A custom Slider which accepts a list of ordered values. It's meant to be as simple as the original Slider!

# UI with it

<img src="https://raw.githubusercontent.com/sthefanoss/flutter_multi_slider/main/giphy.gif" width="250">

# Features
1. Customize the apperance of the slider with `horizontalPadding`, `color`, `height` and `displayDivisions`.
2. Define maximum and minimum values.
3. Add custom callbacks with `onChanged`, `onChangeStart`, `onChangeEnd`.
4. Add or remove pairs of boundaries on double tap.
5. Add a custom tooltip that will be displayed above the slider.
6. Define the difference between division with discrete slider. 

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
),
```
## Add or remove on double tap
```dart
MultiSlider(
    values: _myList,
    onChanged: (values) => setState(()=> _myList = values),
    addOrRemove: true,
    defaultRange: 0.1,
),
```
<img src="https://github.com/Adam-Mazur/flutter_multi_slider/blob/new_branch/doubleTap.gif" width="250">

## Add a tooltip

```dart
MultiSlider(
    values: _myList,
    onChanged: (values) => setState(()=> _myList = values),
    showTooltip: true,
    tooltipBuilder: (value) => value.toStringAsFixed(2),
),
```

<img src="https://github.com/Adam-Mazur/flutter_multi_slider/blob/new_branch/tooltip.gif" width="250">
