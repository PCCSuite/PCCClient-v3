import 'package:flutter/material.dart';
import 'package:pccclient/utils/plugins/command.dart';
import 'package:pccclient/utils/plugins/datas.dart';
import 'package:pccclient/utils/plugins/status_enum.dart';

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

  void updateList(List<ActivePluginData> newData) {
    setState(() {
      pluginsData = newData;
    });
  }

  PluginSysStatus sysStatus = pluginSysStatus;
  List<ActivePluginData> pluginsData = activePlugins;

  static const double indentPerDepth = 30.0;

  void _builtPluginChildList(List<Widget> dest, List<String> builtName,
      List<String> targetList, int depth) {
    for (String targetName in targetList) {
      if (builtName.contains(targetName)) {
        continue;
      }
      ActivePluginData target =
          pluginsData.firstWhere((element) => element.name == targetName);
      builtName.add(target.name);
      dest.add(_PluginStatusRow(
        status: target.status,
        name: target.name,
        statusText: target.name,
        indent: depth * indentPerDepth,
      ));
      _builtPluginChildList(dest, builtName, target.dependency, depth + 1);
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
    if (sysStatus == PluginSysStatus.ready) {
      list.add(FloatingActionButton(
        onPressed: () {
          startPluginRestore();
        },
        child: Text("temp"),
      ));
    } else {
      List<String> builtName = [];
      _builtPluginChildList(
          list, builtName, pluginsData.map((e) => e.name).toList(), 0);
    }
    // for (ActivePluginData pluginData in pluginsData) {
    //   if (builtName.contains(pluginData.name)) {
    //     continue;
    //   }
    //   builtName.add(pluginData.name);
    //   list.add(_PluginStatusRow(
    //     status: pluginData.status,
    //     name: pluginData.name,
    //     statusText: pluginData.name,
    //     indent: 0,
    //   ));
    // }
    return ListView(
      children: list,
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