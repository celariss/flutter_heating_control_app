import 'package:flutter/material.dart';
import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import 'temperatureset.dart';

class TemperatureSets extends StatefulWidget {
  final List<Map> temperatureSetsData;
  final String scheduleName;

  const TemperatureSets({super.key, required this.temperatureSetsData, required this.scheduleName});

  @override
  State<TemperatureSets> createState() => _TemperatureSetsState();
}

class _TemperatureSetsState extends State<TemperatureSets> {
  _TemperatureSetsState();

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
        // Padding to avoid content being hidden by navbar
        padding: Common.getNavbarHeightPadding(),
        itemCount: widget.temperatureSetsData.length,
        itemBuilder: (BuildContext context, int index) =>
            TemperatureSet.temperatureSetTileBuilder(context, widget.temperatureSetsData[index], widget.scheduleName),
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            if (oldIndex != newIndex) {
              final Map item = widget.temperatureSetsData.removeAt(oldIndex);
              widget.temperatureSetsData.insert(newIndex, item);
              ModelCtrl().swapTemperatureSets(oldIndex, newIndex);
            }
          });
        });
  }
}
