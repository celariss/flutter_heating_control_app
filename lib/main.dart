/// Entry point for the app.
/// This file defines the root widget.
///
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause

import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:provider/provider.dart';
import 'common/common.dart';
import 'common/theme.dart';
import 'common/themenotifier.dart';
import 'widgets/homepage/homepage.dart';
import 'common/model_ctrl.dart';
import 'common/settings.dart';
import 'widgets/homepage/settingspage.dart';
import 'widgets/schedule/schedulespage.dart';
import 'widgets/temperatureset/temperaturesetspage.dart';
import 'widgets/timeslotset/timeslotsetpage.dart';

Future<void> main() async {
  // Right before doing any loading
  WidgetsFlutterBinding.ensureInitialized();
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
      : modelCtrl = ModelCtrl();

  final ModelCtrl modelCtrl;

  @override
  Widget build(BuildContext context) {
    ModelCtrl().connect();
    NavbarNotifier.hideBottomNavBar = false;
    return Consumer<ThemeNotifier>(
      builder: (context, appState, child) {
        return MaterialApp(
        title: 'Heating Control App',
        theme: ThemeData(
          primaryColor: AppTheme().background3Color,
          secondaryHeaderColor: AppTheme().background3Color,
          cardColor: AppTheme().background2Color,
          scaffoldBackgroundColor: AppTheme().background1Color,
          unselectedWidgetColor: AppTheme().specialTextColor,
          // Color visible during transition between pages
          canvasColor: AppTheme().background1Color,
          dialogBackgroundColor: AppTheme().background2Color,
          
          appBarTheme: AppBarTheme(
            color: AppTheme().appBarColor,
          ),

          buttonTheme: ButtonThemeData(
            buttonColor: AppTheme().buttonBackColor,
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

class _RootPageState extends State<RootPage> {
  List<NavbarItem> items = [
    NavbarItem(Icons.home, 'Général', backgroundColor: AppTheme().background2Color),
    NavbarItem(Icons.list, 'Jeux de T°', backgroundColor: AppTheme().background2Color),
    NavbarItem(Icons.schedule, 'Plannings', backgroundColor: AppTheme().background2Color),
  ];

  Map<int, Map<String, Widget>> routes = {
    0: {
      '/': const HomePage(),
      SettingsPage.route: const SettingsPage(),
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

  void _onServerResponseEvent(args) {
    ServerResponse response = args!.value;
    if (!response.status) {
      if (response.errorCode.isEmpty) {
        Common.showSnackBar(context, 'Changement refusé !', backColor: AppTheme().errorColor, duration_ms: 4000);
      } else {
        String text = response.genericDesc;
        switch (response.errorCode) {
          case 'DUPLICATE_UNIQUE_KEY':
            text = "L'identifiant '${response.errorMap['key']}' est déjà utilisé !";
            break;
          case 'EMPTY_LIST':
            text = "La liste ne peut pas être vide !";
            break;
          case 'BAD_VALUE':
            text = "La valeur '${response.errorMap['value']}' n'est pas autorisée !";
            break;
          case 'CIRCULAR_REF':
            text =
                "Une dépendance circulaire a été détectée entre les jeux de température suivants : ${response.errorMap['aliases']}";
            break;
          case 'MISSING_VALUE':
            text = "La valeur '${response.errorMap['value']}' est manquante dans la liste !";
            break;
        }
        Common.showWarningDialog(context, text, title: 'Changement refusé', closeBtnOnly: true);
      }
    }
  }

  void _onMessageEvent(args) {
    MessageInfo message = args!.value;
    Color backColor = AppTheme().errorColor;
    String msgText = message.text;
    bool refresh = false;
    switch (message.type) {
      case EMsgInfoType.info:
        backColor = AppTheme().successColor;
        break;
      case EMsgInfoType.warning:
        backColor = AppTheme().warningColor;
        break;
      case EMsgInfoType.error:
        backColor = AppTheme().errorColor;
        break;
    }
    Color textColor = Common.contrastColor(backColor);
    switch (message.code) {
      case EMsgInfoCode.mqttServerConnected:
        msgText = 'Connecté au serveur';
        refresh = true;
        break;
      case EMsgInfoCode.mqttServerDisconnected:
        msgText = 'Déconnecté du serveur !';
        refresh = true;
        break;
      case EMsgInfoCode.mqttMessageError:
        msgText = 'Message défectueux reçu du serveur !';
        break;
      case EMsgInfoCode.controlServerUnavailable:
        msgText = 'Serveur de contrôle du chauffage injoignable !';
        break;
      default:
        break;
    }
    if (refresh) {
      setState(() {});
    }
    Common.showSnackBar(context, msgText, backColor: backColor, textColor: textColor, duration_ms: 4000);
  }

  @override
  void initState() {
    super.initState();
    ModelCtrl().onServerResponseEvent.subscribe(_onServerResponseEvent);
    ModelCtrl().onMessageEvent.subscribe(_onMessageEvent);
  }

  @override
  void dispose() {
    ModelCtrl().onServerResponseEvent.unsubscribe(_onServerResponseEvent);
    ModelCtrl().onMessageEvent.unsubscribe(_onMessageEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We need this line witrh listen:true to ensure refresh of NavBarRouter when current theme changes
    themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
      ),
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
              Common.showSnackBar(context, 'Appuyez une 2ième fois pour sortir');
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
