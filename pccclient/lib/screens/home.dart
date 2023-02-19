import 'package:flutter/material.dart';
import 'debug.dart';
import 'part/tips.dart';
import 'plugin_manage.dart';
import '../utils/environment/common.dart';
import '../utils/general.dart';
import '../utils/plugins/status_widget.dart';

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
    List<Widget> content = [];
    content.add(const Expanded(
      child: Text("Welcome to PCC!"),
    ));
    if (environment.enablePlugin) {
      content.add(const SizedBox(
        width: 400,
        child: PluginSysStatusWidget(),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(HomeScreen.screenName),
      ),
      bottomNavigationBar: getTipsBar(),
      drawer: const _HomeDrawer(),
      body: Row(
        children: content,
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
          environment.enablePlugin
              ? ListTile(
                  leading: const Icon(Icons.settings_applications),
                  title: Text(str.home_drawer_plugin),
                  onTap: () {
                    Navigator.pushNamed(context, PluginManageScreen.routeName);
                  },
                )
              : Container(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(str.home_drawer_settings),
          ),
          ListTile(
            leading: const Icon(Icons.developer_mode),
            title: Text(str.home_drawer_debug),
            onTap: () {
              Navigator.pushNamed(context, DebugScreen.routeName);
            },
          )
        ],
      ),
    );
  }
}
