import 'package:flutter/material.dart';
import 'package:pccclient/utils/general.dart';
import 'package:pccclient/utils/plugins/status.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const routeName = "/home";

  static var screenName = str.home_title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(HomeScreen.screenName),
      ),
      drawer: const _HomeDrawer(),
      body: Row(
        children: [
          Expanded(
            child: Text("Webview space"),
          ),
          SizedBox(
            width: 400,
            child: _PluginStatusList(),
          )
        ],
      ),
    );
  }
}

class _PluginStatusList extends StatefulWidget {
  const _PluginStatusList({Key? key}) : super(key: key);

  @override
  State<_PluginStatusList> createState() => _PluginStatusListState();
}

class _PluginStatusListState extends State<_PluginStatusList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _PluginStatusRow(
          status: ActionStatus.waitStart,
          name: "start_waiter",
          statusText: "waiting for start",
          indent: 0,
        ),
        _PluginStatusRow(
          status: ActionStatus.waitDepend,
          name: "depend_waiter",
          statusText: "waiting for dependency",
          indent: 0,
        ),
        _PluginStatusRow(
          status: ActionStatus.waitLock,
          name: "lock_waiter",
          statusText: "waiting for lock",
          indent: 30,
        ),
        _PluginStatusRow(
          status: ActionStatus.running,
          name: "running",
          statusText: "running",
          indent: 30,
        ),
        _PluginStatusRow(
          status: ActionStatus.done,
          name: "done",
          statusText: "done",
          indent: 0,
        ),
        _PluginStatusRow(
          status: ActionStatus.failed,
          name: "failed",
          statusText: "failed",
          indent: 0,
        ),
      ],
    );
  }
}

class _PluginStatusRow extends StatelessWidget {
  const _PluginStatusRow(
      {Key? key,
      required this.status,
      required this.name,
      required this.statusText,
      required this.indent})
      : super(key: key);

  final ActionStatus status;
  final String name;
  final String? statusText;
  final double indent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: indent),
      child: ListTile(
        leading: status.icon,
        title: Text(name),
        subtitle: statusText != null ? Text(statusText!) : null,
      ),
    );
  }
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(str.home_drawer_settings),
          )
        ],
      ),
    );
  }
}
