import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:pccclient/screens/part/error.dart';
import 'package:pccclient/screens/plugin_detail.dart';
import 'package:pccclient/screens/plugin_dialog.dart';
import 'package:pccclient/utils/plugins/files.dart';
import 'package:pccclient/utils/plugins/status_enum.dart';

import '../utils/general.dart';
import '../utils/plugins/datas.dart';

class PluginManageScreen extends StatelessWidget {
  const PluginManageScreen({Key? key}) : super(key: key);

  static const routeName = "/plugin/manage";

  static final screenName = str.plugin_manage_title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(PluginManageScreen.screenName),
      ),
      body: const _PluginManageWidget(),
    );
  }
}

class _PluginManageWidget extends StatefulWidget {
  const _PluginManageWidget({Key? key}) : super(key: key);

  @override
  State<_PluginManageWidget> createState() => _PluginManageWidgetState();
}

final String _installed = str.plugin_manage_installed;
final String _favorite = str.plugin_manage_favorite;
final String _repository = str.plugin_manage_repository;

class _PluginManageWidgetState extends State<_PluginManageWidget> {
  String showing = _installed;

  Widget content = const Text("Loading");

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [
      ListTile(
        title: Text(_installed),
        onTap: () {
          setState(() {
            showing = _installed;
          });
          _getInstalledView().then(
                (value) {
              setState(() {
                content = value;
              });
            },
          );
        },
      ),
      ListTile(
        title: Text(_favorite),
        onTap: () {
          setState(() {
            showing = _favorite;
          });
        },
      ),
      ListTile(
        title: Text(_repository),
        onTap: () {
          setState(() {
            showing = _repository;
          });
          _getRepositoryView(null).then(
            (value) {
              setState(() {
                content = value;
              });
            },
          );
        },
      ),
    ];
    for (var repo in pluginSysConfig!.repositories.keys) {
      list.add(ListTile(
        contentPadding: const EdgeInsets.only(left: 50),
        title: Text(repo),
        onTap: () {
          setState(() {
            showing = repo;
          });
          _getRepositoryView(repo).then(
            (value) {
              setState(() {
                content = value;
              });
            },
          );
        },
      ));
    }
    return Row(
      children: [
        Container(
          width: 250,
          color: Colors.black26,
          child: ListView(
            children: list,
          ),
        ),
        Expanded(
          child: content,
        )
      ],
    );
  }
}

Future<Widget> _getRepositoryView(String? repoName) async {
  try {
    List<Plugin> list = [];
    if (repoName != null) {
      String repoDir = pluginSysConfig!.repositories[repoName]!;
      for (var dir in Directory(repoDir).listSync()) {
        list.add(Plugin(path.basename(dir.path), repoName, dir.path));
      }
    } else {
      for (var repo in pluginSysConfig!.repositories.entries) {
        for (var dir in Directory(repo.value).listSync()) {
          list.add(Plugin(path.basename(dir.path), repo.key, dir.path));
        }
      }
    }
    return RepositoryView(
      list: list,
      repositoryName: repoName,
    );
  } catch (err, trace) {
    return getErrorContent(err, trace);
  }
}

class RepositoryView extends StatelessWidget {
  const RepositoryView({Key? key, required this.list, this.repositoryName})
      : super(key: key);

  final List<Plugin> list;

  final String? repositoryName;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: list
          .map((e) => ListTile(
                title: Text(repositoryName != null
                    ? e.name
                    : "${e.name} (${e.repositoryName})"),
                onTap: () {
                  Navigator.pushNamed(context, PluginDetailScreen.routeName,
                      arguments: e);
                },
              ))
          .toList(),
    );
  }
}

Future<Widget> _getInstalledView() async {
  try {
    List<Plugin> list = [];
      for (var plugin in activePlugins) {
        if (!plugin.installed && plugin.status == ActionStatus.failed) {
          continue;
        }
        String? repoDir = pluginSysConfig!.repositories[plugin.repository];
        if (repoDir != null) {
          list.add(Plugin(plugin.name, plugin.repository, path.join(repoDir, plugin.name)));
        } else {
          list.add(Plugin(plugin.name, plugin.repository, null));
        }
      }
    return InstalledView(
      list: list,
    );
  } catch (err, trace) {
    return getErrorContent(err, trace);
  }
}

class InstalledView extends StatelessWidget {
  const InstalledView({Key? key, required this.list})
      : super(key: key);

  final List<Plugin> list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showPluginAddDialog(context, "", true, false),
      ),
      body: ListView(
        children: list
            .map((e) => ListTile(
          title: Text(e.repositoryName != null
              ? "${e.name} (${e.repositoryName})"
              : e.name),
          onTap: () {
            Navigator.pushNamed(context, PluginDetailScreen.routeName,
                arguments: e);
          },
        ))
            .toList(),
      ),
    );
  }
}
