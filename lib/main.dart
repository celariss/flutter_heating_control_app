/// Entry point for the app.
/// This file defines the root widget.
///
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause
library;

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:heating_control_app/widgets/homepage/deviceseditorpage.dart';
import 'package:navbar_router/navbar_router.dart';
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

  @override
  Widget build(BuildContext context) {
    ModelCtrl().connect();
    NavbarNotifier.hideBottomNavBar = false;

    return Consumer<ThemeNotifier>(
      builder: (context, appState, child) {
        return MaterialApp(
        title: 'Heating Control App',
        theme: ThemeData(
          dividerColor: AppTheme().focusColor, // Settings page dividers
          dividerTheme: const DividerThemeData(
            color: Colors.transparent, // ugly divider that cuts off the selection in scroll picker (settings page)
          ),
          colorScheme: ColorScheme.dark(secondary: AppTheme().focusColor,  // Settings page selected item in list picker
            ),
          primaryColor: AppTheme().background3Color,
          secondaryHeaderColor: AppTheme().background3Color, // Settings page headers background
          cardColor: AppTheme().background2Color,
          scaffoldBackgroundColor: AppTheme().background1Color,
          unselectedWidgetColor: AppTheme().specialTextColor,
          // Color visible during transition between pages
          canvasColor: AppTheme().background1Color,
          iconTheme: IconThemeData(color: AppTheme().specialTextColor),
          navigationRailTheme: NavigationRailThemeData(
            unselectedLabelTextStyle: TextStyle(
              color: AppTheme().normalTextColor
              ),
            unselectedIconTheme: IconThemeData(
              color: AppTheme().normalTextColor
            )
          ),
          /*bottomNavigationBarTheme: BottomNavigationBarThemeData(
            unselectedItemColor: AppTheme().normalTextColor,
            unselectedLabelStyle: TextStyle(
              color: AppTheme().normalTextColor)
          ),
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return TextStyle(
                color: AppTheme().focusColor,
              );
            }
            return TextStyle(
                color: AppTheme().normalTextColor,
            );
          }),
          ),*/
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
            foregroundColor: AppTheme().normalTextColor,
          ),

          dialogTheme: DialogTheme(
            backgroundColor: AppTheme().background2Color,
          ).data,

          buttonTheme: ButtonThemeData(
            buttonColor: AppTheme().buttonBackColor,
          ),
          textButtonTheme: TextButtonThemeData(
            // Buttons shown in popups of Settings page
            style: ButtonStyle(
              backgroundColor:WidgetStatePropertyAll(AppTheme().buttonBackColor),
              textStyle: WidgetStatePropertyAll(TextStyle(color:AppTheme().buttonTextColor))
            ),
          ),
          
          textTheme: TextTheme(
                bodyMedium: TextStyle(color: AppTheme().normalTextColor), // thermostat setpoint
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

          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: AppTheme().specialTextColor), // style for labels
          ),
        ),

        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: _locale,
        navigatorKey: getNavigatorKey(),
        home: const RootPage());
      }
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
  Map<int, Map<String, Widget>> routes = {
    0: {
      '/': const HomePage(),
      SettingsPage.route: const SettingsPage(),
      DevicesEditorPage.route: const DevicesEditorPage(),
    },
    1: {
      '/': const TemperatureSetsPage(),
    },
    2: {
      '/': const SchedulesPage(),
      TimeSlotSetPage.route: const TimeSlotSetPage(),
    },
  };

  ThemeNotifier ?themeNotifier;
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
        //msgText = wcLocalizations().msgInfoCode_mqttServerConnected;
        msgText = "";
        refresh = true;
        break;
      case EMsgInfoCode.mqttServerDisconnected:
        //msgText = wcLocalizations().msgInfoCode_mqttServerDisconnected;
        msgText = "";
        refresh = true;
        break;
      case EMsgInfoCode.mqttMessageError:
        msgText = wcLocalizations().msgInfoCode_mqttMessageError;
        break;
      case EMsgInfoCode.controlServerAvailable:
        //msgText = wcLocalizations().msgInfoCode_controlServerAvailable;
        msgText = "";
        refresh = true;
        break;
      case EMsgInfoCode.controlServerUnavailable:
        //msgText = wcLocalizations().msgInfoCode_controlServerUnavailable;
        msgText = "";
        refresh = true;
        break;
      default:
        break;
    }
    if (refresh) {
      setState(() {});
    }
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
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state==AppLifecycleState.resumed) {
      ModelCtrl().onAppActive();
    }
    else {
      ModelCtrl().onAppInactive();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // We need this line with listen:true to ensure refresh of NavBarRouter when current theme changes
    themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    List<NavbarItem> items = [
        NavbarItem(Icons.home, wcLocalizations().navbarHome, backgroundColor: AppTheme().background2Color),
        NavbarItem(Icons.list, wcLocalizations().navbarTempsets, backgroundColor: AppTheme().background2Color),
        NavbarItem(Icons.schedule, wcLocalizations().navbarPlannings, backgroundColor: AppTheme().background2Color),
      ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      /*floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Common.createFloatingButton(
        size: 30,
        icon: Icon(NavbarNotifier.isNavbarHidden ? Icons.toggle_off : Icons.toggle_on),
        onPressed: () {
          // Programmatically toggle the Navbar visibility
          if (NavbarNotifier.isNavbarHidden) {
            NavbarNotifier.hideBottomNavBar = false;
          } else {
            NavbarNotifier.hideBottomNavBar = true;
          }
          setState(() {});
        },
      ),*/
      body: NavbarRouter(
        type: NavbarType.standard,
        errorBuilder: (context) {
          return const Center(child: Text('NavBarRouter Error : unknown route'));
        },
        isDesktop: size.width > 600 ? true : false,
        onBackButtonPressed: (isExitingApp) {
          if (isExitingApp) {
            newTime = DateTime.now();
            int difference = newTime.difference(oldTime).inMilliseconds;
            oldTime = newTime;
            if (difference < 1000) {
              Common.hideSnackBar(context);
              return isExitingApp;
            } else {
              Common.showSnackBar(context, wcLocalizations().snackbarBackButton);
              return false;
            }
          } else {
            return isExitingApp;
          }
        },
        destinationAnimationCurve: Curves.fastOutSlowIn,
        destinationAnimationDuration: 600,
        decoration: NavbarDecoration(
            showUnselectedLabels: true,
            backgroundColor: AppTheme().background2Color,
            indicatorColor: AppTheme().background2Color,
            selectedLabelTextStyle: TextStyle(fontWeight: FontWeight.bold, color: AppTheme().focusColor),
            selectedIconTheme: IconThemeData(color: AppTheme().focusColor),
            selectedIconColor: AppTheme().focusColor,
            unselectedLabelTextStyle: TextStyle(color: AppTheme().normalTextColor),
            unselectedIconTheme: IconThemeData(color: AppTheme().normalTextColor),
            unselectedLabelColor: AppTheme().normalTextColor,
            unselectedIconColor: AppTheme().normalTextColor,
            unselectedItemColor: AppTheme().normalTextColor,
            isExtended: size.width > 800 ? true : false,
            navbarType: BottomNavigationBarType.fixed),
        onChanged: (x) {},
        backButtonBehavior: BackButtonBehavior.rememberHistory,
        destinations: [
          for (int i = 0; i < items.length; i++)
            DestinationRouter(
              navbarItem: items[i],
              destinations: [
                for (int j = 0; j < routes[i]!.keys.length; j++)
                  Destination(
                    route: routes[i]!.keys.elementAt(j),
                    widget: routes[i]!.values.elementAt(j),
                  ),
              ],
              initialRoute: routes[i]!.keys.first,
            ),
        ],
      ),
    );
  }
}
