import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:provider/provider.dart';
import 'package:selectable_list/selectable_list.dart';

import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../../common/theme.dart';
import '../../common/themenotifier.dart';
import '../../utils/localizations.dart';
import 'deviceseditorpage.dart';
import 'settingspage.dart';
import 'thermostat.dart';

///////////////////////////////////////////////////////////////////////////
//             HOME PAGE
///////////////////////////////////////////////////////////////////////////
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String route = '/';

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
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
    updateSchedulesList();
    ModelCtrl().onSchedulesEvent.subscribe(_onSchedulesEvent);
    ModelCtrl().onDevicesEvent.subscribe(_onDevicesEvent);
    ModelCtrl().onMessageEvent.subscribe(_onMessageEvent);
  }

  void updateSchedulesList() {
    noPlanningStr = wcLocalizations().homePageNoActiveSchedule;
    schedulesList = getScheduleNames();
    selectedScheduleName = getActiveSchedule();
    internalSelectedScheduleName = selectedScheduleName;
  }

  // @override
  // void didUpdateWidget(covariant HomePage oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  // }

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

  void _onDevicesEvent(args) {
    setState(() {});
  }

  void _onSchedulesEvent(args) {
    if (args != null) {
      schedulerData = args!.value as Map;
      updateSchedulesList();
      setState(() {});
    }
  }

  // We need to update the AppBar to reflect connexion state in connexion icon
  void _onMessageEvent(args) {
    setState(() {});
  }

  String selectedScheduleName = '';
  String? internalSelectedScheduleName;
  List<String> schedulesList = [];
  String noPlanningStr = '';

  List<String> getScheduleNames() {
    List<String> result = [noPlanningStr];
    if (schedulerData != null) {
      result.addAll((schedulerData!['schedules'] as List).map((schedule) => schedule['alias'] as String).toList());
    }
    return result;
  }

  void setActiveSchedule(String scheduleName) {
    if (scheduleName == noPlanningStr || !schedulesList.contains(scheduleName)) {
      ModelCtrl().setActiveSchedule('');
    } else {
      ModelCtrl().setActiveSchedule(scheduleName);
    }
  }

  String getActiveSchedule() {
    if (schedulerData != null && schedulerData!['active_schedule'] != null) {
      String res = schedulerData!['active_schedule'];
      if (res!='') {
        return res;
      }
    }
    return noPlanningStr;
  }

  @override
  Widget build(BuildContext context) {
    // We need this line with listen:true to ensure refresh of this page
    Provider.of<ThemeNotifier>(context, listen: true);
    return Scaffold(
      appBar: Common.createAppBar(wcLocalizations().homePageTitle, actions:[
        Common.createCircleIconButton(
            Icons.settings,
            //iconSize: 50,
            iconColor: AppTheme().normalTextColor,
            backColor: AppTheme().background3Color,
            onPressed: () {
              NavbarNotifier.hideBottomNavBar = false;
              Common.navBarNavigate(context, SettingsPage.route, isRootNavigator: false);
            },)
      ]),
      body: Common.cnxStateWidgetFilter(SingleChildScrollView(
        padding: Common.getNavbarHeightPadding(),
        child: Column(children: [
          const SizedBox(height: 10),
          Text(
            wcLocalizations().homePageActiveSchedule,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppTheme().specialTextColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 7, 10, 15),
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme().background2Color,
                  backgroundBlendMode: BlendMode.difference,
                  border: Border.all(),
                  borderRadius: const BorderRadius.all(Radius.circular(8.0))),
                child:SelectableList<String, String?>(
                  key: UniqueKey(),
                  items: schedulesList,
                  itemBuilder: (context, schedule, selected, onTap) => Column(children: [
                    ListTile(
                        visualDensity: VisualDensity.compact,
                        title: (schedule == selectedScheduleName)
                            ? Text(schedule,
                                style:
                                    TextStyle(fontWeight: FontWeight.bold, color: AppTheme().normalTextColor, fontSize: 16))
                            : Text(schedule, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
                        shape: (schedule == selectedScheduleName)
                            ? RoundedRectangleBorder(
                                side: BorderSide(color: AppTheme().focusColor, width: 3),
                                borderRadius: BorderRadius.circular(8),
                              )
                            : null,
                        selected: selected,
                        onTap: onTap),
                  ]),
                  valueSelector: (schedule) => schedule,
                  selectedValue: internalSelectedScheduleName,
                  onItemSelected: (schedule) {
                    setState(() {
                      selectedScheduleName = schedule;
                      internalSelectedScheduleName = schedule;
                      setActiveSchedule(schedule);
                    });
                  },
                  onItemDeselected: (schedule) {
                    internalSelectedScheduleName = null;
                    setState(() {});
                  },
              )))
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 20.0,
            runSpacing: 0.0,
            alignment: WrapAlignment.center,
            children: ModelCtrl()
                .getDevices()
                .values
                .map((device) => Thermostat.heaterWidgetBuilder(
                      device,
                      (deviceName, setpoint) {
                        setState(() => ModelCtrl().setDeviceSetpoint(deviceName, setpoint));
                      },
                    ))
                .toList(),
          ),
        ]),
      )),
    );
  }
}
