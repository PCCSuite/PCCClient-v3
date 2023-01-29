import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pccclient/screens/part/form_part.dart';
import 'package:pccclient/screens/part/tips.dart';
import 'package:pccclient/utils/general.dart';
import 'package:pccclient/utils/plugins/files.dart';

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
  PluginConfigScreenArgument? argument;

  bool initialized = false;

  Widget content = const Text("Loading...");

  @override
  void initState() {
    super.initState();
  }

  void loadConfig() async {
    argument ??= ModalRoute.of(context)!.settings.arguments
        as PluginConfigScreenArgument;

    Map<String, dynamic> store;

    File file = File(pluginSysConfig.pluginsList);
    if (await file.exists()) {
      String str = await file.readAsString();
      store = jsonDecode(str);
    } else {
      store = {};
    }
    List<Widget> children =
        argument!.xml.config.map((e) => formPartFromData(e, store)).toList();

    var formKey = GlobalKey<FormState>();

    children.add(
      Row(
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              str.plugin_ask_cancel,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              formKey.currentState!.save();
              Navigator.pop(context, true);
            },
            child: Text(
              str.plugin_ask_submit,
            ),
          ),
        ],
      ),
    );

    setState(() {
      content = Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: argument!.ask != null,
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
