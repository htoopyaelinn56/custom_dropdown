import 'package:custom_dropdown/src/anchored_overlay.dart';
import 'package:flutter/material.dart';

class CustomDropDown<T> extends StatefulWidget {
  const CustomDropDown({
    super.key,
    required this.itemList,
    this.hintText = 'Hint Text',
    this.initialValue,
    this.dropdownItemBuilder,
    this.onChanged,
    this.width = 250,
    this.height = 50,
    this.decoration,
  });
  final List<T> itemList;
  final String hintText;
  final Widget? initialValue;
  final Widget Function(T)? dropdownItemBuilder;
  final Function(T)? onChanged;
  final double width;
  final double height;
  final BoxDecoration? decoration;
  @override
  State<CustomDropDown<T>> createState() => _CustomDropDownState<T>();
}

class _CustomDropDownState<T> extends State<CustomDropDown<T>> with SingleTickerProviderStateMixin {
  Widget? _currentItem;

  @override
  void initState() {
    super.initState();
    _currentItem = Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          if (widget.initialValue == null)
            _currentItem == null
                ? Text(
                    widget.hintText,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  )
                : _currentItem!
          else
            widget.initialValue!,
        ],
      ),
    );
  }

  final LayerLink _layerLink = LayerLink();
  late final _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  late final _curveAnimation = CurvedAnimation(
    parent: _animation,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    super.dispose();
    _animation.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnchoredOverlay(
      showOverlay: true,
      overlayBuilder: (context, offset) {
        return CenterAbout(
          position: Offset(offset.dx, offset.dy),
          child: CompositedTransformFollower(
            offset: const Offset(0, 55),
            link: _layerLink,
            showWhenUnlinked: false,
            child: Material(
              elevation: 3,
              color: Colors.white,
              child: SizeTransition(
                axis: Axis.vertical,
                sizeFactor: _curveAnimation,
                child: SizedBox(
                  height: widget.itemList.length <= 3 ? widget.itemList.length * 50 : 250,
                  width: _layerLink.leaderSize!.width,
                  child: ListView(
                    children: [
                      for (int i = 0; i < widget.itemList.length; i++)
                        SizedBox(
                          width: widget.width,
                          height: widget.height,
                          child: Material(
                            color: Colors.white,
                            child: InkWell(
                              onTap: () {
                                _animation.reverse();
                                _currentItem = Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      widget.dropdownItemBuilder?.call(widget.itemList[i]) ?? const SizedBox.shrink(),
                                    ],
                                  ),
                                );
                                widget.onChanged?.call(widget.itemList[i]);
                                setState(() {});
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: widget.dropdownItemBuilder?.call(widget.itemList[i]),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Material(
          color: Colors.white,
          child: Container(
            decoration: widget.decoration ??
                BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
            width: widget.width,
            height: widget.height,
            child: InkWell(
              onTap: () {
                if (_animation.isDismissed) {
                  _animation.forward();
                } else {
                  _animation.reverse();
                }
              },
              child: _currentItem,
            ),
          ),
        ),
      ),
    );
  }
}
