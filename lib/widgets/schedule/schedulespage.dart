import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:provider/provider.dart';
import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../../common/theme.dart';
import '../../common/themenotifier.dart';
import '../../utils/localizations.dart';
import 'schedule.dart';

///////////////////////////////////////////////////////////////////////////
//             SCHEDULES PAGE
///////////////////////////////////////////////////////////////////////////
class SchedulesPage extends StatefulWidget {
  const SchedulesPage({super.key});
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
    schedulerData = ModelCtrl().getSchedulerData();
    if (schedulerData!.isEmpty) {
      schedulerData = null;
    }
    ModelCtrl().onSchedulesEvent.subscribe(_onSchedulesEvent);
    ModelCtrl().onDevicesEvent.subscribe(_onDevicesEvent);
    ModelCtrl().onMessageEvent.subscribe(_onMessageEvent);
  }

  void _addScrollListener() {
    _scrollController.addListener(handleScroll);
  }

  @override
  void dispose() {
    ModelCtrl().onSchedulesEvent.unsubscribe(_onSchedulesEvent);
    ModelCtrl().onDevicesEvent.unsubscribe(_onDevicesEvent);
    ModelCtrl().onMessageEvent.unsubscribe(_onMessageEvent);
    _scrollController.dispose();
    super.dispose();
  }

  void _onDevicesEvent(Value<Map<String,Device>> args) {
    setState(() {});
  }

  void _onSchedulesEvent(Value<Map> args) {
    schedulerData = args.value;
    setState(() {});
  }

  void _onNewScheduleValidate(BuildContext context, Map scheduleData, String tapedName, String chosenParent) {
    if (ModelCtrl().getSchedule(tapedName).isNotEmpty) {
      Common.showSnackBar(context, wcLocalizations().errorDuplicateKey(tapedName), backColor: AppTheme().errorColor, durationMs: 4000);
    } else if (ModelCtrl().getDevices().isEmpty || ModelCtrl().getTemperatureSets().isEmpty) {
      Common.showSnackBar(context, wcLocalizations().schedulesPageErrorMissingThermostatAndTempSet, backColor: AppTheme().errorColor, durationMs: 4000);
    } else if (chosenParent!="" && ModelCtrl().getSchedule(chosenParent).isEmpty) {
      Common.showSnackBar(context, wcLocalizations().schedulePageErrorBadParent, backColor: AppTheme().errorColor, durationMs: 4000);
    } else {
      ModelCtrl().createSchedule(tapedName, null, chosenParent); 
    }
  }

  // We need to update the AppBafr to reflect connexion state in connexion icon
  void _onMessageEvent(Value<MessageInfo> args) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // We need this line with listen:true to ensure refresh of this page
    Provider.of<ThemeNotifier>(context, listen: true);
    return Scaffold(
      appBar: Common.createAppBar(wcLocalizations().schedulesPageTitle),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Common.cnxStateButtonFilter(Common.createFloatingButton(
        size: 55,
        icon: Icon(Icons.add, color: AppTheme().buttonTextColor),
        onPressed: () {
          Map scheduleData = {'alias': wcLocalizations().new_};
          Common.editScheduleProperties(context, scheduleData, _onNewScheduleValidate);
        },
      )),
      body: Common.cnxStateWidgetFilter(ReorderableListView.builder(
          padding: Common.getNavbarHeightPadding(),
          // The two following lines are here to avoid "viewport has unbounded height" error
          // and allows the scroll to work in nested listviews
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
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
          })),
    );
  }
}
