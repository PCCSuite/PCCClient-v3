import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:pccclient/screens/part/error.dart';
import 'package:pccclient/utils/plugins/files.dart';

import '../utils/general.dart';
import '../utils/plugins/datas.dart';

class PluginDetailScreen extends StatefulWidget {
  const PluginDetailScreen({Key? key}) : super(key: key);

  static const routeName = "/plugin/detail";

  static final screenName = str.plugin_detail_title;

  @override
  State<PluginDetailScreen> createState() => _PluginDetailScreenState();
}

class _PluginDetailScreenState extends State<PluginDetailScreen> {
  Widget xmlWidget = const Text("Loading...");

  bool initiated = false;

  Plugin? plugin;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (plugin == null) {
      Plugin plugin = ModalRoute.of(context)!.settings.arguments as Plugin;
      this.plugin = plugin;
      if (plugin.dir != null) {
        Future<PluginXml> xmlFuture =
            loadPluginXml(path.join(plugin.dir!, "plugin.xml"));
        xmlFuture.then((value) {
          setState(() {
            xmlWidget = _PluginXmlWidget(
              xml: value,
            );
          });
        }, onError: (err, trace) {
          setState(() {
            xmlWidget = getErrorContent(err, trace);
          });
        });
      } else {
        xmlWidget = Container();
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(PluginDetailScreen.screenName),
      ),
      body: ListView(
        children: [
          _PluginDetailRow(str.plugin_detail_name, plugin!.name),
          _PluginDetailRow(
              str.plugin_detail_repository, plugin!.repositoryName),
          xmlWidget,
        ],
      ),
    );
  }
}

class _PluginXmlWidget extends StatelessWidget {
  const _PluginXmlWidget({Key? key, required this.xml}) : super(key: key);

  final PluginXml xml;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PluginDetailRow(str.plugin_detail_version, xml.version),
        _PluginDetailRow(str.plugin_detail_description, xml.description),
        _PluginDetailRow(str.plugin_detail_author, xml.author),
        _PluginDetailRow(str.plugin_detail_licence, xml.licence),
        _PluginDetailRow(
            str.plugin_detail_dependency, xml.dependency.join(", ")),
      ],
    );
  }
}

class _PluginDetailRow extends StatelessWidget {
  const _PluginDetailRow(this.name, this.value, {Key? key}) : super(key: key);

  final String name;

  final String? value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 300,
          padding: const EdgeInsets.all(10.0),
          child: Text(
            name,
          ),
        ),
        Text(value != null ? value! : str.plugin_detail_unknown),
      ],
    );
  }
}
