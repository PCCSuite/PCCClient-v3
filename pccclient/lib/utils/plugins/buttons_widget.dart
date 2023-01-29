import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pccclient/screens/plugin_add.dart';
import 'package:pccclient/screens/plugin_config.dart';
import 'package:pccclient/utils/general.dart';
import 'package:pccclient/utils/plugins/command.dart';
import 'package:pccclient/utils/plugins/datas.dart';
import 'package:pccclient/utils/plugins/files.dart';

import 'package:path/path.dart' as path;
import 'package:pccclient/utils/plugins/status_enum.dart';

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
    Future.delayed(Duration.zero, () => updateList(activePlugins));
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
              startPluginActionCommand(
                  activePlugin!.identifier, btnData.action);
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
