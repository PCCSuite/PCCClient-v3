import 'package:flutter/material.dart';
import 'package:pccclient/screens/part/error.dart';
import 'package:pccclient/screens/plugin_detail.dart';
import 'package:pccclient/utils/general.dart';
import 'package:pccclient/utils/plugins/command.dart';
import 'package:pccclient/utils/plugins/datas.dart';
import 'package:pccclient/utils/plugins/start.dart';
import 'package:pccclient/utils/plugins/status_enum.dart';

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

  void updateList(List<ActivePluginData> newData) {
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
  List<ActivePluginData> pluginsData = activePlugins;
  List<AskData> _askData = askData;

  static const double indentPerDepth = 30.0;

  void _builtPluginChildList(List<Widget> dest, List<String> builtName,
      List<String> targetList, int depth) {
    for (String targetName in targetList) {
      if (builtName.contains(targetName)) {
        continue;
      }
      ActivePluginData target =
          pluginsData.firstWhere((element) => element.identifier == targetName);
      builtName.add(target.identifier);
      dest.add(_PluginStatusRow(
        plugin: target,
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
    List<String> builtName = [];
    _builtPluginChildList(
        list, builtName, pluginsData.map((e) => e.identifier).toList(), 0);
    return ListView(
      children: list,
    );
  }

}

class _PluginStatusRow extends StatelessWidget {
  const _PluginStatusRow(
      {Key? key,
      required this.plugin,
      required this.indent})
      : super(key: key);

  final ActivePluginData plugin;
  final double indent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: indent),
      child: ListTile(
        leading: plugin.status.icon,
        title: Text(plugin.identifier),
        subtitle: Text(plugin.statusText),
        onTap: () => Navigator.pushNamed(context, PluginDetailScreen.routeName, arguments: plugin.toPlugin()),
      ),
    );
  }
}
