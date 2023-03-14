import 'package:flutter/material.dart';
import '../utils/auth.dart';
import '../utils/user_settings.dart';
import 'login_app.dart';
import 'login_webview.dart';
import 'part/tips.dart';
import '../utils/server_info.dart';

import '../utils/general.dart';
import 'login_browser.dart';

class LoginSelectScreen extends StatefulWidget {
  const LoginSelectScreen({Key? key}) : super(key: key);

  static const routeName = "/login";

  @override
  State<LoginSelectScreen> createState() => _LoginSelectScreenState();
}

class _LoginSelectScreenState extends State<LoginSelectScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      switch (userSettings.loginMethod) {
        case LoginMethod.browser:
          Navigator.pushNamed(context, LoginBrowserScreen.routeName);
          return;
        case LoginMethod.webview:
          Navigator.pushNamed(context, LoginWebviewScreen.routeName);
          return;
        case LoginMethod.internal:
          Navigator.pushNamed(context, LoginInternalScreen.routeName);
          return;
        case null:
          break;
      }
      switch (serverInfo.defaultLoginMethod) {
        case LoginMethod.browser:
          Navigator.pushNamed(context, LoginBrowserScreen.routeName);
          return;
        case LoginMethod.webview:
          Navigator.pushNamed(context, LoginWebviewScreen.routeName);
          return;
        case LoginMethod.internal:
          Navigator.pushNamed(context, LoginInternalScreen.routeName);
          return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(str.login_select_title),
      ),
      bottomNavigationBar: getTipsBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        str.login_browser_title,
                        textScaleFactor: 2.0,
                      )),
                  onPressed: () {
                    Navigator.pushNamed(context, LoginBrowserScreen.routeName);
                  },
                ),
                // ElevatedButton(
                //   child: const Padding(
                //       padding: EdgeInsets.all(16.0),
                //       child: Text(
                //         "Login in WebView",
                //         textScaleFactor: 2.0,
                //       )),
                //   onPressed: () {
                //     Navigator.pushNamed(context, LoginWebviewScreen.routeName);
                //   },
                // ),
                ElevatedButton(
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        LoginInternalScreen.screenName,
                        textScaleFactor: 2.0,
                      )),
                  onPressed: () {
                    Navigator.pushNamed(context, LoginInternalScreen.routeName);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
