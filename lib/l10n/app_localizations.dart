import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @new_.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get new_;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit{item, select, eqptlist{ devices list} other{}}'**
  String editAction(String item);

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add{item, select, slots{ daily timeslots} subschedule{ sub-schedule} other{}}'**
  String addAction(String item);

  /// No description provided for @cloneAction.
  ///
  /// In en, this message translates to:
  /// **'Clone'**
  String get cloneAction;

  /// No description provided for @removeAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeAction;

  /// No description provided for @closeAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeAction;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @validateAction.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get validateAction;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @moveUpAction.
  ///
  /// In en, this message translates to:
  /// **'Move Up'**
  String get moveUpAction;

  /// No description provided for @moveDownAction.
  ///
  /// In en, this message translates to:
  /// **'Move Down'**
  String get moveDownAction;

  /// No description provided for @popupPickDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Devices selection'**
  String get popupPickDeviceTitle;

  /// No description provided for @popupPickPlanningTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a planning'**
  String get popupPickPlanningTitle;

  /// No description provided for @popupPickColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get popupPickColorTitle;

  /// No description provided for @popupErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get popupErrorTitle;

  /// No description provided for @popupWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get popupWarningTitle;

  /// No description provided for @popupWaitingConnection.
  ///
  /// In en, this message translates to:
  /// **'Waiting for server connection ...'**
  String get popupWaitingConnection;

  /// No description provided for @popupNoMQTTParameters.
  ///
  /// In en, this message translates to:
  /// **'Please set server connexion parameters in settings page'**
  String get popupNoMQTTParameters;

  /// No description provided for @popupNoDevices.
  ///
  /// In en, this message translates to:
  /// **'Please add some devices in settings page'**
  String get popupNoDevices;

  /// No description provided for @removeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you confirm the removing of {item, select, eqpt{equipement} schedule{schedule} tempset{temperature set} subschedule{this sub-schedule} timeslots{this daily timeslots} other{}} \'{name}\' ?'**
  String removeConfirmation(String item, String name);

  /// No description provided for @removeFortnightConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you confirm to turn off fortnight mode ? The \'B\' week will be lost.'**
  String get removeFortnightConfirmation;

  /// No description provided for @errorDuplicateKey.
  ///
  /// In en, this message translates to:
  /// **'The key \'{key}\' already exists ...'**
  String errorDuplicateKey(String key);

  /// No description provided for @errorDuplicateDevice.
  ///
  /// In en, this message translates to:
  /// **'The device \'{key}\' is already in another schedule item'**
  String errorDuplicateDevice(String key);

  /// No description provided for @weekChipMonday.
  ///
  /// In en, this message translates to:
  /// **'Mo'**
  String get weekChipMonday;

  /// No description provided for @weekChipTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tu'**
  String get weekChipTuesday;

  /// No description provided for @weekChipWednesday.
  ///
  /// In en, this message translates to:
  /// **'We'**
  String get weekChipWednesday;

  /// No description provided for @weekChipThurday.
  ///
  /// In en, this message translates to:
  /// **'Th'**
  String get weekChipThurday;

  /// No description provided for @weekChipFriday.
  ///
  /// In en, this message translates to:
  /// **'Fr'**
  String get weekChipFriday;

  /// No description provided for @weekChipSaturday.
  ///
  /// In en, this message translates to:
  /// **'Sa'**
  String get weekChipSaturday;

  /// No description provided for @weekChipSunday.
  ///
  /// In en, this message translates to:
  /// **'Su'**
  String get weekChipSunday;

  /// Title of the home navbar item
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navbarHome;

  /// Title of the temperature sets navbar item
  ///
  /// In en, this message translates to:
  /// **'T° Sets'**
  String get navbarTempsets;

  /// Title of the plannings navbar item
  ///
  /// In en, this message translates to:
  /// **'Schedules'**
  String get navbarPlannings;

  /// Text shown in snackbar after back button has been hit
  ///
  /// In en, this message translates to:
  /// **'Press twice to exit'**
  String get snackbarBackButton;

  /// No description provided for @msgInfoCode_mqttServerConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected to server'**
  String get msgInfoCode_mqttServerConnected;

  /// No description provided for @msgInfoCode_mqttServerDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected from server !'**
  String get msgInfoCode_mqttServerDisconnected;

  /// No description provided for @msgInfoCode_mqttMessageError.
  ///
  /// In en, this message translates to:
  /// **'Malformed message received from server !'**
  String get msgInfoCode_mqttMessageError;

  /// No description provided for @msgInfoCode_controlServerAvailable.
  ///
  /// In en, this message translates to:
  /// **'Heating control server available'**
  String get msgInfoCode_controlServerAvailable;

  /// No description provided for @msgInfoCode_controlServerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Heating control server unavailable !'**
  String get msgInfoCode_controlServerUnavailable;

  /// Popup dialog title that displays error received from server
  ///
  /// In en, this message translates to:
  /// **'Change has been refused'**
  String get srvResponseDialogTitle;

  /// text displayed when server refused last command
  ///
  /// In en, this message translates to:
  /// **'Change has been refused !'**
  String get srvResponseRefused;

  /// text displayed when server error is DUPLICATE_UNIQUE_KEY
  ///
  /// In en, this message translates to:
  /// **'Key \'{key}\' is already declared !'**
  String srvResponseDuplicateKey(String key);

  /// text displayed when server error is EMPTY_LIST
  ///
  /// In en, this message translates to:
  /// **'The list can\'t be empty !'**
  String get srvResponseEmptyList;

  /// text displayed when server error is BAD_VALUE
  ///
  /// In en, this message translates to:
  /// **'Value \'{value}\' is not allowed !'**
  String srvResponseBadValue(String value);

  /// text displayed when server error is CIRCULAR_REF
  ///
  /// In en, this message translates to:
  /// **'Circular reference detected between following temp sets : {aliases}'**
  String srvResponseCircularRef(List<String> aliases);

  /// text displayed when server error is MISSING_VALUE
  ///
  /// In en, this message translates to:
  /// **'Value \'{value}\' is missing in list !'**
  String srvResponseMissingValue(String value);

  /// No description provided for @settingsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsPageTitle;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'Application version : {version}'**
  String settingsAppVersion(String version);

  /// No description provided for @settingsServerVersion.
  ///
  /// In en, this message translates to:
  /// **'Server version : {version}'**
  String settingsServerVersion(String version);

  /// No description provided for @settingsErrorMandatoryValue.
  ///
  /// In en, this message translates to:
  /// **'value is mandatory'**
  String get settingsErrorMandatoryValue;

  /// No description provided for @settingsGroupServer.
  ///
  /// In en, this message translates to:
  /// **'Server side settings'**
  String get settingsGroupServer;

  /// No description provided for @settingsGroupMain.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get settingsGroupMain;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSystemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsSystemLanguage;

  /// No description provided for @settingsEditDevicesList.
  ///
  /// In en, this message translates to:
  /// **'Edit devices list'**
  String get settingsEditDevicesList;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThermostatRes.
  ///
  /// In en, this message translates to:
  /// **'thermostats resolution'**
  String get settingsThermostatRes;

  /// No description provided for @settingsGroupManualReset.
  ///
  /// In en, this message translates to:
  /// **'Manual valve setpoint handling'**
  String get settingsGroupManualReset;

  /// No description provided for @settingsManualResetMode.
  ///
  /// In en, this message translates to:
  /// **'Auto mode back mode'**
  String get settingsManualResetMode;

  /// No description provided for @settingsManualResetDuration.
  ///
  /// In en, this message translates to:
  /// **'Time until return'**
  String get settingsManualResetDuration;

  /// No description provided for @settingsManualResetMode_Duration.
  ///
  /// In en, this message translates to:
  /// **'Duration (hours)'**
  String get settingsManualResetMode_Duration;

  /// No description provided for @settingsManualResetMode_TimeslotChange.
  ///
  /// In en, this message translates to:
  /// **'Timeslot change'**
  String get settingsManualResetMode_TimeslotChange;

  /// No description provided for @settingsManualResetMode_SetPointChange.
  ///
  /// In en, this message translates to:
  /// **'Setpoint change'**
  String get settingsManualResetMode_SetPointChange;

  /// No description provided for @settingsGroupMqtt.
  ///
  /// In en, this message translates to:
  /// **'MQTT connexion settings'**
  String get settingsGroupMqtt;

  /// No description provided for @settingsBrokerAddress.
  ///
  /// In en, this message translates to:
  /// **'Broker adresss'**
  String get settingsBrokerAddress;

  /// No description provided for @settingsUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get settingsUsername;

  /// No description provided for @settingsPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get settingsPassword;

  /// No description provided for @settingsPortNumber.
  ///
  /// In en, this message translates to:
  /// **'Port (WebSocket)'**
  String get settingsPortNumber;

  /// No description provided for @settingsIsPortSecured.
  ///
  /// In en, this message translates to:
  /// **'SSL'**
  String get settingsIsPortSecured;

  /// No description provided for @devicesEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'List of thermostats'**
  String get devicesEditorTitle;

  /// No description provided for @devicesEditorEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Device properties'**
  String get devicesEditorEditTitle;

  /// No description provided for @devicesEditorEditEntity.
  ///
  /// In en, this message translates to:
  /// **'Entity'**
  String get devicesEditorEditEntity;

  /// No description provided for @devicesEditorEditName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get devicesEditorEditName;

  /// No description provided for @homePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homePageTitle;

  /// No description provided for @homePageNoActiveSchedule.
  ///
  /// In en, this message translates to:
  /// **'No active schedule'**
  String get homePageNoActiveSchedule;

  /// No description provided for @homePageActiveSchedule.
  ///
  /// In en, this message translates to:
  /// **'Current active schedule'**
  String get homePageActiveSchedule;

  /// No description provided for @tempSetsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Temperature Sets'**
  String get tempSetsPageTitle;

  /// No description provided for @tempSetEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Temperature set properties'**
  String get tempSetEditTitle;

  /// No description provided for @tempSetEditName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get tempSetEditName;

  /// No description provided for @tempSetEditNameHint.
  ///
  /// In en, this message translates to:
  /// **'Set name'**
  String get tempSetEditNameHint;

  /// No description provided for @tempSetEditColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get tempSetEditColor;

  /// No description provided for @timeslotWeekA.
  ///
  /// In en, this message translates to:
  /// **'A'**
  String get timeslotWeekA;

  /// No description provided for @timeslotWeekB.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get timeslotWeekB;

  /// No description provided for @timeslotAddAfter.
  ///
  /// In en, this message translates to:
  /// **'Add after'**
  String get timeslotAddAfter;

  /// No description provided for @timeslotSetEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edition of a daily schedule'**
  String get timeslotSetEditTitle;

  /// No description provided for @schedulesPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedules'**
  String get schedulesPageTitle;

  /// No description provided for @schedulesPageErrorMissingThermostatAndTempSet.
  ///
  /// In en, this message translates to:
  /// **'Please first add a thermostat and create a temperature set ...'**
  String get schedulesPageErrorMissingThermostatAndTempSet;

  /// No description provided for @schedulePageErrorBadParent.
  ///
  /// In en, this message translates to:
  /// **'Given parent schedule does not exist !'**
  String get schedulePageErrorBadParent;

  /// No description provided for @schedulePageErrorNoUnaffectedDevices.
  ///
  /// In en, this message translates to:
  /// **'Can not create schedule item : no device left !'**
  String get schedulePageErrorNoUnaffectedDevices;

  /// No description provided for @scheduleEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Planning properties'**
  String get scheduleEditTitle;

  /// No description provided for @scheduleEditName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get scheduleEditName;

  /// No description provided for @scheduleEditParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get scheduleEditParent;

  /// No description provided for @scheduleEditNameHint.
  ///
  /// In en, this message translates to:
  /// **'Planning name'**
  String get scheduleEditNameHint;

  /// No description provided for @scheduleParentPrefix.
  ///
  /// In en, this message translates to:
  /// **'Inherits from'**
  String get scheduleParentPrefix;

  /// No description provided for @timeslotsFortnightSwitch.
  ///
  /// In en, this message translates to:
  /// **'Fortnight mode on/off'**
  String get timeslotsFortnightSwitch;

  /// No description provided for @timeslotsErrorNotEmpty.
  ///
  /// In en, this message translates to:
  /// **'Some weekdays are still active on this daily timeslots'**
  String get timeslotsErrorNotEmpty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
