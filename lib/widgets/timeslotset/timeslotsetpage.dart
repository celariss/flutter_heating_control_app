import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:navbar_router/navbar_router.dart';

import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../../utils/localizations.dart';
import 'timeslot_set_editor.dart';

///////////////////////////////////////////////////////////////////////////
//             TIMESLOTSET PAGE
///////////////////////////////////////////////////////////////////////////
class TimeSlotSetPage extends StatefulWidget {
  const TimeSlotSetPage({super.key});
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
    ModelCtrl().onMessageEvent.subscribe(_onMessageEvent);
  }

  @override
  void dispose() {
    ModelCtrl().onSchedulesEvent.unsubscribe(_onSchedulesEvent);
    //ModelCtrl().onDevicesEvent.unsubscribe(_onDevicesEvent);
    ModelCtrl().onMessageEvent.unsubscribe(_onMessageEvent);
    _scrollController.dispose();
    super.dispose();
  }

  /*void _onDevicesEvent(args) {
    setState(() {});
  }*/

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
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final String scheduleName = args['scheduleName'];
    final int scheduleItemIdx = args['scheduleItemIdx'];
    final int timeslotSetIdx = args['timeslotSetIdx'];
    final String tsKey = args['tsKey'];
    //Map timeslotSetData = args['timeslotSetData'];

    return Scaffold(
      appBar: Common.createAppBar(wcLocalizations().timeslotSetEditTitle),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: TimeSlotSetEditor(
            scheduleName: scheduleName, scheduleItemIdx: scheduleItemIdx, tsKey: tsKey, timeslotSetIdx: timeslotSetIdx),
      ),
    );
  }
}
