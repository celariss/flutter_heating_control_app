import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:heating_control_app/common/common.dart';
import 'package:heating_control_app/common/model_ctrl.dart';
import 'package:heating_control_app/main.dart';
import 'package:heating_control_app/widgets/homepage/themeseditorpage.dart';
import 'package:navbar_router/navbar_router.dart';
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
  final _scrollController = ScrollController();
  Size size = Size.zero;
  ThemeNotifier ?themeNotifier;

  bool mqttChanged = false;
  String mqttUrl = Settings().MQTT.brokerAddress;
  String mqttUser = Settings().MQTT.user;
  String mqttPassword = Settings().MQTT.password;
  int mqttPort = Settings().MQTT.port;
  bool mqttSecure = Settings().MQTT.secure;
  String themeName = Settings().themeName;
  List<String> themesList = [];
  String manualResetMode = '';
  int manualResetDuration = 4;

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

  void _addScrollListener() {
    _scrollController.addListener(handleScroll);
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
    _scrollController.dispose();
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
        appBar: AppBar(title: Text(wcLocalizations().settingsPageTitle)),
        body: SingleChildScrollView(
          padding: Common.getNavbarHeightPadding(),
          child: Column(
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

  Widget _buildInformationSection() {
    return SettingsWidgetHelper.createSection(
      wcLocalizations().settingsAppVersion(Package().getPackageInfo()?.version ?? ''),
      <Widget>[ ],
      context
    );
  }

  Widget _buildServerSection() {
    final bool enabled = ModelCtrl().isConnectedToCtrlServer();
    return SettingsWidgetHelper.createSection(
      wcLocalizations().settingsGroupServer,
      <Widget>[
        SettingsWidgetHelper.createTextField(wcLocalizations().settingsServerVersion(enabled ? ModelCtrl().serverVersion : '?'), enabled: enabled),
        SettingsWidgetHelper.createBtnField(
          wcLocalizations().settingsEditDevicesList,
          Icons.edit_note,
          () {
            NavbarNotifier.hideBottomNavBar = false;
            Common.navBarNavigate(context, DevicesEditorPage.route, isRootNavigator: false);
          },
          enabled: enabled,
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
          ]
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
      context
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
         SettingsWidgetHelper.createBtnField(
          wcLocalizations().settingsEditThemes,
          Icons.edit_note,
          () async {
            NavbarNotifier.hideBottomNavBar = false;
            await Common.navBarNavigate(context, ThemesEditorPage.route, isRootNavigator: false);
            if (!mounted) return;
            setState(() {
              themesList = Settings().getThemesList();
              if (!themesList.contains(themeName)) {
                themeName = themesList.contains(Settings().themeName)
                    ? Settings().themeName
                    : (themesList.isEmpty ? '' : themesList.first);
                Settings().setTheme(themeName);
              }
              themeNotifier!.refreshAppTheme();
            });
          },
        ),
        SettingsWidgetHelper.createListPickerField(wcLocalizations().settingsTheme, themesList, themeName, (value) {
          themeName = value;
          Settings().setTheme(themeName);
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
      context
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
          errorText:wcLocalizations().settingsErrorInvalidFormat,
        ),
        _buildSettingBool(wcLocalizations().settingsIsPortSecured, mqttSecure, (value) {
          mqttSecure = value;
          mqttChanged = true;
        },),
      ],
      context
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
}
