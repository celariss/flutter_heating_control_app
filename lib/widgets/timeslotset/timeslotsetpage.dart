import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:navbar_router/navbar_router.dart';

import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import 'timeslot_set_editor.dart';

///////////////////////////////////////////////////////////////////////////
//             TIMESLOTSET PAGE
///////////////////////////////////////////////////////////////////////////
class TimeSlotSetPage extends StatefulWidget {
  const TimeSlotSetPage({Key? key}) : super(key: key);
  static const String route = '/timeslotset';

  @override
  State<TimeSlotSetPage> createState() => _TimeSlotSetPage();
}

class _TimeSlotSetPage extends State<TimeSlotSetPage> {
  List<Map> globalTemperatureSetsData = [];

  final _scrollController = ScrollController();
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
    //ModelCtrl().onDevicesEvent.subscribe(_onDevicesEvent);
  }

  @override
  void dispose() {
    ModelCtrl().onSchedulesEvent.unsubscribe(_onSchedulesEvent);
    //ModelCtrl().onDevicesEvent.unsubscribe(_onDevicesEvent);
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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final String scheduleName = args['scheduleName'];
    final int scheduleItemIdx = args['scheduleItemIdx'];
    final int timeslotSetIdx = args['timeslotSetIdx'];
    //Map timeslotSetData = args['timeslotSetData'];

    return Scaffold(
      appBar: AppBar(title: const Text("Edition d'une Plage hebdomadaire"), actions: [
        Common.createCircleIcon(
            size: 32,
            icon: Icon(ModelCtrl().isConnectedToServer() ? Icons.link : Icons.link_off, color: Colors.white),
            backColor: ModelCtrl().isConnectedToServer() ? Colors.green.shade700 : Colors.red.shade800),
      ]),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: TimeSlotSetEditor(
            scheduleName: scheduleName, scheduleItemIdx: scheduleItemIdx, timeslotSetIdx: timeslotSetIdx),
      ),
    );
  }
}
