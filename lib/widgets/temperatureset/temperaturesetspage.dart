import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../../common/theme.dart';
import '../../common/themenotifier.dart';
import '../../utils/localizations.dart';
import 'temperaturesets.dart';

///////////////////////////////////////////////////////////////////////////
//             TemperatureSetsPage PAGE
///////////////////////////////////////////////////////////////////////////
class TemperatureSetsPage extends StatefulWidget {
  const TemperatureSetsPage({super.key});
  static const String route = '/';

  @override
  State<TemperatureSetsPage> createState() => _TemperatureSetsPageState();
}

class _TemperatureSetsPageState extends State<TemperatureSetsPage> {
  List<Map> globalTemperatureSetsData = [];




  @override
  void initState() {
    super.initState();
    _onUpdateTempsetsData(ModelCtrl().getSchedulerData());
    ModelCtrl().onSchedulesEvent.subscribe(_onSchedulesEvent);
    ModelCtrl().onDevicesEvent.subscribe(_onDevicesEvent);
    ModelCtrl().onMessageEvent.subscribe(_onMessageEvent);
  }

  @override
  void dispose() {
    ModelCtrl().onSchedulesEvent.unsubscribe(_onSchedulesEvent);
    ModelCtrl().onDevicesEvent.unsubscribe(_onDevicesEvent);
    ModelCtrl().onMessageEvent.unsubscribe(_onMessageEvent);
    super.dispose();
  }

  void _onDevicesEvent(Value<Map<String,Device>> args) {
    setState(() {});
  }

  void _onSchedulesEvent(Value<Map> args) {
    Map schedulerData = args.value;
    _onUpdateTempsetsData(schedulerData);
    setState(() {});
  }

  void _onUpdateTempsetsData(Map schedulerData) {
    globalTemperatureSetsData = [];
    if (schedulerData.containsKey('temperature_sets')) {
      globalTemperatureSetsData = List<Map>.from(schedulerData['temperature_sets'] as List);
    }
  }

  // We need to update the AppBar to reflect connexion state in connexion icon
  void _onMessageEvent(Value<MessageInfo> args) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // We need this line with listen:true to ensure refresh of this page when theme is changed
    Provider.of<ThemeNotifier>(context, listen: true);
    return Scaffold(
      appBar: Common.createAppBar(wcLocalizations().tempSetsPageTitle),
      body: Common.cnxStateWidgetFilter(TemperatureSets(temperatureSetsData: globalTemperatureSetsData, scheduleName: '')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Common.cnxStateButtonFilter(Common.createFloatingButton(
        size: 55,
        iconData: Icons.add,
        onPressed: () {
          Map tempSetData = {'alias': wcLocalizations().new_};
          Common.editTemperatureSetProperties(context, tempSetData, '', _onNewTemperatureSetValidate);
        },
      )),
    );
  }

  static void _onNewTemperatureSetValidate(Map data, String scheduleName, Color pickedColor, String tapedName) {
    ModelCtrl().createTemperatureSet(pickedColor, tapedName, scheduleName: scheduleName);
  }
}