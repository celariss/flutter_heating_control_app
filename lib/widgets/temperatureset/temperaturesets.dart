import 'package:flutter/material.dart';
import '../../common/model_ctrl.dart';
import 'temperatureset.dart';

class TemperatureSets extends StatefulWidget {
  List<Map> temperatureSetsData;
  String scheduleName;

  TemperatureSets({super.key, required this.temperatureSetsData, required this.scheduleName});

  @override
  State<TemperatureSets> createState() => _TemperatureSetsState(temperatureSetsData, scheduleName);
}

class _TemperatureSetsState extends State<TemperatureSets> {
  final List<Map> _data;
  String scheduleName;

  _TemperatureSetsState(this._data, this.scheduleName);

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
        // Padding to avoid content being hidden by navbar
        padding: const EdgeInsets.only(bottom: 55),
        itemCount: _data.length,
        itemBuilder: (BuildContext context, int index) =>
            TemperatureSet.temperatureSetTileBuilder(context, _data[index], scheduleName),
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            if (oldIndex != newIndex) {
              final Map item = _data.removeAt(oldIndex);
              _data.insert(newIndex, item);
              ModelCtrl().swapTemperatureSets(oldIndex, newIndex);
            }
          });
        });
  }
}
