import 'package:flutter/material.dart';
import 'package:pccclient/screens/debug.dart';
import 'package:pccclient/screens/first.dart';
import 'package:pccclient/screens/home.dart';
import 'package:pccclient/screens/loggingin.dart';
import 'package:pccclient/screens/login_app.dart';
import 'package:pccclient/screens/login_browser.dart';
import 'package:pccclient/screens/login_select.dart';
import 'package:pccclient/screens/login_webview.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pccclient/screens/plugin_detail.dart';
import 'package:pccclient/screens/plugin_manage.dart';

const version = "3.0.0-alpha.2";

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
      theme: ThemeData.dark(),
      initialRoute: InitialScreen.routeName,
      routes: {
        InitialScreen.routeName: (context) => const InitialScreen(),
        LoginSelectScreen.routeName: (context) => const LoginSelectScreen(),
        LoginBrowserScreen.routeName: (context) => const LoginBrowserScreen(),
        LoginWebviewScreen.routeName: (context) => const LoginWebviewScreen(),
        LoginAppScreen.routeName: (context) => const LoginAppScreen(),
        LoggingInScreen.routeName: (context) => const LoggingInScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        PluginManageScreen.routeName: (context) => const PluginManageScreen(),
        PluginDetailScreen.routeName: (context) => const PluginDetailScreen(),
        DebugScreen.routeName: (context) => const DebugScreen(),
      },
    );
  }
}
