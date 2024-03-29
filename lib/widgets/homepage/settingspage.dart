import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:heating_control_app/common/model_ctrl.dart';
import 'package:heating_control_app/main.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:card_settings/card_settings.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/settings.dart';
import '../../common/theme.dart';
import '../../common/themenotifier.dart';
import '../../utils/package.dart';
import '../../utils/localizations.dart';

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
  String themeName = Settings().themeName;
  List<String> themesList = Settings().getThemesList();

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
    //ModelCtrl().onSchedulesEvent.subscribe(_onSchedulesEvent);
  }

  void _addScrollListener() {
    _scrollController.addListener(handleScroll);
  }

  @override
  void dispose() {
    //ModelCtrl().onSchedulesEvent.unsubscribe(_onSchedulesEvent);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    themeNotifier = Provider.of<ThemeNotifier>(context);
    return PopScope(
      // Called when user click on back button of the navigation bar
      onPopInvoked: (bool didPop) {
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
        child: _buildPortraitLayout()
      ),
    ),
    );
  }

  static String localeToString(Locale locale) {
    String lang = Languages.getNameFromLocale(locale)!['nativeName'] ?? '';
    return '$lang (${locale.toLanguageTag()})';
  }

  CardSettings _buildPortraitLayout() {
    List<String> langList = AppLocalizations.supportedLocales.map((e) => localeToString(e)).toList();
    langList.insert(0, wcLocalizations().settingsSystemLanguage);
    String curLangName = wcLocalizations().settingsSystemLanguage;
    if (Settings().locale!=null) {
      curLangName = localeToString(getCurrentLocale());
    }
    return CardSettings.sectioned(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      showMaterialonIOS: false,
      labelWidth: 150,
      contentAlign: TextAlign.right,
      cardless: false,
      children: <CardSettingsSection>[
        CardSettingsSection(
          header: CardSettingsHeader(
            label: wcLocalizations().settingsAppVersion(Package().getPackageInfo()?.version ?? ''),
          ),
        ),
        CardSettingsSection(
          header: CardSettingsHeader(
            label: wcLocalizations().settingsGroupMain,
          ),
          children: <CardSettingsWidget>[
            _buildCardSettingsListPickerType(wcLocalizations().settingsTheme, themesList, themeName, (value) {
              themeName = value;
              Settings().setTheme(themeName);
              themeNotifier!.refreshAppTheme();
            }),
           _buildCardSettingsListPickerType(wcLocalizations().settingsLanguage, langList, curLangName, (value) {
              Locale ?newLocale;
              curLangName = value;
              if (value != wcLocalizations().settingsSystemLanguage) {
                for (Locale locale in AppLocalizations.supportedLocales) {
                  if (localeToString(locale)==value) {
                    newLocale = locale;
                    break;
                  }
                }
              }
              MyApp.setLocale(newLocale);
              Settings().setLocale(newLocale);
              themeNotifier!.refreshAppTheme();
            }),
            _buildCardSettingsListPickerType(wcLocalizations().settingsThermostatRes,
              ['0.1', '0.2', '0.5', '1.0'], Settings().thermostatResolution.toString(), (value) {
                Settings().setThermostatResolution(double.parse(value));
              }),
          ],
        ),
        CardSettingsSection(
          header: CardSettingsHeader(
            label: wcLocalizations().settingsGroupMqtt,
          ),
          //divider: Divider(thickness: 1.0, color: AppTheme().focusColor),
          children: <CardSettingsWidget>[
            _buildCardSettingsText(_mqttUrlKey, wcLocalizations().settingsBrokerAddress, mqttUrl, (value) {
              mqttUrl = value;
              mqttChanged = true;
            }, wcLocalizations().settingsErrorMandatoryValue),
            _buildCardSettingsText(_mqttUserKey, wcLocalizations().settingsUsername, mqttUser, (value) {
              mqttUser = value;
              mqttChanged = true;
            }, wcLocalizations().settingsErrorMandatoryValue),
            _buildCardSettingsPassword(_mqttPasswordKey, (value) {
              mqttPassword = value;
              mqttChanged = true;
            }),
            _buildCardSettingsInt(_mqttPortKey, wcLocalizations().settingsPortNumber, mqttPort, (value) {
              mqttPort = value;
              mqttChanged = true;
            }, wcLocalizations().settingsErrorMandatoryValue),
            _buildCardSettingsBool(_mqttSecureKey, wcLocalizations().settingsIsPortSecured, mqttSecure, (value) {
              mqttSecure = value;
              mqttChanged = true;
            }, wcLocalizations().settingsErrorMandatoryValue),
          ],
        ),
      ],
    );
  }

  CardSettingsListPicker _buildCardSettingsListPickerType(String title, List values, dynamic initialValue, void Function(dynamic) onChanged) {
    List<PickerModel> list = values.map((e) => PickerModel(e as String)).toList();
    PickerModel initial = list.firstWhere((e) => e.name==initialValue as String, orElse: () => const PickerModel(""));
    return CardSettingsListPicker<PickerModel>(
      key: UniqueKey(),
      label: title,
      initialItem: initial,
      hintText: initialValue as String,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      items: list,
      onChanged: (value) {
        setState(() {
          initial = value!;
          onChanged(value.name);
        });
      },
    );
  }

  CardSettingsText _buildCardSettingsText(Key key, String label, String initialValue, void Function(dynamic) onChanged, String ?requiredText) {
    return CardSettingsText(
      key: key,
      label: label,
      initialValue: initialValue,
      requiredIndicator: requiredText!=null ? Text('*', style: TextStyle(color: AppTheme().focusColor)) : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      //focusNode: _focusNode,
      inputAction: TextInputAction.next,
      maxLength: 32,
      //inputActionNode: _actionNode,
      //inputMask: '000.000.000.000',
      validator: (value) {
        if (requiredText!=null && (value == null || value.isEmpty)) return requiredText;
        return null;
      },
      onChanged: (value) {
        setState(() {
          onChanged(value);
        });
      },
    );
  }

CardSettingsInt _buildCardSettingsInt(Key key, String label, int initialValue, void Function(dynamic) onChanged, String ?requiredText) {
    return CardSettingsInt(
      key: key,
      label: label,
      initialValue: initialValue,
      requiredIndicator: requiredText!=null ? Text('*', style: TextStyle(color: AppTheme().focusColor)) : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      //focusNode: _focusNode,
      inputAction: TextInputAction.next,
      maxLength: 32,
      //inputActionNode: _actionNode,
      //inputMask: '000.000.000.000',
      validator: (value) {
        if (requiredText!=null && (value == null)) return requiredText;
        return null;
      },
      onChanged: (value) {
        setState(() {
          onChanged(value);
        });
      },
    );
  }

// ignore: unused_element
CardSettingsDouble _buildCardSettingsDouble(Key key, String label, double initialValue, double min_, double max_, void Function(dynamic) onChanged, String ?requiredText, String ?badValueText) {
    return CardSettingsDouble(
      key: key,
      label: label,
      initialValue: initialValue,
      requiredIndicator: requiredText!=null ? Text('*', style: TextStyle(color: AppTheme().focusColor)) : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      //focusNode: _focusNode,
      inputAction: TextInputAction.next,
      decimalDigits: 2,
      unitLabel: '°',
      //inputActionNode: _actionNode,
      //inputMask: '000.000.000.000',
      validator: (value) {
        if (requiredText!=null && (value == null)) return requiredText;
        if (badValueText!=null && (value == null)) return requiredText;
        return null;
      },
      onChanged: (value) {
        setState(() {
          onChanged(value);
        });
      },
    );
  }

CardSettingsSwitch _buildCardSettingsBool(Key key, String label, bool initialValue, void Function(dynamic) onChanged, String ?requiredText) {
    return CardSettingsSwitch(
      key: key,
      falseLabel: wcLocalizations().no,
      trueLabel: wcLocalizations().yes,
      label: label,
      initialValue: initialValue,
      requiredIndicator: requiredText!=null ? Text('*', style: TextStyle(color: AppTheme().focusColor)) : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      //focusNode: _focusNode,
      //inputAction: TextInputAction.next,
      //inputActionNode: _actionNode,
      //inputMask: '000.000.000.000',
      validator: (value) {
        if (requiredText!=null && (value == null)) return requiredText;
        return null;
      },
      onChanged: (value) {
        setState(() {
          onChanged(value);
        });
      },
    );
  }

  CardSettingsPassword _buildCardSettingsPassword(Key key, void Function(dynamic) onChanged) {
    return CardSettingsPassword(
      key: key,
      icon: const Icon(Icons.lock),
      labelWidth: 200,
      label: wcLocalizations().settingsPassword,
      initialValue: mqttPassword,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (value) {
        setState(() {
          onChanged(value);
        });
      },
    );
  }
}
