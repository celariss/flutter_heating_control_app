import 'package:flutter/material.dart';

import '../../common/theme.dart';
import '../../utils/localizations.dart';

/// A native Flutter dialog for choosing a temperature in tenths of a degree.
class TemperaturePicker {
  static Future<double> show(
    BuildContext context, {
    required double temperature,
    required int min,
    required int max,
  }) async {
    final double? pickedTemperature = await showDialog<double>(
      context: context,
      builder: (context) => _TemperaturePickerDialog(
        temperature: temperature,
        min: min,
        max: max,
      ),
    );

    // Preserve the previous behavior: dismissing the dialog keeps the value.
    return pickedTemperature ?? temperature;
  }
}

class _TemperaturePickerDialog extends StatefulWidget {
  const _TemperaturePickerDialog({
    required this.temperature,
    required this.min,
    required this.max,
  });

  final double temperature;
  final int min;
  final int max;

  @override
  State<_TemperaturePickerDialog> createState() => _TemperaturePickerDialogState();
}

class _TemperaturePickerDialogState extends State<_TemperaturePickerDialog> {
  late final List<int> _wholeValues;
  late final FixedExtentScrollController _wholeController;
  late final FixedExtentScrollController _decimalController;
  late int _wholeValue;
  late int _decimalValue;

  @override
  void initState() {
    super.initState();
    final double clampedTemperature =
        widget.temperature.clamp(widget.min.toDouble(), widget.max.toDouble()).toDouble();
    _wholeValue = clampedTemperature.floor();
    _decimalValue = (clampedTemperature * 10).floor() % 10;
    _wholeValues = List<int>.generate(widget.max - widget.min + 1, (index) => widget.min + index);
    _wholeController = FixedExtentScrollController(initialItem: _wholeValue - widget.min);
    _decimalController = FixedExtentScrollController(initialItem: _decimalValue);
  }

  @override
  void dispose() {
    _wholeController.dispose();
    _decimalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = AppTheme();
    final TextStyle itemStyle = TextStyle(color: theme.specialTextColor, fontSize: 18);
    final TextStyle selectedItemStyle = TextStyle(color: theme.normalTextColor, fontSize: 22);

    return AlertDialog(
      backgroundColor: theme.background2Color,
      contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      content: SizedBox(
        height: 180,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('-', style: selectedItemStyle),
            Expanded(
              child: _buildWheel(
                controller: _wholeController,
                selectedItem: _wholeValue - widget.min,
                itemCount: _wholeValues.length,
                itemBuilder: (index) => _wholeValues[index].toString(),
                itemStyle: itemStyle,
                selectedItemStyle: selectedItemStyle,
                onSelectedItemChanged: (index) => setState(() => _wholeValue = _wholeValues[index]),
              ),
            ),
            Text('-', style: selectedItemStyle),
            Expanded(
              child: _buildWheel(
                controller: _decimalController,
                selectedItem: _decimalValue,
                itemCount: 10,
                itemBuilder: (index) => index.toString(),
                itemStyle: itemStyle,
                selectedItemStyle: selectedItemStyle,
                onSelectedItemChanged: (index) => setState(() => _decimalValue = index),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text('-', style: selectedItemStyle),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(wcLocalizations().cancelAction, style: TextStyle(color: theme.buttonTextColor)),
        ),
        TextButton(
          onPressed: () {
            final double value = _wholeValue + _decimalValue / 10;
            Navigator.of(context).pop(value > widget.max ? widget.max.toDouble() : value);
          },
          child: Text(wcLocalizations().validateAction, style: TextStyle(color: theme.buttonTextColor)),
        ),
      ],
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int selectedItem,
    required int itemCount,
    required String Function(int index) itemBuilder,
    required TextStyle itemStyle,
    required TextStyle selectedItemStyle,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 40,
      diameterRatio: 1.6,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          if (index < 0 || index >= itemCount) return null;
          final bool selected = index == selectedItem;
          return Center(
            child: Text(itemBuilder(index), style: selected ? selectedItemStyle : itemStyle),
          );
        },
      ),
    );
  }
}
