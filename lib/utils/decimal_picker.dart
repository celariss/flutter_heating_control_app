import 'package:flutter/material.dart';

class DecimalPicker {
  
  static Widget createDecimalPicker(double initialValue, Color itemColor, Color selectedItemColor, int min, int max, void Function(double) onChanged) {
    final TextStyle itemStyle = TextStyle(color: itemColor, fontSize: 18);
    final TextStyle selectedItemStyle = TextStyle(color: selectedItemColor, fontSize: 22, fontWeight: FontWeight.bold);
    final List<int> wholeValues = List<int>.generate(max - min + 1, (index) => min + index);
    
    final double clampedTemperature = initialValue.clamp(min.toDouble(), max.toDouble()).toDouble();
    int wholeValue = clampedTemperature.floor();
    final FixedExtentScrollController wholeController = FixedExtentScrollController(initialItem: wholeValue - min);
    int decimalValue = (clampedTemperature * 10).floor() % 10;
    final FixedExtentScrollController decimalController = FixedExtentScrollController(initialItem: decimalValue);

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter localSetState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('-', style: selectedItemStyle),
            Expanded(
              child: DecimalPicker._buildWheel(
                controller: wholeController,
                selectedItem: wholeValue - min,
                itemCount: wholeValues.length,
                itemBuilder: (index) => wholeValues[index].toString(),
                itemStyle: itemStyle,
                selectedItemStyle: selectedItemStyle,
                onSelectedItemChanged: (index) => {
                  localSetState(() => wholeValue = wholeValues[index]),
                  onChanged(wholeValue + decimalValue / 10)
                },
              ),
            ),
            Text('-', style: selectedItemStyle),
            Expanded(
              child: DecimalPicker._buildWheel(
                controller: decimalController,
                selectedItem: decimalValue,
                itemCount: 10,
                itemBuilder: (index) => index.toString(),
                itemStyle: itemStyle,
                selectedItemStyle: selectedItemStyle,
                onSelectedItemChanged: (index) => {
                  localSetState(() => decimalValue = index),
                  onChanged(wholeValue + decimalValue / 10)
                }
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text('-', style: selectedItemStyle),
            ),
          ],
        );
      }
    );
  }

  static Widget _buildWheel({
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