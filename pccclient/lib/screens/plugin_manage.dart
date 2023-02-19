import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'part/tips.dart';
import 'plugin_detail.dart';
import 'plugin_add.dart';
import '../utils/plugins/files.dart';

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
      bottomNavigationBar: getTipsBar(),
      body: const _PluginManageWidget(),
    );
  }
}

class _PluginManageWidget extends StatefulWidget {
  const _PluginManageWidget({Key? key}) : super(key: key);

  @override
  State<_PluginManageWidget> createState() => _PluginManageWidgetState();
}

final String _favorite = str.plugin_manage_favorite;
final String _installed = str.plugin_manage_installed;
final String _repository = str.plugin_manage_repository;

class _PluginManageWidgetState extends State<_PluginManageWidget> {
  String showing = _favorite;

  static const Widget _loading = Text("Loading");

  Widget content = _loading;

  List<Package> _list = [];

  String _search = "";
  final _searchFieldController = TextEditingController();

  @override
  void initState() {
    _searchFieldController.addListener(() {
      _search = _searchFieldController.text;
      _refresh();
    });

    _showFavorite();
    super.initState();
  }

  Future<void> _showFavorite() async {
    showing = _favorite;
    List<FavoritePlugin> favorites = await loadFavoritePlugins();
    _list = favorites.map((e) => Package.fromIdentifier(e.identifier)).toList();
    _refresh();
  }

  Future<void> _showInstalled() async {
    showing = _installed;
    _list = installingAndInstalledPlugins.map((e) => e.toPlugin()).toList();
    _refresh();
  }

  Future<void> _showRepository(String? repoName) async {
    showing = repoName ?? _repository;
    _list = [];
    if (repoName != null) {
      String repoDir = pluginSysConfig.repositories[repoName]!;
      for (var dir in Directory(repoDir).listSync()) {
        _list.add(Package(path.basename(dir.path), repoName, dir.path));
      }
    } else {
      _list = getPluginsInRepositories();
    }
    _refresh();
  }

  void _refresh() {
    _list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    setState(() {
      content = _PluginListWidget(
        list: _search == ""
            ? _list
            : _list
                .where((element) =>
                    element.name.toLowerCase().contains(_search.toLowerCase()))
                .toList(),
        showRepoName: showing == _installed ||
            showing == _favorite ||
            showing == _repository,
        favorite: showing == _favorite,
        install: showing == _installed,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [
      ListTile(
        title: Text(_favorite),
        selected: showing == _favorite,
        onTap: () {
          _showFavorite();
        },
      ),
      ListTile(
        title: Text(_installed),
        selected: showing == _installed,
        onTap: () {
          _showInstalled();
        },
      ),
      ListTile(
        title: Text(_repository),
        selected: showing == _repository,
        onTap: () {
          _showRepository(null);
        },
      ),
    ];
    for (var repo in pluginSysConfig.repositories.keys) {
      list.add(ListTile(
        contentPadding: const EdgeInsets.only(left: 50),
        title: Text(repo),
        selected: showing == repo,
        onTap: () {
          _showRepository(repo);
        },
      ));
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showPluginAddDialog(
            context,
            PluginAddInfo(
              favorite: showing == _favorite,
              install: showing == _installed,
            )),
        child: const Icon(Icons.add),
      ),
      body: Row(
        children: [
          Container(
            width: 250,
            color: Colors.black26,
            child: ListView(
              children: list,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                TextField(
                  controller: _searchFieldController,
                  decoration: InputDecoration(
                    // isDense: true,
                    icon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                        onPressed: _searchFieldController.clear,
                        icon: const Icon(Icons.clear)),
                  ),
                ),
                Expanded(
                  child: content,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PluginListWidget extends StatelessWidget {
  const _PluginListWidget(
      {Key? key,
      required this.list,
      this.showRepoName = true,
      this.favorite = false,
      this.install = false})
      : super(key: key);

  final bool showRepoName;
  final bool favorite;
  final bool install;

  final List<Package> list;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: list
          .map((e) => ListTile(
                title: Text(showRepoName && e.repositoryName != null
                    ? "${e.name} (${e.repositoryName})"
                    : e.name),
                onTap: () {
                  if (e.repositoryName == null) {
                    try {
                      e = Package.fromIdentifier(e.name);
                    } on StateError catch (_) {}
                  }
                  Navigator.pushNamed(context, PluginDetailScreen.routeName,
                      arguments: e);
                },
              ))
          .toList(),
    );
  }
}

List<Package> getPluginsInRepositories() {
  List<Package> list = [];
  for (var repo in pluginSysConfig.repositories.entries) {
    for (var dir in Directory(repo.value).listSync()) {
      list.add(Package(path.basename(dir.path), repo.key, dir.path));
    }
  }
  return list;
}
