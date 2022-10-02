import 'package:flutter/material.dart';
import 'package:pccclient/screens/part/error.dart';
import 'package:pccclient/utils/auth.dart';
import 'package:pccclient/utils/plugins/start.dart';

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
      body: const _DebugMenu(),
    );
  }
}

class _DebugMenu extends StatefulWidget {
  const _DebugMenu({Key? key}) : super(key: key);

  @override
  State<_DebugMenu> createState() => _DebugMenuState();
}

class _DebugMenuState extends State<_DebugMenu> {
  String result = "none";

  @override
  Widget build(BuildContext context) {
    return Row(
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
        ),
        Text(result),
        ElevatedButton(
          onPressed: () {
            setState(() {
              result = "start";
            });
            var future = startPluginSys();
            future.then((value) {
              setState(() {
                result = "done";
              });
            });
            future.catchError((err, trace) {
              showError(context, err, trace);
            });
          },
          child: const Text("Start PluginSys"),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              result = "start";
            });
            var future = () async {
              return pluginSysProcess!.kill();
            }();
            future.then((value) {
              setState(() {
                result = value;
              });
            });
            future.catchError((err, trace) {
              showError(context, err, trace);
            });
          },
          child: const Text("Stop PluginSys"),
        ),
      ],
    );
  }
}
