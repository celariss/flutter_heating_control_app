import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:provider/provider.dart';
import 'package:selectable_list/selectable_list.dart';

import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../../common/theme.dart';
import '../../common/themenotifier.dart';
import 'deviceseditor.dart';
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
    schedulesList = getScheduleNames();
    selectedScheduleName = getActiveSchedule();
    internalSelectedScheduleName = selectedScheduleName;
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
    if (args != null) {
      schedulerData = args!.value as Map;
      schedulesList = getScheduleNames();
      selectedScheduleName = getActiveSchedule();
      internalSelectedScheduleName = selectedScheduleName;
      setState(() {});
    }
  }

  String selectedScheduleName = '';
  String? internalSelectedScheduleName;
  List<String> schedulesList = [];
  final String noPlanningStr = 'Aucun planning actif';

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
      return schedulerData!['active_schedule'];
    }
    return noPlanningStr;
  }

  @override
  Widget build(BuildContext context) {
    // We need this line witrh listen:true to ensure refresh of this page
    Provider.of<ThemeNotifier>(context, listen: true);
    return Scaffold(
      appBar: AppBar(title: const Text('Général'), actions: [
        Common.createCircleIconButton(
            Icons.settings,
            //iconSize: 50,
            iconColor: AppTheme().normalTextColor,
            backColor: AppTheme().background3Color,
            onPressed: () {
              NavbarNotifier.hideBottomNavBar = false;
              Common.navBarNavigate(context, SettingsPage.route, isRootNavigator: false);
            },),
        Common.createCircleIcon(
            size: 32,
            icon: Icon(ModelCtrl().isConnectedToServer() ? Icons.link : Icons.link_off, color: Colors.white),
            backColor: ModelCtrl().isConnectedToServer() ? Colors.green.shade700 : Colors.red.shade800),
      ]),
      body: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(height: 10),
          Text(
            'Planning actif',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppTheme().specialTextColor,
            ),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(10, 7, 10, 15),
              child: SelectableList<String, String?>(
                key: UniqueKey(),
                items: schedulesList,
                itemBuilder: (context, schedule, selected, onTap) => Column(children: [
                  ListTile(
                      visualDensity: VisualDensity.compact,
                      tileColor: AppTheme().background2Color,
                      selectedTileColor: AppTheme().background2Color,
                      /*trailing: internalSelectedScheduleName!=null ? Common.createCircleIconButton(Icons.remove_red_eye_outlined, onPressed: () {
                      },) : null,*/
                      title: (schedule == selectedScheduleName)
                          ? Text(schedule,
                              style:
                                  TextStyle(fontWeight: FontWeight.bold, color: AppTheme().normalTextColor, fontSize: 16))
                          : Text(schedule, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
                      shape: (schedule == selectedScheduleName)
                          ? RoundedRectangleBorder(
                              side: BorderSide(color: AppTheme().focusColor, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            )
                          : RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                      selected: selected,
                      onTap: onTap),
                  const SizedBox(height: 10),
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
              )),
          Wrap(
            spacing: 10.0,
            runSpacing: 0.0,
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [Container(), Common.createCircleIconButton(Icons.edit_note, iconSize: 50, onPressed: () {
              DevicesEditorWidget.editDevices(context);
            })]
          ),
          const SizedBox(height: 15),
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
          const SizedBox(height: 55)
        ]),
      ),
    );
  }
}
