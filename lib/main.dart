/// Entry point for the app.
/// This file defines the root widget.
///
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause
library;

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heating_control_app/widgets/homepage/deviceseditorpage.dart';
import 'package:heating_control_app/widgets/homepage/themeseditorpage.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';

import 'common/common.dart';
import 'common/theme.dart';
import 'common/themenotifier.dart';
import 'common/model_ctrl.dart';
import 'common/settings.dart';
import 'utils/package.dart';
import 'utils/localizations.dart';
import 'widgets/homepage/homepage.dart';
import 'widgets/homepage/settingspage.dart';
import 'widgets/schedule/schedulespage.dart';
import 'widgets/temperatureset/temperaturesetspage.dart';
import 'widgets/timeslotset/timeslotsetpage.dart';

Future<void> main() async {
  // Right before doing any loading
  WidgetsFlutterBinding.ensureInitialized();
  await Package().init();
  await Settings().loadConfigFile();

  /*Map test = AppTheme().saveToMap();
  YamlWriter writer = YamlWriter();
  String serialized = writer.write(test);*/

  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key})
      : modelCtrl = ModelCtrl() {
        setLocale(Settings().locale);
      }

  final ModelCtrl modelCtrl;
  static Locale ?_locale;

  static void setLocale(Locale? locale) {
    _locale = locale;
  }

  static ThemeData getAppThemeData() {
    return ThemeData(
      dividerColor: AppTheme().focusColor, // Settings page dividers
      disabledColor: AppTheme().specialTextColor, // Disabled control text color
      dividerTheme: const DividerThemeData(
        color: Colors.transparent, // ugly divider that cuts off the selection in scroll picker (settings page)
      ),
      colorScheme: ColorScheme.dark(
        secondary: AppTheme().focusColor, // Settings page selected item in list picker
        onSurface: AppTheme().specialTextColor, // Used for disabled text (with opacity of 0.38)
        ),
      primaryColor: AppTheme().background3Color,
      secondaryHeaderColor: AppTheme().background3Color, // Settings page headers background
      cardColor: AppTheme().background2Color,
      scaffoldBackgroundColor: AppTheme().background1Color,
      unselectedWidgetColor: AppTheme().specialTextColor,
      // Color visible during transition between pages
      canvasColor: AppTheme().background1Color,
      iconTheme: IconThemeData(color: AppTheme().specialTextColor),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppTheme().background2Color,
        indicatorColor: AppTheme().background2Color,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.bold : FontWeight.normal,
          color: states.contains(WidgetState.selected) ? AppTheme().focusColor : AppTheme().normalTextColor,
        )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? AppTheme().focusColor : AppTheme().normalTextColor,
        )),
      ),
      navigationRailTheme: NavigationRailThemeData(
        indicatorColor: AppTheme().background2Color,
        selectedLabelTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme().focusColor,
        ),
        selectedIconTheme: IconThemeData(color: AppTheme().focusColor),
        unselectedLabelTextStyle: TextStyle(color: AppTheme().normalTextColor),
        unselectedIconTheme: IconThemeData(color: AppTheme().normalTextColor),
      ),
      listTileTheme: ListTileThemeData(
        textColor: AppTheme().specialTextColor,
      ),
      cardTheme: CardTheme(
        color: AppTheme().background2Color, // Background for settings page widgets
      ).data,
      scrollbarTheme: ScrollbarThemeData(
        trackColor: WidgetStateProperty.all(AppTheme().normalTextColor),
        thumbColor: WidgetStateProperty.all(AppTheme().focusColor)
      ),
      chipTheme: const ChipThemeData(
        shape: StadiumBorder(),
        padding: EdgeInsets.all(0)
      ),

      switchTheme: SwitchThemeData(
        trackColor:  WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? AppTheme().focusColor : null)
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: AppTheme().appBarColor,
        foregroundColor: AppTheme().appBarTextColor,
        titleTextStyle: TextStyle(
          color: AppTheme().appBarTextColor,
          fontSize: 22,
          fontWeight: FontWeight.bold
        )
      ),

      dialogTheme: DialogTheme(
        backgroundColor: AppTheme().background2Color,
      ).data,

      buttonTheme: ButtonThemeData(
        buttonColor: AppTheme().focusColor,
      ),
      textButtonTheme: TextButtonThemeData(
        // Buttons shown in popups of Settings page
        style: ButtonStyle(
          backgroundColor:WidgetStatePropertyAll(AppTheme().focusColor),
          textStyle: WidgetStatePropertyAll(TextStyle(color:AppTheme().buttonTextColor))
        ),
      ),
      
      textTheme: TextTheme(
            bodyMedium: TextStyle(color: AppTheme().normalTextColor), // thermostat setpoint
            bodyLarge: TextStyle(color: AppTheme().normalTextColor), // TextFormField input text
            labelLarge: TextStyle(color: AppTheme().buttonTextColor), // button text
            titleMedium: TextStyle(color: AppTheme().normalTextColor), // input text
            titleLarge: TextStyle(color: AppTheme().normalTextColor), // card header text
          ).apply(
            bodyColor: AppTheme().normalTextColor,
            displayColor: AppTheme().normalTextColor,
            decorationColor: AppTheme().normalTextColor,
          ),
        
      primaryTextTheme: TextTheme(
        titleLarge: TextStyle(color: AppTheme().normalTextColor), // app header text
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppTheme().focusColor,
        selectionColor: AppTheme().focusColor,
        selectionHandleColor: AppTheme().focusColor,
      ),

      inputDecorationTheme: InputDecorationTheme( // Input text fields (TextFormField)
        labelStyle: TextStyle(color: AppTheme().specialTextColor), // style for labels
        iconColor: AppTheme().normalTextColor, // style 
        prefixIconColor: AppTheme().specialTextColor, // style for prefix icons
        suffixIconColor: AppTheme().specialTextColor, // style for suffix icons
        counterStyle: TextStyle(
          color: AppTheme().normalTextColor, // counter text style (max length) in TextFormField
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme().normalTextColor.withValues(alpha: 0.20)), // underline color for TextFormField
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme().normalTextColor), // underline color for TextFormField
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme().focusColor), // underline color for TextFormField
        ), // underline color for TextFormField
      ),

      menuTheme:MenuBarThemeData( // Menu theme (and DropDownMenu)
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(AppTheme().background1Color),
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    ModelCtrl().connect();

    return Consumer<ThemeNotifier>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'Heating Control App',
          theme: getAppThemeData(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: _locale,
          navigatorKey: getNavigatorKey(),
          home: const RootPage(),
        );
      },
    );
  }
}

///////////////////////////////////////////////////////////////////////////
// ROOT PAGE : root page, contains the nav bar
///////////////////////////////////////////////////////////////////////////
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with WidgetsBindingObserver {
  static const int _mobileBreakpoint = 600;
  static const int _extendedRailBreakpoint = 800;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];
  final List<int> _tabHistory = [];
  int _selectedIndex = 0;
  DateTime oldTime = DateTime.now();
  DateTime newTime = DateTime.now();

  void _onServerResponseEvent(Value<ServerResponse> args) {
    ServerResponse response = args.value;
    if (!response.status) {
      if (response.errorCode.isEmpty) {
        Common.showSnackBar(context, wcLocalizations().srvResponseRefused, backColor: AppTheme().errorColor, durationMs: 4000);
      } else {
        String text = response.genericDesc;
        switch (response.errorCode) {
          case 'DUPLICATE_UNIQUE_KEY':
            text = wcLocalizations().srvResponseDuplicateKey(response.errorMap['key']);
            break;
          case 'EMPTY_LIST':
            text = wcLocalizations().srvResponseEmptyList;
            break;
          case 'BAD_VALUE':
            text = wcLocalizations().srvResponseBadValue(response.errorMap['value']);
            break;
          case 'CIRCULAR_REF':
            text = wcLocalizations().srvResponseCircularRef(response.errorMap['aliases']);
            break;
          case 'MISSING_VALUE':
            text = wcLocalizations().srvResponseMissingValue(response.errorMap['value']);
            break;
        }
        Common.showWarningDialog(context, text, title: wcLocalizations().srvResponseDialogTitle, closeBtnOnly: true);
      }
    }
  }

  void _onMessageEvent(Value<MessageInfo> args) {
    MessageInfo message = args.value;
    Color backColor = AppTheme().errorColor;
    String msgText = message.text;
    bool refresh = false;
    int duration = 2000;
    switch (message.type) {
      case EMsgInfoType.info:
        backColor = AppTheme().successColor;
        break;
      case EMsgInfoType.warning:
        backColor = AppTheme().warningColor;
        break;
      case EMsgInfoType.error:
        backColor = AppTheme().errorColor;
        duration = 4000;
        break;
    }
    Color textColor = Common.contrastColor(backColor);
    switch (message.code) {
      case EMsgInfoCode.mqttServerConnected:
      case EMsgInfoCode.mqttServerDisconnected:
      case EMsgInfoCode.controlServerAvailable:
      case EMsgInfoCode.controlServerUnavailable:
        msgText = '';
        refresh = true;
        break;
      case EMsgInfoCode.mqttMessageError:
        msgText = wcLocalizations().msgInfoCode_mqttMessageError;
        break;
      default:
        break;
    }
    if (refresh) setState(() {});
    if (msgText.isNotEmpty) {
      Common.hideSnackBar(context);
      Common.showSnackBar(context, msgText, backColor: backColor, textColor: textColor, durationMs: duration);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ModelCtrl().onServerResponseEvent.subscribe(_onServerResponseEvent);
    ModelCtrl().onMessageEvent.subscribe(_onMessageEvent);
  }

  @override
  void dispose() {
    ModelCtrl().onServerResponseEvent.unsubscribe(_onServerResponseEvent);
    ModelCtrl().onMessageEvent.unsubscribe(_onMessageEvent);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      ModelCtrl().onAppActive();
    } else {
      ModelCtrl().onAppInactive();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Provider.of<ThemeNotifier>(context, listen: true);
    final isDesktop = size.width >= _mobileBreakpoint;
    final destinations = <NavigationDestination>[
      NavigationDestination(icon: const Icon(Icons.home), label: wcLocalizations().navbarHome),
      NavigationDestination(icon: const Icon(Icons.list), label: wcLocalizations().navbarTempsets),
      NavigationDestination(icon: const Icon(Icons.schedule), label: wcLocalizations().navbarPlannings),
    ];

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBackButton();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Row(
          children: [
            if (isDesktop)
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _selectTab,
                labelType: size.width >= _extendedRailBreakpoint
                    ? null
                    : NavigationRailLabelType.selected,
                extended: size.width >= _extendedRailBreakpoint,
                destinations: [
                  for (final destination in destinations)
                    NavigationRailDestination(
                      icon: destination.icon,
                      selectedIcon: destination.selectedIcon,
                      label: Text(destination.label),
                    ),
                ],
              ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildTabNavigator(0),
                  _buildTabNavigator(1),
                  _buildTabNavigator(2),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: isDesktop
            ? null
            : NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _selectTab,
                destinations: destinations,
              ),
      ),
    );
  }

  Widget _buildTabNavigator(int tabIndex) {
    final routes = <Map<String, WidgetBuilder>>[
      {
        HomePage.route: (_) => const HomePage(),
        SettingsPage.route: (_) => const SettingsPage(),
        DevicesEditorPage.route: (_) => const DevicesEditorPage(),
        ThemesEditorPage.route: (_) => const ThemesEditorPage(),
      },
      {TemperatureSetsPage.route: (_) => const TemperatureSetsPage()},
      {
        SchedulesPage.route: (_) => const SchedulesPage(),
        TimeSlotSetPage.route: (_) => const TimeSlotSetPage(),
      },
    ][tabIndex];

    return Navigator(
      key: _navigatorKeys[tabIndex],
      onGenerateRoute: (settings) {
        final builder = routes[settings.name];
        return MaterialPageRoute<void>(
          settings: settings,
          builder: builder ?? (_) => const Scaffold(
            body: Center(child: Text('Route introuvable')),
          ),
        );
      },
    );
  }

  void _selectTab(int index) {
    if (index == _selectedIndex) return;
    _tabHistory.add(_selectedIndex);
    setState(() => _selectedIndex = index);
  }

  void _handleBackButton() {
    final navigator = _navigatorKeys[_selectedIndex].currentState;
    if (navigator?.canPop() ?? false) {
      navigator!.pop();
      return;
    }
    if (_tabHistory.isNotEmpty) {
      setState(() => _selectedIndex = _tabHistory.removeLast());
      return;
    }

    newTime = DateTime.now();
    final difference = newTime.difference(oldTime).inMilliseconds;
    oldTime = newTime;
    if (difference < 1000) {
      Common.hideSnackBar(context);
      SystemNavigator.pop();
    } else {
      Common.showSnackBar(context, wcLocalizations().snackbarBackButton);
    }
  }
}
