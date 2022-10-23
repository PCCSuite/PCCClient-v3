import 'package:flutter/material.dart';
import 'package:pccclient/utils/plugins/datas.dart';
import 'package:pccclient/utils/plugins/list_file.dart';
import 'package:pccclient/utils/plugins/status_enum.dart';

import '../utils/general.dart';

class PluginAddInfo {
  String plugin;
  bool install;
  bool favorite;
  bool autoRestore;

  PluginAddInfo(
      {this.plugin = "",
      this.install = false,
      this.favorite = false,
      this.autoRestore = false});
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
    if (info.plugin.isNotEmpty) {
      try {
        installingAndInstalledPlugins.firstWhere((element) => element.name == info.plugin.split(":").last);
        info.install = false;
        _installed = true;
      } on StateError catch (_) {
        _installed = false;
      }
      try {
        FavoritePlugin plugin =
        favoritePlugins.firstWhere((element) => element.name == info.plugin);
        info.favorite = true;
        info.autoRestore = plugin.enabled;
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
              initialValue: info.plugin,
              onChanged: (val) => setState(() {
                info.plugin = val;
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
}
