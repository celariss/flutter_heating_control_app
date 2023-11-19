import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:navbar_router/navbar_router.dart';

import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../../common/theme.dart';
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
  final _scrollController = ScrollController();
  List<Map> globalTemperatureSetsData = [];
  Size size = Size.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = MediaQuery.of(context).size;
    if (size.width < 600) {
      _addScrollListener();
    }
  }

  void handleScroll() {
    if (size.width > 600) return;
    if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (NavbarNotifier.isNavbarHidden) {
        NavbarNotifier.hideBottomNavBar = false;
      }
    } else {
      if (!NavbarNotifier.isNavbarHidden) {
        NavbarNotifier.hideBottomNavBar = true;
      }
    }
  }

  void _addScrollListener() {
    _scrollController.addListener(handleScroll);
  }

  @override
  void initState() {
    super.initState();
    ModelCtrl().onSchedulesEvent.subscribe(_onSchedulesEvent);
    ModelCtrl().onDevicesEvent.subscribe(_onDevicesEvent);
    ModelCtrl().onMessageEvent.subscribe(_onMessageEvent);
  }

  @override
  void dispose() {
    ModelCtrl().onSchedulesEvent.unsubscribe(_onSchedulesEvent);
    ModelCtrl().onDevicesEvent.unsubscribe(_onDevicesEvent);
    ModelCtrl().onMessageEvent.unsubscribe(_onMessageEvent);
    _scrollController.dispose();
    super.dispose();
  }

  void _onDevicesEvent(args) {
    setState(() {});
  }

  void _onSchedulesEvent(args) {
    Map schedulerData = args!.value;
    globalTemperatureSetsData = [];
    if (schedulerData.containsKey('temperature_sets')) {
      globalTemperatureSetsData = List<Map>.from(schedulerData['temperature_sets'] as List);
    }
    setState(() {});
  }

  // We need to update the AppBafr to reflect connexion state in connexion icon
  void _onMessageEvent(args) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Common.createAppBar('Jeux de T°'),
      body: TemperatureSets(temperatureSetsData: globalTemperatureSetsData, scheduleName: ''),
      key: UniqueKey(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Common.createFloatingButton(
        size: 55,
        icon: Icon(Icons.add, color: AppTheme().buttonTextColor),
        onPressed: () {
          Map tempSetData = {'alias': 'New'};
          Common.editTemperatureSetProperties(context, tempSetData, '', _onNewTemperatureSetValidate);
        },
      ),
    );
  }

  static _onNewTemperatureSetValidate(Map data, String scheduleName, Color pickedColor, String tapedName) {
    ModelCtrl().createTemperatureSet(pickedColor.value, tapedName, scheduleName: scheduleName);
  }
}
