import 'package:flutter/material.dart';
import 'package:pccclient/utils/plugins/files.dart';

import '../utils/general.dart';

class ManagePluginScreen extends StatelessWidget {
  const ManagePluginScreen({Key? key}) : super(key: key);

  static const routeName = "/manage_plugin";

  static final screenName = str.manage_plugin_title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ManagePluginScreen.screenName),
      ),
      body: const _ManagePluginWidget(),
    );
  }
}

class _ManagePluginWidget extends StatefulWidget {
  const _ManagePluginWidget({Key? key}) : super(key: key);

  @override
  State<_ManagePluginWidget> createState() => _ManagePluginWidgetState();
}

final String _installed = str.manage_plugin_installed;
final String _favorite = str.manage_plugin_favorite;

class _ManagePluginWidgetState extends State<_ManagePluginWidget> {
  String showing = _installed;

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [
      ListTile(
        title: Text(_installed),
        onTap: () {
          setState(() {
            showing = _installed;
          });
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
    ];
    for (var repo in pluginSysConfig!.repositories.keys) {
      list.add(ListTile(
        title: Text(repo),
        onTap: () {
          setState(() {
            showing = repo;
          });
        },
      ));
    }
    return Row(
      children: [
        ListView(
          children: list,
        )
      ],
    );
  }
}
