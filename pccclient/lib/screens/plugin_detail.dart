import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:pccclient/screens/part/error.dart';
import 'package:pccclient/screens/part/tips.dart';
import 'package:pccclient/utils/plugins/buttons_widget.dart';
import 'package:pccclient/utils/plugins/files.dart';
import 'package:pccclient/utils/plugins/status_widget.dart';

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
  Widget buttonsWidget = const Text("Loading...");

  bool initiated = false;

  Package? package;

  ActivePackageData? activePackageData;
  void Function(ActivePackageData)? activePackageDataListener;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (activePackageDataListener != null) {
      unsubscribeActivePackage(
          package!.getIdentifier(), activePackageDataListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (package == null) {
      Package package = ModalRoute.of(context)!.settings.arguments as Package;
      this.package = package;
      if (package.dir != null) {
        Future<PluginXml> xmlFuture =
            loadPluginXml(path.join(package.dir!, "plugin.xml"));
        xmlFuture.then((value) {
          setState(() {
            xmlWidget = _PluginXmlWidget(
              xml: value,
            );
            buttonsWidget = PluginButtonsWidget(
              plugin: package,
              xml: value,
            );
          });
        }, onError: (err, trace) {
          setState(() {
            xmlWidget = getErrorContent(err, trace);
            buttonsWidget = Container();
          });
        });
      } else {
        xmlWidget = Container();
        buttonsWidget = PluginButtonsWidget(
          plugin: package,
          xml: null,
        );
      }
      activePackageDataListener =
          (data) => setState(() => activePackageData = data);
      subscribeActivePackage(
        package.getIdentifier(),
        activePackageDataListener!,
      );
      activePackageData = package.getActiveData();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(PluginDetailScreen.screenName),
      ),
      bottomNavigationBar: getTipsBar(),
      body: ListView(
        children: [
          activePackageData != null
              ? PackageStatusRow(
                  package: activePackageData!, indent: 0, clickable: false)
              : Container(),
          _PluginDetailRow(str.plugin_detail_name, package!.name),
          _PluginDetailRow(
              str.plugin_detail_repository, package!.repositoryName),
          xmlWidget,
          buttonsWidget,
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
