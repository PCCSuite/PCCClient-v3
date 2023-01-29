import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pccclient/screens/part/form_part.dart';
import 'package:pccclient/screens/part/tips.dart';
import 'package:pccclient/utils/general.dart';
import 'package:pccclient/utils/plugins/files.dart';

import 'package:path/path.dart' as path;

class PluginConfigScreenArgument {
  final String? ask;
  final PluginXml xml;

  PluginConfigScreenArgument(this.ask, this.xml);
}

class PluginConfigScreen extends StatefulWidget {
  const PluginConfigScreen({Key? key}) : super(key: key);

  static const routeName = "/plugin/config";

  @override
  State<PluginConfigScreen> createState() => _PluginConfigScreenState();
}

class _PluginConfigScreenState extends State<PluginConfigScreen> {
  bool initialized = false;

  Widget content = const Text("Loading...");

  @override
  void initState() {
    super.initState();
  }

  void loadConfig() async {
    PluginConfigScreenArgument argument = ModalRoute.of(context)!
        .settings
        .arguments as PluginConfigScreenArgument;

    Map<String, dynamic> store;

    File file = File(path.join(argument.xml.dataDir, "config.json"));
    if (await file.exists()) {
      String str = await file.readAsString();
      store = jsonDecode(str);
    } else {
      store = {};
    }
    List<Widget> children = [];
    children.addAll(argument.xml.config.map((e) => Container(
          padding: const EdgeInsets.all(16.0),
          child: formPartFromData(e, store),
        )));

    var formKey = GlobalKey<FormState>();

    children.add(
      Row(
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              argument.ask != null
                  ? str.plugin_ask_cancel
                  : str.plugin_config_cancel,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              formKey.currentState!.save();
              String str = jsonEncode(store);
              file.writeAsStringSync(str);
              Navigator.pop(context, true);
            },
            child: Text(
              argument.ask != null
                  ? str.plugin_ask_submit
                  : str.plugin_config_save,
            ),
          ),
        ],
      ),
    );

    setState(() {
      content = Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: argument.ask == null,
          title: Text(str.plugin_config_title),
        ),
        bottomNavigationBar: getTipsBar(),
        body: Form(
          key: formKey,
          child: ListView(
            children: children,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      initialized = true;
      loadConfig();
    }
    return content;
  }
}
