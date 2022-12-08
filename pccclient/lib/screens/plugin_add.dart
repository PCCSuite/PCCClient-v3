import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pccclient/utils/plugins/command.dart';
import 'package:pccclient/utils/plugins/datas.dart';
import 'package:pccclient/utils/plugins/files.dart';
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

  Future<void> _checkPluginStatus(bool overwriteIdentifier) async {
    if (info.identifier.isNotEmpty) {
      try {
        installingAndInstalledPlugins.firstWhere(
            (element) => element.name == info.identifier.split(":").last);
        setState(() {
          info.install = false;
          _installed = true;
        });
      } on StateError catch (_) {
        setState(() {
          _installed = false;
        });
      }
      FavoritePlugin? favorite = _getMatchFavorite(info.identifier);
      setState(() {
        if (favorite == null) {
          info.favorite = false;
          info.autoRestore = false;
        } else {
          if (overwriteIdentifier) {
            info.identifier = favorite.identifier;
          }
          info.favorite = true;
          info.autoRestore = favorite.enabled;
          info.priority = favorite.priority;
        }
      });
    }
  }

  @override
  void initState() {
    _checkPluginStatus(true);
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
            onFocusChange: (val) => _checkPluginStatus(false),
            child: TextFormField(
              decoration: InputDecoration(
                  labelText: str.plugin_add_dialog_plugin_id,
                  hintText: "repository:name"),
              initialValue: info.identifier,
              onChanged: (val) => setState(() {
                info.identifier = val;
              }),
              onFieldSubmitted: (val) => _checkPluginStatus(false),
              onEditingComplete: () => _checkPluginStatus(false),
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

Future<void> showPluginAddDialog(BuildContext context, PluginAddInfo info,
    {Plugin? plugin}) async {
  if (info.identifier == "" && plugin != null) {}
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
  await loadFavoritePlugins();
  FavoritePlugin? favoritePlugin = _getMatchFavorite(info.identifier);
  if (favoritePlugin != null) {
    favoritePlugins.remove(favoritePlugin);
  }
  if (info.favorite) {
    favoritePlugins
        .add(FavoritePlugin(info.identifier, info.priority, info.autoRestore));
  }
  await saveFavoritePlugins();
}


FavoritePlugin? _getMatchFavorite(String identifier) {
  List<String> splitId = identifier.split(":");
  String? repo;
  bool isInternal = true;
  if (splitId.length == 2) {
    repo = splitId.first;
    isInternal = pluginSysConfig.repositories[repo] != null;
  }
  String name = splitId.last;
  for (FavoritePlugin plugin in favoritePlugins) {
    if (plugin.identifier == identifier) {
      return plugin;
    }
    if (isInternal) {
      List<String> splitId = plugin.identifier.split(":");
      if (splitId.last != name) {
        continue;
      }
      if (splitId.length == 1) {
        return plugin;
      }
      if (repo == null && pluginSysConfig.repositories[splitId[0]] != null) {
        return plugin;
      }
    }
  }
  return null;
}