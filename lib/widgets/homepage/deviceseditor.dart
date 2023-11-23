import 'dart:math';

import 'package:flutter/material.dart';

import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../../common/theme.dart';

class DevicesEditorWidget extends StatefulWidget {
  const DevicesEditorWidget({super.key});

  @override
  State<DevicesEditorWidget> createState() => _DevicesEditorWidgetState();

  static Future<void> editDevices(BuildContext context) async {
    await Common.showModalDialog(context, dlgButtons: DlgButtons.close, title: "Edition de la liste des équipements",
        onValidate: () {
      //
    }, content: const DevicesEditorWidget());
  }
}

class _DevicesEditorWidgetState extends State<DevicesEditorWidget> {
  Map<String, Device> devices = {};
  List<String> orderedDevices = [];

  @override
  void initState() {
    super.initState();
    devices = ModelCtrl().getDevices();
    orderedDevices = devices.keys.toList();
    ModelCtrl().onDevicesEvent.subscribe(_onDevicesEvent);
  }

  @override
  void dispose() {
    ModelCtrl().onDevicesEvent.unsubscribe(_onDevicesEvent);
    super.dispose();
  }

  void _onDevicesEvent(args) {
    devices = ModelCtrl().getDevices();
    orderedDevices = devices.keys.toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // SizeBox with forced width is needed to avoid Exception
    return SizedBox(
        width: min(MediaQuery.of(context).size.width, 800),
        //height: 800,
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
            }));
  }

  static Widget deviceTileBuilder(BuildContext context, Device? device) {
    String name = '*Unknown*';
    if (device != null) {
      name = device.name;
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
            await editDeviceName(
              context,
              name,
              (deviceName, tapedName) {
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

  static Future<void> editDeviceName(
      BuildContext context, String deviceName, void Function(String deviceName, String tapedName) onValidate) async {
    var nameCtrl = TextEditingController(text: deviceName);
    await Common.showModalDialog(context,
        dlgButtons: DlgButtons.okCancel,
        title: "Changer le nom de l'équipement",
        onValidate: () => onValidate(deviceName, nameCtrl.text),
        content: StatefulBuilder(builder: (context, setState) {
          return SizedBox(
            width: min(MediaQuery.of(context).size.width, 800),
            child: Column(
            children: [
              TextFormField(
                controller: nameCtrl,
                style: TextStyle(color: AppTheme().specialTextColor),
                decoration: const InputDecoration(hintText: 'Nom'),
              ),
            ],
          ));
        }));
  }
}
