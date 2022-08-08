import 'package:flutter/material.dart';
import 'package:pccclient/utils/general.dart';

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
        drawer: Drawer(
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.settings),
                title: Text(str.home_drawer_settings),
              )
            ],
          ),
        ),
        body: Column(
          children: [],
        ),
    );
  }
}
