import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:navbar_router/navbar_router.dart';

import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../../common/theme.dart';
import '../../utils/localizations.dart';

class DevicesEditorPage extends StatefulWidget {
  const DevicesEditorPage({super.key});
  static const String route = '/devices';

  @override
  State<DevicesEditorPage> createState() => _DevicesEditorPageState();
}

class _DevicesEditorPageState extends State<DevicesEditorPage> {
  final _scrollController = ScrollController();
  Size size = Size.zero;
  Map<String, Device> devices = {};
  List<String> orderedDevices = [];
  Map<String, Entity> entities = {};

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
    devices = ModelCtrl().getDevices();
    orderedDevices = devices.keys.toList();
    ModelCtrl().onDevicesEvent.subscribe(_onDevicesEvent);
    entities = ModelCtrl().getEntities();
    ModelCtrl().onEntitiesEvent.subscribe(_onEntitiesEvent);
    ModelCtrl().onMessageEvent.subscribe(_onMessageEvent);
  }

  void _addScrollListener() {
    _scrollController.addListener(handleScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    ModelCtrl().onDevicesEvent.unsubscribe(_onDevicesEvent);
    ModelCtrl().onEntitiesEvent.unsubscribe(_onEntitiesEvent);
    ModelCtrl().onMessageEvent.unsubscribe(_onMessageEvent);
    super.dispose();
  }

  void _onDevicesEvent(args) {
    devices = ModelCtrl().getDevices();
    orderedDevices = devices.keys.toList();
    setState(() {});
  }

  void _onEntitiesEvent(args) {
    entities = ModelCtrl().getEntities();
    setState(() {});
  }

  // We need to update the AppBafr to reflect connexion state in connexion icon
  void _onMessageEvent(args) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // SizeBox with forced width is needed to avoid Exception
    return Scaffold(
      appBar: Common.createAppBar(wcLocalizations().devicesEditorTitle),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Common.cnxStateButtonFilter(Common.createFloatingButton(
        size: 55,
        icon: Icon(Icons.add, color: AppTheme().buttonTextColor),
        onPressed: () async {
          await editDeviceProperties(
            context,
            wcLocalizations().new_,
            entities.entries.first.value.serverEntity,
            false,
            (deviceName, tapedName, deviceEntity) {
              ModelCtrl().createDevice(tapedName, deviceEntity);
            },
          );
        },
      )),
      body: Common.cnxStateWidgetFilter(SingleChildScrollView(
        child: ReorderableListView.builder(
            // The two following lines are here to avoid "viewport has unbounded height" error
            // and allows the scroll to work in nested listviews
            //physics: const BouncingScrollPhysics(),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: devices.length,
            itemBuilder: (BuildContext context, int index) =>
                deviceTileBuilder(context, devices[orderedDevices[index]]),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                if (oldIndex != newIndex) {
                  String item = orderedDevices.removeAt(oldIndex);
                  orderedDevices.insert(newIndex, item);
                  ModelCtrl().setDevicesOrder(orderedDevices);
                }
              });
            })
      )),
    );
  }

  Widget deviceTileBuilder(BuildContext context, Device? device) {
    String name = '*${wcLocalizations().unknown}*';
    String entity = '*${wcLocalizations().unknown}*';
    if (device != null) {
      name = device.name;
      entity = device.serverEntity;
    }
    Widget leading = Icon(Common.getDeviceIconData(), color: null);
    Widget title = Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Flexible(child: Text(
        name,
        overflow: TextOverflow.fade,
        style: TextStyle(fontSize: Common.getRadioListTextSize(),
        fontWeight: FontWeight.bold, color: null)),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        IconButton(
          icon: Icon(Icons.edit, color: AppTheme().focusColor),
          onPressed: () async {
            await editDeviceProperties(
              context,
              name,
              entity,
              true,
              (deviceName, tapedName, deviceEntity) {
                ModelCtrl().setDeviceEntity(deviceName, deviceEntity);
                ModelCtrl().setDeviceName(deviceName, tapedName);
              },
            );
          },
        ),
        //const SizedBox(width: 20)
      ]),
    ]);

    return StatefulBuilder(
      key: Key(name),
      builder: (BuildContext context, setState) {
        return ListTile(
            textColor: AppTheme().specialTextColor,
            iconColor: AppTheme().specialTextColor,
            leading: leading,
            title: title);
      },
    );
  }

  Future<void> editDeviceProperties(
      BuildContext context, String deviceName, String deviceEntity, bool showDeleteBtn,
      void Function(String deviceName, String tapedName, String deviceEntity) onValidate) async {
    var nameCtrl = TextEditingController(text: deviceName);
    
    await Common.showModalDialog(context,
        dlgButtons: DlgButtons.okCancel,
        title: wcLocalizations().devicesEditorEditTitle,
        insetPadding: const EdgeInsets.all(0),
        onValidate: () => onValidate(deviceName, nameCtrl.text, deviceEntity),
        content: StatefulBuilder(builder: (context, setState) {
          List<DropdownMenuItem<String>> entitiesMenuItems = createDropdownList(deviceEntity);
          List<Widget> columnChildren = [const SizedBox(height: 20,),
              Row(
                children: [
                  Text('${wcLocalizations().devicesEditorEditEntity} : '),
                  const SizedBox(width:20),
                  Flexible(flex:2, child: DropdownButton(
                    isExpanded: true,
                    value: deviceEntity,
                    items: entitiesMenuItems,
                    dropdownColor: AppTheme().background2Color,
                    //focusColor: AppTheme().background2Color,
                    onChanged: (String ?selected) {
                      setState((){
                        deviceEntity = selected ?? deviceEntity;
                      });
                    }
                )),
                ],
              ),
              //const SizedBox(height: 10),
              Row(
                children: [
                  Text('${wcLocalizations().devicesEditorEditName} : '),
                  const SizedBox(width:20),
                  Flexible(flex:2, child: TextFormField(
                  style: TextStyle(color: AppTheme().specialTextColor), 
                  controller: nameCtrl,
                  decoration: InputDecoration(hintText: wcLocalizations().devicesEditorEditName),
                )),
                ],
              ),
            ];
          if (showDeleteBtn==true) {
            columnChildren += [
              const SizedBox(height: 20,),
              Common.createCircleIconButton(Icons.delete, backColor:AppTheme().errorColor, onPressed: () async {
                bool result =
                await Common.showWarningDialog(context, wcLocalizations().removeConfirmation("eqpt", deviceName));
                if (result) {
                  ModelCtrl().deleteDevice(deviceName);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                }
              })];
          }
          return SizedBox(
            width: min(MediaQuery.of(context).size.width, 800),
            child: Column(
            children: columnChildren,
          ));
        }));
  }

  List<DropdownMenuItem<String>> createDropdownList(String currentDeviceEntity) {
    List<DropdownMenuItem<String>> result;
    bool currentEntityIsMissing = true;
    result = entities.values.map(
      (e) {
        Color color = AppTheme().specialTextColor;
        if (e.serverEntity==currentDeviceEntity) {
          currentEntityIsMissing = false;
          color = AppTheme().normalTextColor;
        }
        return DropdownMenuItem(
          value: e.serverEntity,
          child: Text('${e.serverEntity} (${e.name})',
            style:TextStyle(
              fontWeight: FontWeight.normal,
              color: color,
            ),
          ),
        );
      }
    ).toList();

    if (currentEntityIsMissing) {
      // We add the missing entity
      result.add(DropdownMenuItem(
          value: currentDeviceEntity,
          child: Text('$currentDeviceEntity (???)',
            style:TextStyle(
              fontWeight: FontWeight.normal,
              color: AppTheme().warningColor,
            ),
          ),
        ));
    }

    return result;
  }
}
