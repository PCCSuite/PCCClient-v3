import 'package:flutter/material.dart';
import 'package:pccclient/utils/auth.dart';

import '../utils/general.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({Key? key}) : super(key: key);

  static const routeName = "/debug";

  static var screenName = str.debug_title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DebugScreen.screenName),
      ),
      body: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text("loginState"),
                  content: SelectableText(
                      "username: ${loginState.username}\naccessToken: ${loginState.accessToken}\nsambaPassword: ${loginState.sambaPassword}"),
                ),
              );
            },
            child: const Text("Show loginState"),
          )
        ],
      ),
    );
  }
}
