import 'package:flutter/material.dart';

import '../../common/theme.dart';
import '../../utils/decimal_picker.dart';
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
  double currentValue = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //_wholeController.dispose();
    //_decimalController.dispose();
    super.dispose();
  }

  void onValueChanged(double value) {
    currentValue = value;
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = AppTheme();
    currentValue = widget.temperature;

    return AlertDialog(
      backgroundColor: theme.background2Color,
      contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      content: SizedBox(
        height: 180,
        child: DecimalPicker.createDecimalPicker(widget.temperature, theme.normalTextColor, theme.focusColor, widget.min, widget.max, onValueChanged, unit:'°'),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(wcLocalizations().cancelAction, style: TextStyle(color: theme.buttonTextColor)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(currentValue);
              },
              child: Text(wcLocalizations().validateAction, style: TextStyle(color: theme.buttonTextColor)),
            ),
          ]
        ),
      ],
    );
  }
}
