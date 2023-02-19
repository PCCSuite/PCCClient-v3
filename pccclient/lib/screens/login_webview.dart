import 'package:flutter/material.dart';
import 'part/tips.dart';

import 'loggingin.dart';

class LoginWebviewScreen extends StatefulWidget {
  const LoginWebviewScreen({Key? key}) : super(key: key);

  static const routeName = "/login_webview";

  static const screenName = "Login in WebView";

  @override
  State<LoginWebviewScreen> createState() => _LoginWebviewScreenState();
}

class _LoginWebviewScreenState extends State<LoginWebviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(LoginWebviewScreen.screenName),
        ),
        bottomNavigationBar: getTipsBar(),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, LoggingInScreen.routeName);
            },
            child: Text("Login"),
          ),
        ));
  }
}
