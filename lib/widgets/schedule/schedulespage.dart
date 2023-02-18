import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:navbar_router/navbar_router.dart';
import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../../common/theme.dart';
import 'schedule.dart';

///////////////////////////////////////////////////////////////////////////
//             SCHEDULES PAGE
///////////////////////////////////////////////////////////////////////////
class SchedulesPage extends StatefulWidget {
  const SchedulesPage({Key? key}) : super(key: key);
  static const String route = '/';

  @override
  State<SchedulesPage> createState() => _SchedulesPage();
}

class _SchedulesPage extends State<SchedulesPage> {
  final _scrollController = ScrollController();
  Map? schedulerData;
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

  @override
  void initState() {
    super.initState();
    ModelCtrl().onSchedulesEvent.subscribe(_onSchedulesEvent);
    ModelCtrl().onDevicesEvent.subscribe(_onDevicesEvent);
  }

  void _addScrollListener() {
    _scrollController.addListener(handleScroll);
  }

  @override
  void dispose() {
    ModelCtrl().onSchedulesEvent.unsubscribe(_onSchedulesEvent);
    ModelCtrl().onDevicesEvent.unsubscribe(_onDevicesEvent);
    _scrollController.dispose();
    super.dispose();
  }

  void _onDevicesEvent(args) {
    setState(() {});
  }

  void _onSchedulesEvent(args) {
    schedulerData = args!.value;
    setState(() {});
  }

  void _onNewScheduleValidate(BuildContext context, Map scheduleData, String tapedName) {
    if (ModelCtrl().getSchedule(tapedName).isEmpty) {
      ModelCtrl().createSchedule(tapedName);
    } else {
      Common.showSnackBar(context, 'Ce planning existe déjà ...', backColor: AppTheme().errorColor, duration_ms: 4000);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plannings'), actions: [
        Common.createCircleIcon(
            size: 32,
            icon: Icon(ModelCtrl().isConnectedToServer() ? Icons.link : Icons.link_off, color: Colors.white),
            backColor: ModelCtrl().isConnectedToServer() ? Colors.green.shade700 : Colors.red.shade800),
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Common.createFloatingButton(
        size: 55,
        icon: Icon(Icons.add, color: AppTheme().buttonTextColor),
        onPressed: () {
          Map scheduleData = {'alias': 'New'};
          Common.editScheduleProperties(context, scheduleData, _onNewScheduleValidate);
        },
      ),
      body: ReorderableListView.builder(
          // The two following lines are here to avoid "viewport has unbounded height" error
          // and allows the scroll to work in nested listviews
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          // Padding to avoid content being hidden by navbar
          padding: const EdgeInsets.only(bottom: 55),
          itemCount: schedulerData != null ? schedulerData!['schedules'].length : 0,
          itemBuilder: (context, index) {
            return Schedule.scheduleTileBuilder(context, schedulerData!['schedules'][index]);
          },
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            if (oldIndex != newIndex) {
              ModelCtrl().swapSchedules(oldIndex, newIndex);
            }
          }),
    );
  }
}
