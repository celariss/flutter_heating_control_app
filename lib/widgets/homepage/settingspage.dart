import 'dart:convert';

import 'package:event/event.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:heating_control_app/common/common.dart';
import 'package:heating_control_app/common/model_ctrl.dart';
import 'package:heating_control_app/common/theme.dart';
import 'package:heating_control_app/main.dart';
import 'package:heating_control_app/widgets/homepage/themeseditorpage.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../common/settings.dart';
import '../../common/themenotifier.dart';
import '../../utils/package.dart';
import '../../utils/localizations.dart';
import '../../utils/settings_widget_helper.dart';
import 'deviceseditorpage.dart';

///////////////////////////////////////////////////////////////////////////
//             SETTINGS PAGE
///////////////////////////////////////////////////////////////////////////
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  static const String route = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  //final _formKey = GlobalKey<FormState>();
  ThemeNotifier ?themeNotifier;

  bool mqttChanged = false;
  String mqttUrl = Settings().MQTT.brokerAddress;
  String mqttUser = Settings().MQTT.user;
  String mqttPassword = Settings().MQTT.password;
  int mqttPort = Settings().MQTT.port;
  bool mqttSecure = Settings().MQTT.secure;
  String themeName = Settings().activeThemeName;
  List<String> themesList = [];
  String manualResetMode = '';
  int manualResetDuration = 4;
  int _settingsFormVersion = 0;

  List<String> getManualResetModesList() {
    return [
      wcLocalizations().settingsManualResetMode_Duration,
      wcLocalizations().settingsManualResetMode_TimeslotChange,
      wcLocalizations().settingsManualResetMode_SetPointChange,
    ];
  }

  String manualResetMode2Str() {
    switch (manualResetMode) {
      case '':
        return wcLocalizations().settingsManualResetMode_Duration;
      case 'timeslot_change':
        return wcLocalizations().settingsManualResetMode_TimeslotChange;
      case 'setpoint_change':
        return wcLocalizations().settingsManualResetMode_SetPointChange;
      default:
        return wcLocalizations().settingsManualResetMode_TimeslotChange;
    }
  }

  dynamic str2ManualResetMode(String value) {
    if (value == wcLocalizations().settingsManualResetMode_Duration) {
      return manualResetDuration;
    }
    else if (value == wcLocalizations().settingsManualResetMode_TimeslotChange) {
        return 'timeslot_change';
    }
    else if (value == wcLocalizations().settingsManualResetMode_SetPointChange) {
        return 'setpoint_change';
    }
  }



  @override
  void initState() {
    super.initState();
    //selectedScheduleName = getActiveSchedule();
    ModelCtrl().onSchedulesEvent.subscribe(_onSchedulesEvent);
    ModelCtrl().onMessageEvent.subscribe(_onMessageEvent);
    scheduler(ModelCtrl().getSchedulerData());
  }

  void scheduler(Map schedulerData) {
    if (schedulerData.containsKey('settings') &&
        schedulerData['settings'].containsKey('manual_mode_reset_event')) {
          dynamic manualModeResetEvent = schedulerData['settings']['manual_mode_reset_event'];
        if (manualModeResetEvent is int) {
          manualResetMode = '';
          manualResetDuration = manualModeResetEvent;
        }
        else {
          manualResetMode = manualModeResetEvent;
        }
    }
    else {
      manualResetMode = 'timeslot_change';
    }
  }


  void _onSchedulesEvent(Value<Map> args) {
    Map? schedulerData = args.value;
    scheduler(schedulerData);
    setState(() {});
  }

  void _onMessageEvent(Value<MessageInfo> args) {
    setState(() {});
  }

  @override
  void dispose() {
    ModelCtrl().onSchedulesEvent.unsubscribe(_onSchedulesEvent);
    ModelCtrl().onMessageEvent.unsubscribe(_onMessageEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    themeNotifier = Provider.of<ThemeNotifier>(context);
    themesList = Settings().getThemesList();
    return PopScope(
      // Called when user click on back button of the navigation bar
      onPopInvokedWithResult: (bool didPop, dynamic) {
        if (mqttChanged) {
          Settings().setMqttPassword(mqttPassword);
          Settings().setMqttUser(mqttUser);
          Settings().setMqttUrl(mqttUrl);
          Settings().setMqttPort(mqttPort);
          Settings().setMqttSecure(mqttSecure);
          ModelCtrl().disconnect();
          ModelCtrl().connect();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(wcLocalizations().settingsPageTitle), actions:[
          Common.createAppBarIconButton(
              Icons.save,
              onPressed:  () async {
                await _saveSettingsToFile(context);
              },
          ),
          Common.createAppBarIconButton(
              Icons.file_open_outlined,
              onPressed: () async {
                await _loadSettingsFromFile(context);
              },
          ),
        ]),
        body: SingleChildScrollView(
          child: Column(
                key: ValueKey(_settingsFormVersion),
                children: [
                  _buildInformationSection(),
                  _buildServerSection(),
                  _buildMainSection(),
                  _buildMQTTSection(),
                ],
            )
          ),
      ),
    );
  }

  static String localeToString(Locale locale) {
    String lang = Languages.getNameFromLocale(locale)!['nativeName'] ?? '';
    return '$lang (${locale.toLanguageTag()})';
  }

  static Widget _wrapIconButton(Widget btn) {
    return IconButtonTheme(
      data: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: AppTheme().focusColor,
          foregroundColor: AppTheme().buttonTextColor,
          hoverColor: AppTheme().buttonTextColor.withValues(alpha: 0.5),
        ),
      ),
      child: btn,
    );
  }

  static Widget _createVersionWidget(String version) {
    return Builder(
      builder: (BuildContext context) {
        final inputTheme = Theme.of(context).inputDecorationTheme;
        Color? themeEnabledColor = Theme.of(context).colorScheme.outline;
        if (inputTheme.enabledBorder!=null && inputTheme.enabledBorder?.borderSide!=null) {
          themeEnabledColor = inputTheme.enabledBorder?.borderSide.color;
        }
        themeEnabledColor = themeEnabledColor?.withValues(alpha:0.35);
        return SizedBox(
          width: 80.0,
          height: 30.0,
          child: InputDecorator(
            decoration: InputDecoration(
              contentPadding: EdgeInsetsGeometry.all(0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: themeEnabledColor!, width: 1.5),
              ),
            ),
            child: Text(version, textAlign: TextAlign.center, style: TextStyle(color: AppTheme().normalTextColor, fontSize: 18)),
          ),
        );
      }
    );
  }

  Widget _buildInformationSection() {
    return SettingsWidgetHelper.createSection(
      wcLocalizations().settingsAppVersion,
      <Widget>[ ],
      suffixWidget: _createVersionWidget(Package().getPackageInfo()?.version ?? '?'),
    );
  }

  Widget _buildServerSection() {
    final bool enabled = ModelCtrl().isConnectedToCtrlServer();
    return SettingsWidgetHelper.createSection(
      wcLocalizations().settingsGroupServer,
      <Widget>[
        SettingsWidgetHelper.createTextField(
          wcLocalizations().settingsServerVersion,
          enabled: enabled,
          suffixWidget: _createVersionWidget(enabled ? ModelCtrl().serverVersion : '?'),
        ),
        _wrapIconButton(SettingsWidgetHelper.createBtnField(
            wcLocalizations().settingsEditDevicesList,
            Icons.edit_note,
            () {
              Common.navigate(context, DevicesEditorPage.route, isRootNavigator: false);
            },
            enabled: enabled,
          ),
        ),
        SettingsWidgetHelper.createFieldsGroup(
          wcLocalizations().settingsGroupManualReset,
          <Widget>[
            SettingsWidgetHelper.createListPickerField(
              wcLocalizations().settingsManualResetMode,
              getManualResetModesList(),
              manualResetMode2Str(),
              (value) => ModelCtrl().setManualResetMode(str2ManualResetMode(value)),
              enabled: enabled,
            ),
          ],
          enabled: enabled,
        ),
        if (manualResetMode == '')
          SettingsWidgetHelper.createListPickerField(
            wcLocalizations().settingsManualResetDuration,
            List<String>.generate(24, (index) => '${index + 1}'),
            manualResetDuration.toString(),
            (value) => ModelCtrl().setManualResetMode(str2Int(value)),
            enabled: enabled,
          ),
      ],
    );
  }

  Widget _buildMainSection() {
    final List<String> langList = AppLocalizations.supportedLocales
        .map((locale) => localeToString(locale))
        .toList()
      ..insert(0, wcLocalizations().settingsSystemLanguage);
    String curLangName = wcLocalizations().settingsSystemLanguage;
    if (Settings().locale != null) {
      curLangName = localeToString(getCurrentLocale());
    }

    return SettingsWidgetHelper.createSection(
      wcLocalizations().settingsGroupMain,
      <Widget>[
        _wrapIconButton(SettingsWidgetHelper.createBtnField(
            wcLocalizations().settingsEditThemes,
            Icons.edit_note,
            () async {
              await Common.navigate(context, ThemesEditorPage.route, isRootNavigator: false);
              if (!context.mounted) return;
              setState(() {
                themesList = Settings().getThemesList();
                if (!themesList.contains(themeName)) {
                  themeName = themesList.contains(Settings().activeThemeName)
                      ? Settings().activeThemeName
                      : (themesList.isEmpty ? '' : themesList.first);
                  Settings().setActiveTheme(themeName);
                }
                themeNotifier!.refreshAppTheme();
              });
            },
         )),
        SettingsWidgetHelper.createListPickerField(wcLocalizations().settingsTheme, themesList, themeName, (value) {
          themeName = value;
          Settings().setActiveTheme(themeName);
          themeNotifier!.refreshAppTheme();
        }),
        SettingsWidgetHelper.createListPickerField(wcLocalizations().settingsLanguage, langList, curLangName, (value) {
          Locale? newLocale;
          curLangName = value;
          if (value != wcLocalizations().settingsSystemLanguage) {
            for (final Locale locale in AppLocalizations.supportedLocales) {
              if (localeToString(locale) == value) {
                newLocale = locale;
                break;
              }
            }
          }
          MyApp.setLocale(newLocale);
          Settings().setLocale(newLocale);
          themeNotifier!.refreshAppTheme();
        }),
        SettingsWidgetHelper.createListPickerField(
          wcLocalizations().settingsThermostatRes,
          <String>['0.1', '0.2', '0.5', '1.0'],
          Settings().thermostatResolution.toString(),
          (value) => Settings().setThermostatResolution(double.parse(value)),
        ),
      ],
    );
  }

  Widget _buildMQTTSection() {
    return SettingsWidgetHelper.createSection(
      wcLocalizations().settingsGroupMqtt,
      <Widget>[
        SettingsWidgetHelper.createTextFormField(wcLocalizations().settingsBrokerAddress, mqttUrl, (value) {
            mqttUrl = value;
            mqttChanged = true;
          },
          mandatory: true,
          requiredErrorText: wcLocalizations().settingsErrorMandatoryValue,
        ),
        SettingsWidgetHelper.createTextFormField(wcLocalizations().settingsUsername, mqttUser, (value) {
            mqttUser = value;
            mqttChanged = true;
          },
        ),
        SettingsWidgetHelper.createPasswordFormField(wcLocalizations().settingsPassword,mqttPassword, (value) {
            mqttPassword = value;
            mqttChanged = true;
          },
          showHideTooltip: wcLocalizations().settingsShowHidePassword,
        ),
        SettingsWidgetHelper.createIntFormField(wcLocalizations().settingsPortNumber, mqttPort, (value) {
            mqttPort = value;
            mqttChanged = true;
          },
          mandatory: true,
          requiredErrorText: wcLocalizations().settingsErrorMandatoryValue,
          errorText:wcLocalizations().settingsErrorInvalidValue,
        ),
        _buildSettingBool(wcLocalizations().settingsIsPortSecured, mqttSecure, (value) {
          mqttSecure = value;
          mqttChanged = true;
        },),
      ],
    );
  }

  Widget _buildSettingBool(
    String label,
    bool initialValue,
    void Function(dynamic) onChanged,
  ) {
    return SettingsWidgetHelper.createBoolFormField(
      label,
      initialValue,
      onChanged,
      noText:wcLocalizations().no,
      yesText: wcLocalizations().yes
    );
  }

  Future<void> _saveSettingsToFile(BuildContext context) async {
    try {
      final settingsJson = Settings().configToJson();
      final outputUri = await FilePicker.saveFile(
        fileName: 'heating_ctrl_settings.json',
        bytes: utf8.encode(settingsJson),
        mimeType: 'application/json',
        dialogTitle: wcLocalizations().saveFileDialogTitle,
      );

      if (outputUri == null) return;
    } catch (e) {
      if (!context.mounted) return;
      await Common.showWarningDialog(
        context,
        "${wcLocalizations().saveFileError} : ${e.toString()}",
        closeBtnOnly: true,
      );
    }
  }

  Future<void> _loadSettingsFromFile(BuildContext context) async {
    try {
      final selectedFile = await FilePicker.pickFile(
        dialogTitle: wcLocalizations().loadFileDialogTitle,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (selectedFile == null) return;

      final settingsJson = utf8.decode(await selectedFile.readAsBytes());
      await Settings().loadConfigFromJson(settingsJson);

      final settings = Settings();
      setState(() {
        mqttUrl = settings.MQTT.brokerAddress;
        mqttUser = settings.MQTT.user;
        mqttPassword = settings.MQTT.password;
        mqttPort = settings.MQTT.port;
        mqttSecure = settings.MQTT.secure;
        mqttChanged = true;
        themeName = settings.activeThemeName;
        themesList = settings.getThemesList();
        _settingsFormVersion++;
      });
      MyApp.setLocale(settings.locale);
      await themeNotifier?.refreshAppTheme();
    } catch (e) {
      if (!context.mounted) return;
      await Common.showWarningDialog(
        context,
        "${wcLocalizations().loadFileError} : ${e.toString()}",
        closeBtnOnly: true,
      );
    }
  }
}