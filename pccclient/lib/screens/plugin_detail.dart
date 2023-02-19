import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'part/error.dart';
import 'part/tips.dart';
import 'plugin_add.dart';
import 'plugin_config.dart';
import '../utils/plugins/command.dart';
import '../utils/plugins/files.dart';
import '../utils/plugins/status_widget.dart';

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

class PluginButtonsWidget extends StatefulWidget {
  const PluginButtonsWidget({Key? key, required this.plugin, required this.xml})
      : super(key: key);

  final Package plugin;
  final PluginXml? xml;

  @override
  State<PluginButtonsWidget> createState() => PluginButtonsWidgetState();
}

class PluginButtonsWidgetState extends State<PluginButtonsWidget> {
  @override
  void initState() {
    listener = (ActivePackageData data) {
      setState(() {
        activePlugin = data;
      });
    };
    subscribeActivePackage(widget.plugin.getIdentifier(), listener);
    activePlugin = ActivePackageData.findByName(widget.plugin.name);
    dataDir.exists().then((value) => setState(() => dataExists = value));
    super.initState();
  }

  @override
  void dispose() {
    unsubscribeActivePackage(widget.plugin.getIdentifier(), listener);
    super.dispose();
  }

  late void Function(ActivePackageData) listener;

  void updateList(List<ActivePackageData> newData) {}

  ActivePackageData? activePlugin;

  late final Directory dataDir =
      Directory(path.join(pluginSysConfig.dataDir, widget.plugin.name));

  bool dataExists = false;

  @override
  Widget build(BuildContext context) {
    List<ListTile> buttons = [];
    buttons.add(ListTile(
      title: Text(str.plugin_button_header_manage),
      dense: true,
    ));
    if (activePlugin?.isInstalledOrInstalling() != true) {
      buttons.add(
        ListTile(
          title: Text(str.plugin_button_install),
          onTap: () => showPluginAddDialog(
              context,
              PluginAddInfo(
                  identifier: widget.plugin.getIdentifier(), install: true)),
        ),
      );
    } else if (activePlugin?.isRunning() == true) {
      buttons.add(
        ListTile(
          title: Text(str.plugin_button_stop_action),
          onTap: () => cancelActionCommand(activePlugin!.identifier),
        ),
      );
    }
    buttons.add(
      ListTile(
        title: Text(str.plugin_button_favorite),
        onTap: () => showPluginAddDialog(
            context, PluginAddInfo(identifier: widget.plugin.getIdentifier())),
      ),
    );
    if (dataExists) {
      if (widget.xml != null && widget.xml!.config.isNotEmpty) {
        buttons.add(
          ListTile(
            title: Text(str.plugin_button_config),
            onTap: () => Navigator.of(context).pushNamed(
                PluginConfigScreen.routeName,
                arguments: PluginConfigScreenArgument(null, widget.xml!)),
          ),
        );
      }
      buttons.add(
        ListTile(
          title: Text(str.plugin_button_clean),
          onTap: () async {
            bool? confirm = await showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => AlertDialog(
                      title: Text(str.plugin_button_clean),
                      content: Text(str.plugin_button_clean_description),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(str.plugin_button_clean_cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            str.plugin_button_clean_confirm,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ));
            if (confirm == true) {
              await dataDir.delete(recursive: true);
              setState(() {
                dataDir
                    .exists()
                    .then((value) => setState(() => dataExists = value));
              });
            }
          },
        ),
      );
    }
    if (activePlugin?.installed == true &&
        !activePlugin!.isRunning() &&
        widget.xml != null &&
        widget.xml!.buttons.isNotEmpty) {
      buttons.add(ListTile(
        title: Text(str.plugin_button_header_defined),
        dense: true,
      ));
      for (var btnData in widget.xml!.buttons) {
        buttons.add(
          ListTile(
            title: Text(btnData.name),
            onTap: () {
              startPluginActionCommand(activePlugin!.name, btnData.action);
            },
          ),
        );
      }
    }
    return Column(
      children: buttons,
    );
  }
}
