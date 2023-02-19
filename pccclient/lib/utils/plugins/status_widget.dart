import 'package:flutter/material.dart';
import '../../screens/part/error.dart';
import '../../screens/plugin_detail.dart';
import '../general.dart';
import 'command.dart';
import 'datas.dart';
import 'start.dart';
import 'status_enum.dart';

import 'ask.dart';

class PluginSysStatusWidget extends StatefulWidget {
  const PluginSysStatusWidget({Key? key}) : super(key: key);

  @override
  State<PluginSysStatusWidget> createState() => PluginSysStatusWidgetState();
}

List<PluginSysStatusWidgetState> pluginSysStatusWidgets = [];

class PluginSysStatusWidgetState extends State<PluginSysStatusWidget> {
  @override
  void initState() {
    pluginSysStatusWidgets.add(this);
    Future.delayed(Duration.zero, checkAsk);
    super.initState();
  }

  @override
  void dispose() {
    pluginSysStatusWidgets.remove(this);
    super.dispose();
  }

  void updateStatus(PluginSysStatus newData) {
    setState(() {
      sysStatus = newData;
    });
  }

  void updateList(List<ActivePackageData> newData) {
    setState(() {
      pluginsData = newData;
    });
  }

  void updateAsk(List<AskData> newData) {
    setState(() {
      _askData = newData;
      checkAsk();
    });
  }

  Future<void> checkAsk() async {
    for (var data in _askData) {
      AskStatus? status = askStatus[data.id];
      if (status == null) {
        askStatus[data.id] = AskStatus.showing;
        showAskDialog(context, data).then((value) {
          askStatus[data.id] = AskStatus.done;
        }).catchError((err, trace) {
          showError(context, err, trace);
        });
      }
    }
  }

  PluginSysStatus sysStatus = pluginSysStatus;
  List<ActivePackageData> pluginsData = activePackages;
  List<AskData> _askData = askData;

  static const double indentPerDepth = 30.0;

  void _builtPluginChildList(List<Widget> dest, List<String> builtList,
      List<String> targetList, int depth) {
    for (String targetName in targetList) {
      if (builtList.contains(targetName)) {
        continue;
      }
      ActivePackageData target =
          pluginsData.firstWhere((element) => element.identifier == targetName);
      builtList.add(target.identifier);
      dest.add(PackageStatusRow(
        package: target,
        indent: depth * indentPerDepth,
        clickable: true,
      ));
      _builtPluginChildList(dest, builtList, target.dependency, depth + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    list.add(ListTile(
      title: Text(
        "PluginSysステータス: ${sysStatus.message}",
      ),
    ));
    switch (sysStatus) {
      case PluginSysStatus.ready:
        {
          list.add(ElevatedButton(
            onPressed: () {
              startPluginRestore();
            },
            child: Text(str.plugin_sys_start_restore),
          ));
          break;
        }
      case PluginSysStatus.stopped:
        {
          list.add(ElevatedButton(
            onPressed: () {
              startPluginSys();
            },
            child: Text(str.plugin_sys_restart),
          ));
          break;
        }
      default:
    }
    pluginsData.sort((a, b) => a.priority.compareTo(b.priority));
    List<String> noParentList = pluginsData.map((e) => e.identifier).toList();
    for (ActivePackageData plugin in pluginsData) {
      for (String depend in plugin.dependency) {
        noParentList.remove(depend);
      }
    }
    List<String> builtName = [];
    _builtPluginChildList(list, builtName, noParentList, 0);
    return ListView(
      children: list,
    );
  }
}

class PackageStatusRow extends StatelessWidget {
  const PackageStatusRow(
      {Key? key,
      required this.package,
      required this.indent,
      required this.clickable})
      : super(key: key);

  final ActivePackageData package;
  final double indent;
  final bool clickable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: indent),
      child: ListTile(
        leading: package.status.icon,
        title: Text(package.identifier),
        subtitle: Text(package.statusText),
        onTap: clickable
            ? () => Navigator.pushNamed(context, PluginDetailScreen.routeName,
                arguments: package.toPlugin())
            : null,
      ),
    );
  }
}
