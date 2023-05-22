import 'package:flutter/material.dart';
import 'screens/debug.dart';
import 'screens/first.dart';
import 'screens/home.dart';
import 'screens/loggingin.dart';
import 'screens/login_internal.dart';
import 'screens/login_browser.dart';
import 'screens/login_select.dart';
import 'screens/login_webview.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'screens/plugin_config.dart';
import 'screens/plugin_detail.dart';
import 'screens/plugin_manage.dart';
import 'screens/samba.dart';
import 'screens/settings.dart';

const version = "3.0.1-beta.2";

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PCCClient v$version',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData.dark().copyWith(
        scrollbarTheme: ScrollbarThemeData(
          thumbVisibility: MaterialStateProperty.all(true),
        ),
      ),
      initialRoute: InitialScreen.routeName,
      routes: {
        InitialScreen.routeName: (context) => const InitialScreen(),
        LoginSelectScreen.routeName: (context) => const LoginSelectScreen(),
        LoginBrowserScreen.routeName: (context) => const LoginBrowserScreen(),
        LoginWebviewScreen.routeName: (context) => const LoginWebviewScreen(),
        LoginInternalScreen.routeName: (context) => const LoginInternalScreen(),
        LoggingInScreen.routeName: (context) => const LoggingInScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        SambaScreen.routeName: (context) => const SambaScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
        PluginManageScreen.routeName: (context) => const PluginManageScreen(),
        PluginDetailScreen.routeName: (context) => const PluginDetailScreen(),
        PluginConfigScreen.routeName: (context) => const PluginConfigScreen(),
        DebugScreen.routeName: (context) => const DebugScreen(),
      },
    );
  }
}
