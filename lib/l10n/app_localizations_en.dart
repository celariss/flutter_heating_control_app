// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get new_ => 'New';

  @override
  String get unknown => 'Unknown';

  @override
  String editAction(String item) {
    String _temp0 = intl.Intl.selectLogic(
      item,
      {
        'eqptlist': ' devices list',
        'other': '',
      },
    );
    return 'Edit$_temp0';
  }

  @override
  String addAction(String item) {
    String _temp0 = intl.Intl.selectLogic(
      item,
      {
        'slots': ' daily timeslots',
        'subschedule': ' sub-schedule',
        'other': '',
      },
    );
    return 'Add$_temp0';
  }

  @override
  String get cloneAction => 'Clone';

  @override
  String get removeAction => 'Remove';

  @override
  String get closeAction => 'Close';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get validateAction => 'Validate';

  @override
  String get continueAction => 'Continue';

  @override
  String get moveUpAction => 'Move Up';

  @override
  String get moveDownAction => 'Move Down';

  @override
  String get popupPickDeviceTitle => 'Devices selection';

  @override
  String get popupPickPlanningTitle => 'Pick a planning';

  @override
  String get popupPickColorTitle => 'Pick a color';

  @override
  String get popupErrorTitle => 'Error';

  @override
  String get popupWarningTitle => 'Warning';

  @override
  String get popupWaitingConnection => 'Waiting for server connection ...';

  @override
  String get popupNoMQTTParameters =>
      'Please set server connexion parameters in settings page';

  @override
  String get popupNoDevices => 'Please add some devices in settings page';

  @override
  String removeConfirmation(String item, String name) {
    String _temp0 = intl.Intl.selectLogic(
      item,
      {
        'eqpt': 'equipement',
        'schedule': 'schedule',
        'tempset': 'temperature set',
        'subschedule': 'this sub-schedule',
        'timeslots': 'this daily timeslots',
        'other': '',
      },
    );
    return 'Do you confirm the removing of $_temp0 \'$name\' ?';
  }

  @override
  String get removeFortnightConfirmation =>
      'Do you confirm to turn off fortnight mode ? The \'B\' week will be lost.';

  @override
  String errorDuplicateKey(String key) {
    return 'The key \'$key\' already exists ...';
  }

  @override
  String errorDuplicateDevice(String key) {
    return 'The device \'$key\' is already in another schedule item';
  }

  @override
  String get weekChipMonday => 'Mo';

  @override
  String get weekChipTuesday => 'Tu';

  @override
  String get weekChipWednesday => 'We';

  @override
  String get weekChipThurday => 'Th';

  @override
  String get weekChipFriday => 'Fr';

  @override
  String get weekChipSaturday => 'Sa';

  @override
  String get weekChipSunday => 'Su';

  @override
  String get navbarHome => 'Home';

  @override
  String get navbarTempsets => 'T° Sets';

  @override
  String get navbarPlannings => 'Schedules';

  @override
  String get snackbarBackButton => 'Press twice to exit';

  @override
  String get msgInfoCode_mqttServerConnected => 'Connected to server';

  @override
  String get msgInfoCode_mqttServerDisconnected => 'Disconnected from server !';

  @override
  String get msgInfoCode_mqttMessageError =>
      'Malformed message received from server !';

  @override
  String get msgInfoCode_controlServerAvailable =>
      'Heating control server available';

  @override
  String get msgInfoCode_controlServerUnavailable =>
      'Heating control server unavailable !';

  @override
  String get srvResponseDialogTitle => 'Change has been refused';

  @override
  String get srvResponseRefused => 'Change has been refused !';

  @override
  String srvResponseDuplicateKey(String key) {
    return 'Key \'$key\' is already declared !';
  }

  @override
  String get srvResponseEmptyList => 'The list can\'t be empty !';

  @override
  String srvResponseBadValue(String value) {
    return 'Value \'$value\' is not allowed !';
  }

  @override
  String srvResponseCircularRef(List<String> aliases) {
    return 'Circular reference detected between following temp sets : $aliases';
  }

  @override
  String srvResponseMissingValue(String value) {
    return 'Value \'$value\' is missing in list !';
  }

  @override
  String get settingsPageTitle => 'Settings';

  @override
  String settingsAppVersion(String version) {
    return 'Application version : $version';
  }

  @override
  String settingsServerVersion(String version) {
    return 'Server version : $version';
  }

  @override
  String get settingsErrorMandatoryValue => 'value is mandatory';

  @override
  String get settingsGroupServer => 'Server side settings';

  @override
  String get settingsGroupMain => 'Main';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSystemLanguage => 'System';

  @override
  String get settingsEditDevicesList => 'Edit devices list';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThermostatRes => 'thermostats resolution';

  @override
  String get settingsGroupManualReset => 'Manual valve setpoint handling';

  @override
  String get settingsManualResetMode => 'Auto mode back mode';

  @override
  String get settingsManualResetDuration => 'Time until return';

  @override
  String get settingsManualResetMode_Duration => 'Duration (hours)';

  @override
  String get settingsManualResetMode_TimeslotChange => 'Timeslot change';

  @override
  String get settingsManualResetMode_SetPointChange => 'Setpoint change';

  @override
  String get settingsGroupMqtt => 'MQTT connexion settings';

  @override
  String get settingsBrokerAddress => 'Broker adresss';

  @override
  String get settingsUsername => 'Username';

  @override
  String get settingsPassword => 'Password';

  @override
  String get settingsPortNumber => 'Port (WebSocket)';

  @override
  String get settingsIsPortSecured => 'SSL';

  @override
  String get devicesEditorTitle => 'List of thermostats';

  @override
  String get devicesEditorEditTitle => 'Device properties';

  @override
  String get devicesEditorEditEntity => 'Entity';

  @override
  String get devicesEditorEditName => 'Name';

  @override
  String get homePageTitle => 'Home';

  @override
  String get homePageNoActiveSchedule => 'No active schedule';

  @override
  String get homePageActiveSchedule => 'Current active schedule';

  @override
  String get tempSetsPageTitle => 'Temperature Sets';

  @override
  String get tempSetEditTitle => 'Temperature set properties';

  @override
  String get tempSetEditName => 'Name';

  @override
  String get tempSetEditNameHint => 'Set name';

  @override
  String get tempSetEditColor => 'Color';

  @override
  String get timeslotWeekA => 'A';

  @override
  String get timeslotWeekB => 'B';

  @override
  String get timeslotAddAfter => 'Add after';

  @override
  String get timeslotSetEditTitle => 'Edition of a daily schedule';

  @override
  String get schedulesPageTitle => 'Schedules';

  @override
  String get schedulesPageErrorMissingThermostatAndTempSet =>
      'Please first add a thermostat and create a temperature set ...';

  @override
  String get schedulePageErrorBadParent =>
      'Given parent schedule does not exist !';

  @override
  String get schedulePageErrorNoUnaffectedDevices =>
      'Can not create schedule item : no device left !';

  @override
  String get scheduleEditTitle => 'Planning properties';

  @override
  String get scheduleEditName => 'Name';

  @override
  String get scheduleEditParent => 'Parent';

  @override
  String get scheduleEditNameHint => 'Planning name';

  @override
  String get scheduleParentPrefix => 'Inherits from';

  @override
  String get timeslotsFortnightSwitch => 'Fortnight mode on/off';

  @override
  String get timeslotsErrorNotEmpty =>
      'Some weekdays are still active on this daily timeslots';
}
