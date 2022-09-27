import 'package:flutter/cupertino.dart';
import 'package:pccclient/utils/plugins/status_enum.dart';
import 'package:pccclient/utils/plugins/widget.dart';

PluginSysStatus _pluginSysStatus = PluginSysStatus.stopped;

PluginSysStatus get pluginSysStatus => _pluginSysStatus;
set pluginSysStatus(PluginSysStatus newData) {
  _pluginSysStatus = newData;
  for (PluginSysStatusWidgetState list in pluginSysStatusWidgets) {
    list.updateStatus(newData);
  }
}

List<ActivePluginData> _activePlugins = <ActivePluginData>[];

List<ActivePluginData> get activePlugins => _activePlugins;
set activePlugins(List<ActivePluginData> newData) {
  _activePlugins = newData;
  for (PluginSysStatusWidgetState list in pluginSysStatusWidgets) {
    list.updateList(newData);
  }
}

class ActivePluginData {
  final String name;
  final String repoDir;
  final bool installed;
  final bool locking;
  final ActionStatus status;
  final String statusText;
  final List<String> dependency;

  ActivePluginData.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        repoDir = json["repodir"],
        installed = json["installed"],
        locking = json["locking"],
        status = ActionStatus.from(json["status"]),
        statusText = json["status_text"],
        dependency = json["dependency"].cast<String>();
}
