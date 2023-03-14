import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wordpress_api/wordpress_api.dart';
import '../main.dart';
import '../utils/auth.dart';
import '../utils/user_settings.dart';
import 'debug.dart';
import 'part/tips.dart';
import 'plugin_manage.dart';
import '../utils/environment/common.dart';
import '../utils/general.dart';
import '../utils/plugins/status_widget.dart';
import 'samba.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const routeName = "/home";

  static var screenName = str.home_title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget _mainContent = const Text("Loading...");

  @override
  void initState() {
    _loadWordpress();
    super.initState();
  }

  Future<void> _loadWordpress() async {
    var wordpress = WordPressAPI("pccs3.tama-st-h.local/wordpress");
    var posts = await wordpress.posts.fetch();
    List<_WordPressPostWidget> postWidgets = [];
    for (Post post in posts.data) {
      postWidgets.add(_WordPressPostWidget(post: post));
    }
    setState(() {
      _mainContent = ListView(
        children: postWidgets,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> content = [];
    content.add(Expanded(
      child: _mainContent,
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
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "PCCClient $version",
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Logged in as $username",
                        textAlign: TextAlign.left,
                      ),
                      userSettings.debugMode
                          ? Text(
                              "Role: ${sambaRoles.isEmpty ? "None" : sambaRoles.join(",")}",
                              textAlign: TextAlign.left,
                            )
                          : Container(),
                      userSettings.debugMode
                          ? Text(
                              "machineType: ${environment.machineType.name}",
                              textAlign: TextAlign.left,
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
            leading: const Icon(Icons.storage),
            title: Text(str.home_drawer_samba),
            onTap: () {
              Navigator.pushNamed(context, SambaScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(str.home_drawer_settings),
            onTap: () {
              Navigator.pushNamed(context, SettingsScreen.routeName);
            },
          ),
          userSettings.debugMode
              ? ListTile(
                  leading: const Icon(Icons.developer_mode),
                  title: Text(str.home_drawer_debug),
                  onTap: () {
                    Navigator.pushNamed(context, DebugScreen.routeName);
                  },
                )
              : Container(),
        ],
      ),
    );
  }
}

class _WordPressPostWidget extends StatelessWidget {
  const _WordPressPostWidget({Key? key, required this.post}) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(post.title!),
      subtitle: Text(post.date!),
      isThreeLine: true,
      onTap: () {
        launchUrl(Uri.parse(post.link!));
      },
    );
  }
}
