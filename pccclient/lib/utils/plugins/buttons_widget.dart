import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pccclient/screens/plugin_add.dart';
import 'package:pccclient/screens/plugin_config.dart';
import 'package:pccclient/utils/general.dart';
import 'package:pccclient/utils/plugins/datas.dart';
import 'package:pccclient/utils/plugins/files.dart';

import 'package:path/path.dart' as path;

List<PluginButtonsWidgetState> pluginButtonsWidgets = [];

class PluginButtonsWidget extends StatefulWidget {
  const PluginButtonsWidget({Key? key, required this.plugin, required this.xml})
      : super(key: key);

  final Plugin plugin;
  final PluginXml? xml;

  @override
  State<PluginButtonsWidget> createState() => PluginButtonsWidgetState();
}

class PluginButtonsWidgetState extends State<PluginButtonsWidget> {
  @override
  void initState() {
    pluginButtonsWidgets.add(this);
    dataDir.exists().then((value) => setState(() => dataExists = value));
    super.initState();
  }

  @override
  void dispose() {
    pluginButtonsWidgets.remove(this);
    super.dispose();
  }

  void updateList(List<ActivePluginData> newData) {
    for (var data in newData) {
      if (data.name == widget.plugin.name) {
        setState(() {
          activePlugin = data;
        });
        break;
      }
    }
  }

  ActivePluginData? activePlugin;

  late final Directory dataDir =
      Directory(path.join(pluginSysConfig.dataDir, widget.plugin.name));
  bool dataExists = false;

  @override
  Widget build(BuildContext context) {
    List<ListTile> buttons = [];
    if (activePlugin?.isInstalledOrInstalling() != true) {
      buttons.add(
        ListTile(
          title: Text(str.plugin_button_install),
          onTap: () => showPluginAddDialog(
              context, PluginAddInfo(identifier: widget.plugin.identifier, install: true)),
        ),
      );
    }
    buttons.add(
      ListTile(
        title: Text(str.plugin_button_favorite),
        onTap: () =>
            showPluginAddDialog(context, PluginAddInfo(identifier: widget.plugin.identifier)),
      ),
    );
    if (dataExists) {
      if (widget.xml != null && widget.xml!.config.isNotEmpty) {
        buttons.add(
          ListTile(
            title: Text(str.plugin_button_config),
            onTap: () => Navigator.of(context).pushNamed(PluginConfigScreen.routeName, arguments: PluginConfigScreenArgument(false, widget.xml!)),
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
    return Column(
      children: buttons,
    );
  }
}
