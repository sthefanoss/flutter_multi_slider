part of flutter_multi_slider;

class _CustomGestureDetector extends StatelessWidget {
  final ValueChanged<Offset>? onPanStart;
  final ValueChanged<Offset>? onPanUpdate;
  final ValueChanged<Offset>? onPanEnd;
  final Widget child;

  const _CustomGestureDetector({
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ValueChanged<Offset> globalToLocalWrapper(ValueChanged<Offset>? callback) =>
        (Offset globalOffset) {
          final renderBox = context.findRenderObject()! as RenderBox;
          callback?.call(renderBox.globalToLocal(globalOffset));
        };

    return RawGestureDetector(
      gestures: {
        _CustomPanGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<_CustomPanGestureRecognizer>(
          () => _CustomPanGestureRecognizer(
            onPanStart: globalToLocalWrapper(onPanStart),
            onPanUpdate: globalToLocalWrapper(onPanUpdate),
            onPanEnd: globalToLocalWrapper(onPanEnd),
          ),
          (_CustomPanGestureRecognizer instance) {},
        ),
      },
      child: child,
    );
  }
}

class _CustomPanGestureRecognizer extends OneSequenceGestureRecognizer {
  final ValueChanged<Offset> onPanStart;
  final ValueChanged<Offset> onPanUpdate;
  final ValueChanged<Offset> onPanEnd;

  _CustomPanGestureRecognizer({
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  @override
  void addPointer(PointerEvent event) {
    startTrackingPointer(event.pointer);
    resolve(GestureDisposition.accepted);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerDownEvent) {
      onPanStart.call(event.position);
    }
    if (event is PointerMoveEvent) {
      onPanUpdate.call(event.position);
    }
    if (event is PointerUpEvent) {
      onPanEnd.call(event.position);
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  String get debugDescription => 'CustomPanGestureRecognizer';
}
