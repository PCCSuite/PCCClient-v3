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
  ActivePluginData(this.name, this.repository, this.installed, this.locking,
      this.status, this.statusText, this.dependency);

  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "repository")
  final String repository;
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
}

class Plugin {
  final String name;
  final String? repositoryName;
  final String? dir;

  Plugin(this.name, this.repositoryName, this.dir);
}
