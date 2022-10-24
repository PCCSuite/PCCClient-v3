import 'package:flutter/material.dart';
import 'package:pccclient/utils/general.dart';
import 'package:pccclient/utils/plugins/files.dart';

class PluginConfigScreenArgument {
  final bool ask;
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

  @override
  Widget build(BuildContext context) {
    argument ??= ModalRoute.of(context)!.settings.arguments as PluginConfigScreenArgument;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !argument!.ask,
        title: Text(str.plugin_config_title),
      ),
      body: Form(
        child: ListView(
          children: argument!.xml.config.map((e) => _ConfigRow()).toList(),
        ),
      ),
    );
  }
}

class _ConfigRow extends StatefulWidget {
  const _ConfigRow({Key? key}) : super(key: key);

  @override
  State<_ConfigRow> createState() => _ConfigRowState();
}

class _ConfigRowState extends State<_ConfigRow> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Row"),
      ],
    );
  }
}
