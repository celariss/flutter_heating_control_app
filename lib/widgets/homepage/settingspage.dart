import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:heating_control_app/common/common.dart';
import 'package:heating_control_app/common/model_ctrl.dart';
import 'package:heating_control_app/main.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../common/settings.dart';
import '../../common/themenotifier.dart';
import '../../utils/package.dart';
import '../../utils/localizations.dart';
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
  final _scrollController = ScrollController();
  Size size = Size.zero;
  final GlobalKey<FormState> _mqttUrlKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _mqttUserKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _mqttPortKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _mqttSecureKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _mqttPasswordKey = GlobalKey<FormState>();
  ThemeNotifier ?themeNotifier;

  bool mqttChanged = false;
  String mqttUrl = Settings().MQTT.brokerAddress;
  String mqttUser = Settings().MQTT.user;
  String mqttPassword = Settings().MQTT.password;
  int mqttPort = Settings().MQTT.port;
  bool mqttSecure = Settings().MQTT.secure;
  bool _obscureMqttPassword = true;
  String themeName = Settings().themeName;
  List<String> themesList = Settings().getThemesList();
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
            children: <Widget>[
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

  Widget _settingsSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInformationSection() {
    return _settingsSection(
      wcLocalizations().settingsAppVersion(Package().getPackageInfo()?.version ?? ''),
      <Widget>[
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(wcLocalizations().settingsServerVersion(ModelCtrl().serverVersion)),
        ),
      ],
    );
  }

  Widget _buildServerSection() {
    final bool enabled = ModelCtrl().isConnectedToCtrlServer();
    return _settingsSection(
      wcLocalizations().settingsGroupServer,
      <Widget>[
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(wcLocalizations().settingsEditDevicesList),
          trailing: Common.createCircleIconButton(
            Icons.edit_note,
            iconSize: 50,
            enabled: enabled,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            onPressed: () {
              NavbarNotifier.hideBottomNavBar = false;
              Common.navBarNavigate(context, DevicesEditorPage.route, isRootNavigator: false);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(wcLocalizations().settingsGroupManualReset,
              style: Theme.of(context).textTheme.titleSmall),
        ),
        _buildSettingListPicker(
          wcLocalizations().settingsManualResetMode,
          getManualResetModesList(),
          manualResetMode2Str(),
          (value) => ModelCtrl().setManualResetMode(str2ManualResetMode(value)),
          enabled,
        ),
        if (manualResetMode == '')
          _buildSettingListPicker(
            wcLocalizations().settingsManualResetDuration,
            List<String>.generate(24, (index) => '${index + 1}'),
            manualResetDuration.toString(),
            (value) => ModelCtrl().setManualResetMode(str2Int(value)),
            enabled,
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

    return _settingsSection(
      wcLocalizations().settingsGroupMain,
      <Widget>[
        _buildSettingListPicker(wcLocalizations().settingsTheme, themesList, themeName, (value) {
          themeName = value;
          Settings().setTheme(themeName);
          themeNotifier!.refreshAppTheme();
        }),
        _buildSettingListPicker(wcLocalizations().settingsLanguage, langList, curLangName, (value) {
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
        _buildSettingListPicker(
          wcLocalizations().settingsThermostatRes,
          <String>['0.1', '0.2', '0.5', '1.0'],
          Settings().thermostatResolution.toString(),
          (value) => Settings().setThermostatResolution(double.parse(value)),
        ),
      ],
    );
  }

  Widget _buildMQTTSection() {
    return _settingsSection(
      wcLocalizations().settingsGroupMqtt,
      <Widget>[
        _buildSettingText(_mqttUrlKey, wcLocalizations().settingsBrokerAddress, mqttUrl, (value) {
          mqttUrl = value;
          mqttChanged = true;
        }, wcLocalizations().settingsErrorMandatoryValue),
        _buildSettingText(_mqttUserKey, wcLocalizations().settingsUsername, mqttUser, (value) {
          mqttUser = value;
          mqttChanged = true;
        }, wcLocalizations().settingsErrorMandatoryValue),
        _buildSettingPassword(_mqttPasswordKey, (value) {
          mqttPassword = value;
          mqttChanged = true;
        }),
        _buildSettingInt(_mqttPortKey, wcLocalizations().settingsPortNumber, mqttPort, (value) {
          mqttPort = value;
          mqttChanged = true;
        }, wcLocalizations().settingsErrorMandatoryValue),
        _buildSettingBool(_mqttSecureKey, wcLocalizations().settingsIsPortSecured, mqttSecure, (value) {
          mqttSecure = value;
          mqttChanged = true;
        }, wcLocalizations().settingsErrorMandatoryValue),
      ],
    );
  }

  Widget _buildSettingListPicker(
    String title,
    List values,
    dynamic initialValue,
    void Function(dynamic) onChanged, [
    bool enabled = true,
  ]) {
    final List<String> options = values.cast<String>();
    return DropdownButtonFormField<String>(
      key: UniqueKey(),
      initialValue: options.contains(initialValue) ? initialValue as String : null,
      isExpanded: true,
      decoration: InputDecoration(labelText: title),
      items: options
          .map((value) => DropdownMenuItem<String>(value: value, child: Text(value)))
          .toList(),
      onChanged: enabled
          ? (value) {
              if (value == null) return;
              setState(() => onChanged(value));
            }
          : null,
    );
  }

  Widget _buildSettingText(
    Key key,
    String label,
    String initialValue,
    void Function(dynamic) onChanged,
    String? requiredText,
  ) {
    return TextFormField(
      key: key,
      initialValue: initialValue,
      maxLength: 32,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (requiredText != null && (value == null || value.isEmpty)) return requiredText;
        return null;
      },
      onChanged: (value) => setState(() => onChanged(value)),
    );
  }

  Widget _buildSettingInt(
    Key key,
    String label,
    int initialValue,
    void Function(dynamic) onChanged,
    String? requiredText,
  ) {
    return TextFormField(
      key: key,
      initialValue: initialValue.toString(),
      maxLength: 32,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (requiredText != null && (value == null || value.isEmpty)) return requiredText;
        if (value != null && int.tryParse(value) == null) return requiredText;
        return null;
      },
      onChanged: (value) {
        final int? parsedValue = int.tryParse(value);
        if (parsedValue != null) setState(() => onChanged(parsedValue));
      },
    );
  }

  Widget _buildSettingBool(
    Key key,
    String label,
    bool initialValue,
    void Function(dynamic) onChanged,
    String? requiredText,
  ) {
    return ListTile(
      key: key,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(wcLocalizations().no),
          Switch(
            value: initialValue,
            onChanged: (value) => setState(() => onChanged(value)),
          ),
          Text(wcLocalizations().yes),
        ],
      ),
    );
  }

  Widget _buildSettingPassword(Key key, void Function(dynamic) onChanged) {
    return TextFormField(
      key: key,
      initialValue: mqttPassword,
      obscureText: _obscureMqttPassword,
      maxLength: 32,
      decoration: InputDecoration(
        labelText: wcLocalizations().settingsPassword,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          tooltip: wcLocalizations().settingsPassword,
          icon: Icon(_obscureMqttPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() {
            _obscureMqttPassword = !_obscureMqttPassword;
          }),
        ),
      ),
      onChanged: (value) => setState(() => onChanged(value)),
    );
  }

}
