import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pccclient/utils/plugins/status_enum.dart';
import 'package:pccclient/utils/plugins/widget.dart';

part 'datas.g.dart';

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

@JsonSerializable()
class ActivePluginData {
  ActivePluginData(this.name, this.repoDir, this.installed, this.locking, this.status, this.statusText, this.dependency);

  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "repodir")
  final String repoDir;
  @JsonKey(name: "installed")
  final bool installed;
  @JsonKey(name: "locking")
  final bool locking;
  @JsonKey(name: "status")
  final ActionStatus status;
  @JsonKey(name: "status_text")
  final String statusText;
  @JsonKey(name: "dependency")
  final List<String> dependency;

  factory ActivePluginData.fromJson(Map<String, dynamic> json) =>
      _$ActivePluginDataFromJson(json);

  Map<String, dynamic> toJson() => _$ActivePluginDataToJson(this);

  // ActivePluginData.fromJson(Map<String, dynamic> json)
  //     : name = json["name"],
  //       repoDir = json["repodir"],
  //       installed = json["installed"],
  //       locking = json["locking"],
  //       status = ActionStatus.from(json["status"]),
  //       statusText = json["status_text"],
  //       dependency = json["dependency"].cast<String>();
}
