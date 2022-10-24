import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pccclient/utils/plugins/command.dart';
import 'package:pccclient/utils/plugins/datas.dart';
import 'package:pccclient/utils/plugins/list_file.dart';
import 'package:pccclient/utils/plugins/status_enum.dart';

import '../utils/general.dart';

class PluginAddInfo {
  String identifier;
  bool install;
  bool favorite;
  bool autoRestore;
  int priority;

  PluginAddInfo(
      {this.identifier = "",
      this.install = false,
      this.favorite = false,
      this.autoRestore = false,
      this.priority = 100});
}

class _PluginAddDialog extends StatefulWidget {
  const _PluginAddDialog(this.info, {Key? key}) : super(key: key);

  final PluginAddInfo info;

  @override
  State<_PluginAddDialog> createState() => _PluginAddDialogState();
}

class _PluginAddDialogState extends State<_PluginAddDialog> {
  _PluginAddDialogState();

  late final PluginAddInfo info = widget.info;

  bool _installed = false;

  Future<void> _checkPluginStatus() async {
    if (info.identifier.isNotEmpty) {
      try {
        installingAndInstalledPlugins.firstWhere(
            (element) => element.name == info.identifier.split(":").last);
        info.install = false;
        _installed = true;
      } on StateError catch (_) {
        _installed = false;
      }
      try {
        FavoritePlugin plugin = favoritePlugins
            .firstWhere((element) => element.name == info.identifier);
        info.favorite = true;
        info.autoRestore = plugin.enabled;
        info.priority = plugin.priority;
      } on StateError catch (_) {
        // if not in favorite
        info.favorite = false;
        info.autoRestore = false;
      }
    }
  }

  @override
  void initState() {
    _checkPluginStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(str.plugin_add_dialog_title),
      scrollable: true,
      content: Form(
          child: Column(
        children: [
          Focus(
            onFocusChange: (val) => _checkPluginStatus(),
            child: TextFormField(
              decoration: InputDecoration(
                  labelText: str.plugin_add_dialog_plugin_id,
                  hintText: "repository:name"),
              initialValue: info.identifier,
              onChanged: (val) => setState(() {
                info.identifier = val;
              }),
              onFieldSubmitted: (val) => _checkPluginStatus(),
              onEditingComplete: () => _checkPluginStatus(),
            ),
          ),
          CheckboxListTile(
            value: info.install,
            onChanged: _installed
                ? null
                : (val) => setState(() {
                      info.install = val!;
                    }),
            title: Text(str.plugin_add_dialog_install),
            subtitle: _installed ? Text(str.plugin_add_dialog_installed) : null,
          ),
          CheckboxListTile(
            value: info.favorite,
            onChanged: (val) => setState(() {
              info.favorite = val!;
              if (val == false) {
                info.autoRestore = false;
              }
            }),
            title: Text(str.plugin_add_dialog_add_favorite),
          ),
          CheckboxListTile(
            value: info.autoRestore,
            onChanged: info.favorite
                ? (val) => setState(() {
                      info.autoRestore = val!;
                    })
                : null,
            title: Text(str.plugin_add_dialog_auto_restore),
          ),
          info.autoRestore
              ? TextField(
                  controller:
                      TextEditingController(text: info.priority.toString()),
                  decoration: InputDecoration(
                    labelText: str.plugin_add_dialog_priority,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  enabled: info.autoRestore,
                  onChanged: (val) => info.priority = int.parse(val),
                )
              : Container(),
        ],
      )),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            str.plugin_add_dialog_cancel,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            str.plugin_add_dialog_submit,
          ),
        ),
      ],
    );
  }
}

Future<void> showPluginAddDialog(
    BuildContext context, PluginAddInfo info) async {
  bool? submit = await showDialog(
    context: context,
    builder: (context) => _PluginAddDialog(info),
  );
  if (submit != true) {
    return;
  }
  if (info.install) {
    installPackageCommand(info.identifier);
  }
  FavoritePlugin? favoritePlugin;
  try {
    favoritePlugin = (await loadFavoritePlugins())
        .firstWhere((element) => element.name == info.identifier);
  } on StateError catch (_) {}
  if (favoritePlugin != null) {
    favoritePlugins.remove(favoritePlugin);
  }
  if (info.favorite) {
    favoritePlugins.add(FavoritePlugin(info.identifier, info.priority, info.autoRestore));
  }
  await saveFavoritePlugins();
}
