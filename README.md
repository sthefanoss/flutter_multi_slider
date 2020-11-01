# MultiSlider

Yet another Slider Widget. But here you can use a `List<double>` as input!!!

You **can** use Themes.

# UI with it

<img src="sc.png" width="250">

# Usage
Just a tiny example:
```dart
MultiSlider(
    values: _myList,
    onChanged: (values) => setState(
        ()=> _myList = values,
    ),
    min: -1,
    max: 1,
)
```

