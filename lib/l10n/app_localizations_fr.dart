// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get no => 'Non';

  @override
  String get yes => 'Oui';

  @override
  String get new_ => 'Nouveau';

  @override
  String get unknown => 'Inconnu';

  @override
  String editAction(String item) {
    String _temp0 = intl.Intl.selectLogic(
      item,
      {
        'eqptlist': ' la liste des vannes',
        'other': '',
      },
    );
    return 'Editer$_temp0';
  }

  @override
  String addAction(String item) {
    String _temp0 = intl.Intl.selectLogic(
      item,
      {
        'slots': ' une plage hebdomadaire',
        'subschedule': ' un sous-planning',
        'other': '',
      },
    );
    return 'Ajouter$_temp0';
  }

  @override
  String get cloneAction => 'Dupliquer';

  @override
  String get removeAction => 'Supprimer';

  @override
  String get closeAction => 'Fermer';

  @override
  String get cancelAction => 'Annuler';

  @override
  String get validateAction => 'Valider';

  @override
  String get continueAction => 'Continuer';

  @override
  String get moveUpAction => 'Monter d\'un cran';

  @override
  String get moveDownAction => 'Descendre d\'un cran';

  @override
  String get popupPickDeviceTitle => 'Sélection des équipements';

  @override
  String get popupPickPlanningTitle => 'Sélection d\'un planning';

  @override
  String get popupPickColorTitle => 'Sélection de la couleur';

  @override
  String get popupErrorTitle => 'Erreur';

  @override
  String get popupWarningTitle => 'Attention';

  @override
  String get popupWaitingConnection => 'Connexion en cours ...';

  @override
  String get popupNoMQTTParameters =>
      'Veuillez renseigner les paramètres de connexion au serveur dans l\'onglet des paramètres';

  @override
  String get popupNoDevices =>
      'Veuillez ajouter des vannes dans les paramètres';

  @override
  String removeConfirmation(String item, String name) {
    String _temp0 = intl.Intl.selectLogic(
      item,
      {
        'eqpt': 'l\'équipement',
        'schedule': 'le planning',
        'tempset': 'le jeu',
        'subschedule': 'ce sous-planning',
        'timeslots': 'cette plage hebdomadaire',
        'other': '',
      },
    );
    return 'Etes-vous sûr de vouloir supprimer $_temp0 \'$name\' ?';
  }

  @override
  String get removeFortnightConfirmation =>
      'Etes-vous sûr de vouloir arrêter le mode quinzaine ? la semaine \'B\' sera supprimée.';

  @override
  String errorDuplicateKey(String key) {
    return 'Le nom \'$key\' existe déjà ...';
  }

  @override
  String errorDuplicateDevice(String key) {
    return 'La vanne \'$key\' est déjà présente dans un autre groupe de ce planning';
  }

  @override
  String get weekChipMonday => 'Lu';

  @override
  String get weekChipTuesday => 'Ma';

  @override
  String get weekChipWednesday => 'Me';

  @override
  String get weekChipThurday => 'Je';

  @override
  String get weekChipFriday => 'Ve';

  @override
  String get weekChipSaturday => 'Sa';

  @override
  String get weekChipSunday => 'Di';

  @override
  String get navbarHome => 'Accueil';

  @override
  String get navbarTempsets => 'Jeux de T°';

  @override
  String get navbarPlannings => 'Plannings';

  @override
  String get snackbarBackButton => 'Appuyez une 2ième fois pour sortir';

  @override
  String get msgInfoCode_mqttServerConnected => 'Connecté au serveur';

  @override
  String get msgInfoCode_mqttServerDisconnected => 'Déconnecté du serveur !';

  @override
  String get msgInfoCode_mqttMessageError =>
      'Message défectueux reçu du serveur !';

  @override
  String get msgInfoCode_controlServerAvailable =>
      'Serveur de contrôle du chauffage disponible';

  @override
  String get msgInfoCode_controlServerUnavailable =>
      'Serveur de contrôle du chauffage injoignable !';

  @override
  String get srvResponseDialogTitle => 'Changement refusé';

  @override
  String get srvResponseRefused => 'Changement refusé !';

  @override
  String srvResponseDuplicateKey(String key) {
    return 'L\'identifiant \'$key\' est déjà utilisé !';
  }

  @override
  String get srvResponseEmptyList => 'La liste ne peut pas être vide !';

  @override
  String srvResponseBadValue(String value) {
    return 'La valeur \'$value\' n\'est pas autorisée !';
  }

  @override
  String srvResponseCircularRef(List<String> aliases) {
    return 'Une dépendance circulaire a été détectée entre les jeux de température suivants : $aliases';
  }

  @override
  String srvResponseMissingValue(String value) {
    return 'La valeur \'$value\' est manquante dans la liste !';
  }

  @override
  String get settingsPageTitle => 'Paramètres';

  @override
  String settingsAppVersion(String version) {
    return 'Version application : $version';
  }

  @override
  String settingsServerVersion(String version) {
    return 'Version serveur : $version';
  }

  @override
  String get settingsErrorMandatoryValue => 'Une valeur est obligatoire';

  @override
  String get settingsGroupServer => 'Paramètres du serveur';

  @override
  String get settingsGroupMain => 'Général';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsSystemLanguage => 'Système';

  @override
  String get settingsEditDevicesList => 'Editer la liste des vannes';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsThermostatRes => 'Résolution thermostats';

  @override
  String get settingsGroupManualReset => 'Gestion Consigne Manuelle (Vanne)';

  @override
  String get settingsManualResetMode => 'Mode de retour en mode auto';

  @override
  String get settingsManualResetDuration => 'Durée avant retour';

  @override
  String get settingsManualResetMode_Duration => 'Durée (heures)';

  @override
  String get settingsManualResetMode_TimeslotChange => 'Changement plage';

  @override
  String get settingsManualResetMode_SetPointChange => 'Changement consigne';

  @override
  String get settingsGroupMqtt => 'Paramètres de connexion MQTT';

  @override
  String get settingsBrokerAddress => 'Adresse broker';

  @override
  String get settingsUsername => 'Utilisateur';

  @override
  String get settingsPassword => 'Mot de passe';

  @override
  String get settingsPortNumber => 'Port (WebSocket)';

  @override
  String get settingsIsPortSecured => 'SSL';

  @override
  String get devicesEditorTitle => 'Liste des thermostats';

  @override
  String get devicesEditorEditTitle => 'Propriétés de l\'équipement';

  @override
  String get devicesEditorEditEntity => 'Entité';

  @override
  String get devicesEditorEditName => 'Nom';

  @override
  String get homePageTitle => 'Accueil';

  @override
  String get homePageNoActiveSchedule => 'Aucun planning actif';

  @override
  String get homePageActiveSchedule => 'Planning actif';

  @override
  String get tempSetsPageTitle => 'Jeux de T°';

  @override
  String get tempSetEditTitle => 'Propriétés du Jeu';

  @override
  String get tempSetEditName => 'Nom';

  @override
  String get tempSetEditNameHint => 'Nom du jeu';

  @override
  String get tempSetEditColor => 'Couleur';

  @override
  String get timeslotWeekA => 'A';

  @override
  String get timeslotWeekB => 'B';

  @override
  String get timeslotAddAfter => 'Ajouter dessous';

  @override
  String get timeslotSetEditTitle => 'Edition d\'une Plage hebdomadaire';

  @override
  String get schedulesPageTitle => 'Plannings';

  @override
  String get schedulesPageErrorMissingThermostatAndTempSet =>
      'Il faut commencer par ajouter un thermostat et créer un jeu de températures ...';

  @override
  String get schedulePageErrorBadParent =>
      'Le planning parent indiqué n\'existe pas !';

  @override
  String get scheduleEditTitle => 'Propriétés du planning';

  @override
  String get scheduleEditName => 'Nom';

  @override
  String get scheduleEditParent => 'Parent';

  @override
  String get scheduleEditNameHint => 'Nom du planning';

  @override
  String get scheduleParentPrefix => 'Hérite de';

  @override
  String get timeslotsFortnightSwitch => 'Quinzaine on/off';

  @override
  String get timeslotsErrorNotEmpty =>
      'Certains jours de la semaine sont encore affectés à cette plage hebdomadaire';
}
