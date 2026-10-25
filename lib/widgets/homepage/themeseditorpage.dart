import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:provider/provider.dart';

import '../../common/common.dart';
import '../../common/settings.dart';
import '../../common/theme.dart';
import '../../common/themenotifier.dart';
import '../../utils/localizations.dart';
import '../../utils/settings_widget_helper.dart';

class ThemesEditorPage extends StatefulWidget {
  const ThemesEditorPage({super.key});

  static const String route = '/themes';

  @override
  State<ThemesEditorPage> createState() => _ThemesEditorPageState();
}

class _ThemesEditorPageState extends State<ThemesEditorPage> {
  static const List<String> _colorNames = [
    'appBarColor',
    'appBarTextColor',
    'background1Color',
    'background2Color',
    'background3Color',
    'normalTextColor',
    'specialTextColor',
    'focusColor',
    'buttonTextColor',
    'warningColor',
    'errorColor',
    'successColor',
    'heaterWidgetTrackColor',
    'heaterWidgetNoScheduleStateColor',
    'heaterWidgetAutoStateColor',
    'heaterWidgetManuelStateColor',
    'heaterWidgetPendingStateColor',
    'heaterWidgetTitleColor',
  ];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _newThemeNameController = TextEditingController();
  Size size = Size.zero;
  String? _selectedThemeName;
  late ThemeNotifier _themeNotifier;

  List<String> get _themes => Settings().getThemesList();

  @override
  void initState() {
    super.initState();
    final themes = _themes;
    _selectedThemeName = themes.contains(Settings().themeName)
        ? Settings().themeName
        : (themes.isEmpty ? null : themes.first);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = MediaQuery.of(context).size;
    if (size.width < 600) {
      _scrollController.addListener(_handleScroll);
    }
  }

  void _handleScroll() {
    if (size.width > 600 || !_scrollController.hasClients) return;
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (NavbarNotifier.isNavbarHidden) {
        NavbarNotifier.hideBottomNavBar = false;
      }
    } else if (!NavbarNotifier.isNavbarHidden) {
      NavbarNotifier.hideBottomNavBar = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _newThemeNameController.dispose();
    super.dispose();
  }

  Future<void> _createTheme() async {
    final name = _newThemeNameController.text.trim();
    if (name.isEmpty) return;
    if (!Settings().createTheme(name, templateName: _selectedThemeName)) {
      await Common.showWarningDialog(
        context,
        wcLocalizations().errorDuplicateKey(name),
        closeBtnOnly: true,
      );
      return;
    }
    setState(() {
      _selectedThemeName = name;
      _newThemeNameController.clear();
    });
  }

  Future<void> _deleteSelectedTheme() async {
    final name = _selectedThemeName;
    if (name == null || _themes.length <= 1) return;
    final confirmed = await Common.showWarningDialog(
      context,
      wcLocalizations().themesEditorDeleteConfirmation(name),
    );
    if (!confirmed || !mounted) return;

    Settings().deleteTheme(name);
    setState(() {
      final themes = _themes;
      _selectedThemeName = themes.contains(Settings().themeName)
          ? Settings().themeName
          : (themes.isEmpty ? null : themes.first);
    });
    _themeNotifier.refreshAppTheme();
  }

  Future<void> _editColor(String colorName, Color currentColor) async {
    final themeName = _selectedThemeName;
    if (themeName == null) return;
    final color = await Common.showColorPicker(context, currentColor);
    if (!mounted) return;
    if (Settings().updateThemeColor(themeName, colorName, color)) {
      setState(() {});
      if (Settings().themeName == themeName) {
        _themeNotifier.refreshAppTheme();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    final selectedTheme = _selectedThemeName == null
        ? null
        : Settings().getThemeData(_selectedThemeName!);

    return Scaffold(
      appBar: Common.createAppBar(wcLocalizations().settingsEditThemes),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: Common.getNavbarHeightPadding(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newThemeNameController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _createTheme(),
                      decoration: InputDecoration(
                        labelText: wcLocalizations().settingsTheme,
                        hintText: wcLocalizations().new_,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Common.createCircleIconButton(Icons.add, onPressed: _createTheme),
                ],
              ),
            ),
            const SizedBox(height: 20,),
            Divider(
              height: 15,
              thickness: 4,
              indent: 10,
              endIndent: 10,
              color: AppTheme().background3Color,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: SettingsWidgetHelper.createListPickerField(
                        wcLocalizations().settingsTheme,
                        _themes,
                        _selectedThemeName,
                        (value) => setState(() => _selectedThemeName = value),
                        enabled: _themes.isNotEmpty,
                      ),
                  ),
                  const SizedBox(width: 8),
                  Common.createCircleIconButton(
                    Icons.delete_outline,
                    onPressed: () => {
                      if (selectedTheme != null && _themes.length > 1) {
                        _deleteSelectedTheme()
                      }
                    }
                  ),
                ]
              ),
            ),

            if (selectedTheme != null)
              ..._colorNames.map((name) {
                final colorValue = selectedTheme[name] as String? ?? '';
                final color = AppTheme.string2Color(colorValue);
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  child: ListTile(
                    title: Text(_displayColorName(name)),
                    leading: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(color: AppTheme().specialTextColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    trailing: IconButton(
                      tooltip: wcLocalizations().popupPickColorTitle,
                      icon: Icon(Icons.colorize, color: AppTheme().focusColor),
                      onPressed: () => _editColor(name, color),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _displayColorName(String name) {
    final words = name
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)!}')
        .replaceFirst(' Color', '')
        .trim();
    return words[0].toUpperCase() + words.substring(1);
  }
}
