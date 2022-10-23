import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:pccclient/screens/part/error.dart';
import 'package:pccclient/screens/plugin_detail.dart';
import 'package:pccclient/screens/plugin_add.dart';
import 'package:pccclient/utils/plugins/files.dart';
import 'package:pccclient/utils/plugins/status_enum.dart';

import '../utils/general.dart';
import '../utils/plugins/datas.dart';
import '../utils/plugins/list_file.dart';

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

  static const Widget loading = Text("Loading");

  Widget content = loading;

  @override
  void initState() {
    _getInstalledView().then((value) {
      setState(() {
        content = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [
      ListTile(
        title: Text(_installed),
        selected: showing == _installed,
        onTap: () {
          setState(() {
            showing = _installed;
            content = loading;
          });
          _getInstalledView().then((value) {
            setState(() {
              content = value;
            });
          });
        },
      ),
      ListTile(
        title: Text(_favorite),
        selected: showing == _favorite,
        onTap: () {
          setState(() {
            showing = _favorite;
            content = loading;
          });
          _getFavoriteView().then((value) {
            setState(() {
              content = value;
            });
          });
        },
      ),
      ListTile(
        title: Text(_repository),
        selected: showing == _repository,
        onTap: () {
          setState(() {
            showing = _repository;
            content = loading;
          });
          _getRepositoryView(null).then((value) {
            setState(() {
              content = value;
            });
          });
        },
      ),
    ];
    for (var repo in pluginSysConfig.repositories.keys) {
      list.add(ListTile(
        contentPadding: const EdgeInsets.only(left: 50),
        title: Text(repo),
        selected: showing == repo,
        onTap: () {
          setState(() {
            showing = repo;
            content = loading;
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

Future<Widget> _getInstalledView() async {
  try {
    return InstalledView(
      list: installingAndInstalledPlugins.map((e) {
        String? repoDir = pluginSysConfig.repositories[e.repository];
        if (repoDir != null) {
          return Plugin(e.name, e.repository, path.join(repoDir, e.name));
        } else {
          return Plugin(e.name, e.repository, null);
        }
      }).toList(),
    );
  } catch (err, trace) {
    return getErrorContent(err, trace);
  }
}

class InstalledView extends StatelessWidget {
  const InstalledView({Key? key, required this.list}) : super(key: key);

  final List<Plugin> list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            showPluginAddDialog(context, PluginAddInfo(install: true)),
        child: const Icon(Icons.add),
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

Future<Widget> _getFavoriteView() async {
  try {
    List<FavoritePlugin> favorites = await loadFavoritePlugins();
    List<Plugin> list = favorites.map((e) {
      List<String> splitName = e.name.split(":");
      String name;
      String? repo;
      if (splitName.length == 1) {
        name = e.name;
        try {
          ActivePluginData plugin = activePlugins.firstWhere((element) => element.name == e.name);
          repo = plugin.repository;
        } on StateError catch (_) {}
      } else {
        repo = splitName[0];
        name = splitName[1];
      }
      if (repo == null) {
        return Plugin(name, null, null);
      } else {
        String? repoDir = pluginSysConfig.repositories[repo];
        if (repoDir == null) {
          return Plugin(name, repo, null);
        } else {
          return Plugin(name, repo, path.join(repoDir, splitName[1]));
        }
      }
    }).toList();
    return FavoriteView(
      list: list,
    );
  } catch (err, trace) {
    return getErrorContent(err, trace);
  }
}

class FavoriteView extends StatelessWidget {
  const FavoriteView({Key? key, required this.list}) : super(key: key);

  final List<Plugin> list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            showPluginAddDialog(context, PluginAddInfo(favorite: true)),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: list
            .map((e) => ListTile(
                  title: Text(e.repositoryName != null
                      ? "${e.name} (${e.repositoryName})"
                      : e.name),
                  onTap: () {
                    if (e.repositoryName == null) {
                      try {
                        e = getPluginsInRepositories().firstWhere((element) => element.name == e.name);
                      } on StateError catch (_) {}
                    }
                    Navigator.pushNamed(context, PluginDetailScreen.routeName,
                        arguments: e);
                  },
                ))
            .toList(),
      ),
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

List<Plugin> getPluginsInRepositories() {
  List<Plugin> list = [];
  for (var repo in pluginSysConfig!.repositories.entries) {
    for (var dir in Directory(repo.value).listSync()) {
      list.add(Plugin(path.basename(dir.path), repo.key, dir.path));
    }
  }
  return list;
}