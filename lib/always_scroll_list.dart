library always_scroll_list;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AlwaysScrollList extends StatefulWidget {
  final List<dynamic> items;
  final Widget Function(BuildContext, int, dynamic) itemBuilder;
  final Axis direction;
  final Duration? holdDuration;
  final bool enabled;

  const AlwaysScrollList.vertical({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.enabled = true,
    this.holdDuration,
  })  : direction = Axis.vertical,
        super(key: key);

  const AlwaysScrollList.horizontal({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.enabled = true,
    this.holdDuration,
  })  : direction = Axis.horizontal,
        super(key: key);

  @override
  State<AlwaysScrollList> createState() => _AlwaysScrollListState();
}

class _AlwaysScrollListState extends State<AlwaysScrollList> {
  ScrollController? _scrollController;
  var _items = [];
  Timer? _scrollTimer, _stopScrollTimer;
  bool _stopScroll = false;
  ScrollDirection? _oldScrollDirection;
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      final _holdDuration =
          widget.holdDuration ?? const Duration(milliseconds: 3000);
      _items = [...widget.items, ...widget.items];
      _scrollController = ScrollController();
      _scrollTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        if (!_stopScroll) {
          _scrollPosition++;
          _scrollController?.animateTo(
            _scrollPosition,
            duration: const Duration(milliseconds: 100),
            curve: Curves.ease,
          );
        } else {
          _scrollPosition = _scrollController?.position.pixels ?? 0.0;
        }
      });

      _scrollController?.addListener(() {
        _oldScrollDirection ??= _scrollController?.position.userScrollDirection;

        if (_oldScrollDirection !=
            _scrollController?.position.userScrollDirection) {
          _stopScroll = true;
          _oldScrollDirection = _scrollController?.position.userScrollDirection;
        }

        if (_stopScroll) {
          Future.delayed(_holdDuration, () => _stopScroll = false);
        }

        if ((_scrollController?.position.pixels ?? 0.0) >=
            (_scrollController?.position.maxScrollExtent ?? 0.0) - 10) {
          setState(() {
            _items = [..._items, ..._items];
          });
        }
      });
    } else {
      _items = widget.items;
    }
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _stopScrollTimer?.cancel();
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: widget.direction,
      controller: _scrollController,
      itemCount: _items.length,
      itemBuilder: (context, index) => widget.itemBuilder(
        context,
        index,
        _items[index],
      ),
    );
  }
}
