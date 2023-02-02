/// Entry point for the app.
/// This file defines the root widget.
///
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause

import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'common/common.dart';
import 'common/theme.dart';
import 'widgets/homepage/homepage.dart';
import 'common/model_ctrl.dart';
import 'common/settings.dart';
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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key})
      : modelCtrl = ModelCtrl(),
        super(key: key);

  final ModelCtrl modelCtrl;

  @override
  Widget build(BuildContext context) {
    ModelCtrl().connect();
    NavbarNotifier.hideBottomNavBar = false;
    return MaterialApp(
        title: 'Heating Control App',
        theme: ThemeData(
          // Color visible during transition between pages
          canvasColor: AppTheme().background1Color,
          appBarTheme: AppBarTheme(
            color: AppTheme().appBarColor,
          ),
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: AppTheme().normalTextColor,
                displayColor: AppTheme().normalTextColor,
                decorationColor: AppTheme().normalTextColor,
              ),
          scaffoldBackgroundColor: AppTheme().background1Color,
          unselectedWidgetColor: AppTheme().specialTextColor,
        ),
        home: const RootPage());
  }
}

///////////////////////////////////////////////////////////////////////////
// ROOT PAGE : root page, contains the nav bar
///////////////////////////////////////////////////////////////////////////
class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  List<NavbarItem> items = [
    NavbarItem(Icons.home, 'Général', backgroundColor: AppTheme().background2Color),
    NavbarItem(Icons.list, 'Jeux de T°', backgroundColor: AppTheme().background2Color),
    NavbarItem(Icons.schedule, 'Plannings', backgroundColor: AppTheme().background2Color),
  ];

  final Map<int, Map<String, Widget>> _routes = const {
    0: {
      '/': HomePage(),
    },
    1: {
      '/': TemperatureSetsPage(),
    },
    2: {
      '/': SchedulesPage(),
      TimeSlotSetPage.route: TimeSlotSetPage(),
    },
  };

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
        errorBuilder: (context) {
          return const Center(child: Text('Error 404'));
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
            selectedLabelTextStyle: TextStyle(fontWeight: FontWeight.bold, color: AppTheme().focusColor),
            unselectedLabelTextStyle: TextStyle(color: AppTheme().normalTextColor),
            selectedIconTheme: IconThemeData(color: AppTheme().focusColor),
            unselectedIconTheme: IconThemeData(color: AppTheme().normalTextColor),
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
                for (int j = 0; j < _routes[i]!.keys.length; j++)
                  Destination(
                    route: _routes[i]!.keys.elementAt(j),
                    widget: _routes[i]!.values.elementAt(j),
                  ),
              ],
              initialRoute: _routes[i]!.keys.first,
            ),
        ],
      ),
    );
  }
}
