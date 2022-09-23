import 'package:flutter/material.dart';
import 'package:pccclient/screens/debug.dart';
import 'package:pccclient/utils/environment/common.dart';
import 'package:pccclient/utils/general.dart';
import 'package:pccclient/utils/plugins/status_enum.dart';
import 'package:pccclient/utils/plugins/widget.dart';

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
      child: Text("Webview space"),
    ));
    if (environment.enablePlugin) {
      content.add(const SizedBox(
          width: 400,
          child: PluginSysStatusWidget()
      ));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(HomeScreen.screenName),
      ),
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
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(str.home_drawer_settings),
          ),
          ListTile(
            leading: Icon(Icons.developer_mode),
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
