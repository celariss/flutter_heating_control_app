import 'package:flutter/widgets.dart';

/// A list that shows every item until one is selected, then shows only that
/// item. Tapping the selected item deselects it and restores the full list.
class SelectableList<E, V> extends StatefulWidget {
  const SelectableList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.selectedValue,
    required this.onItemSelected,
    required this.onItemDeselected,
    this.valueSelector,
    this.animationDuration,
  });

  final List<E> items;
  final Widget Function(BuildContext context, E item, bool selected,
      bool expanded, VoidCallback? onTap) itemBuilder;
  final V selectedValue;
  final void Function(E item) onItemSelected;
  final void Function(E item) onItemDeselected;
  final V Function(E item)? valueSelector;
  final Duration? animationDuration;

  @override
  State<SelectableList<E, V>> createState() => _SelectableListState<E, V>();
}

class _SelectableListState<E, V> extends State<SelectableList<E, V>> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late final _ListModel<E> _displayedItems;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    final selectedValue = widget.selectedValue;
    _isExpanded = selectedValue == null;
    final initialItems = selectedValue == null
        ? widget.items
        : widget.items
            .where((item) => _valueSelector(item) == selectedValue)
            .take(1);
    _displayedItems = _ListModel<E>(
      listKey: _listKey,
      items: initialItems,
      animationDuration: widget.animationDuration,
      removedItemBuilder: _buildRemovedItem,
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedList(
        key: _listKey,
        initialItemCount: _displayedItems.length,
        itemBuilder: _buildItem,
        shrinkWrap: true,
      );

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    final item = _displayedItems[index];
    final selected = widget.selectedValue == _valueSelector(item);
    return _AnimatedSelectableItem(
      animation: animation,
      child: widget.itemBuilder(
          context, item, selected, _isExpanded, () => _toggle(item)),
    );
  }

  Widget _buildRemovedItem(
      E item, BuildContext context, Animation<double> animation) {
    final selected = widget.selectedValue == _valueSelector(item);
    return _AnimatedSelectableItem(
      animation: animation,
      child: widget.itemBuilder(context, item, selected, _isExpanded, null),
    );
  }

  void _toggle(E item) {
    final value = _valueSelector(item);
    if (widget.selectedValue != value) {
      _isExpanded = false;
      widget.onItemSelected(item);
      for (final otherItem in widget.items) {
        if (_valueSelector(otherItem) != value &&
            _displayedItems.contains(otherItem)) {
          _displayedItems.remove(otherItem);
        }
      }
      return;
    }

    _isExpanded = true;
    widget.onItemDeselected(item);
    for (var index = 0; index < widget.items.length; index++) {
      final otherItem = widget.items[index];
      if (!_displayedItems.contains(otherItem)) {
        _displayedItems.insert(index, otherItem);
      }
    }
  }

  V _valueSelector(E item) =>
      widget.valueSelector != null ? widget.valueSelector!(item) : item as V;
}

class _AnimatedSelectableItem extends StatelessWidget {
  const _AnimatedSelectableItem({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      SizeTransition(sizeFactor: animation, child: child);
}

class _ListModel<E> {
  _ListModel({
    required this.listKey,
    required Iterable<E> items,
    required this.removedItemBuilder,
    this.animationDuration,
  }) : _items = List<E>.of(items);

  final GlobalKey<AnimatedListState> listKey;
  final Widget Function(
          E item, BuildContext context, Animation<double> animation)
      removedItemBuilder;
  final Duration? animationDuration;
  final List<E> _items;

  static const _defaultDuration = Duration(milliseconds: 200);
  AnimatedListState? get _animatedList => listKey.currentState;
  int get length => _items.length;
  E operator [](int index) => _items[index];
  bool contains(E item) => _items.contains(item);

  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList?.insertItem(index,
        duration: animationDuration ?? _defaultDuration);
  }

  void remove(E item) {
    final index = _items.indexOf(item);
    if (index < 0) return;
    final removedItem = _items.removeAt(index);
    _animatedList?.removeItem(
      index,
      (context, animation) =>
          removedItemBuilder(removedItem, context, animation),
      duration: animationDuration ?? _defaultDuration,
    );
  }
}
