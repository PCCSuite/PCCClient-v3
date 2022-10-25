import 'package:json_annotation/json_annotation.dart';
import 'package:pccclient/utils/plugins/files.dart';
import 'package:pccclient/utils/plugins/status_enum.dart';
import 'package:pccclient/utils/plugins/status_widget.dart';

import 'buttons_widget.dart';

import 'package:path/path.dart' as path;

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
List<ActivePluginData> _installingAndInstalledPlugins = <ActivePluginData>[];

List<ActivePluginData> get activePlugins => _activePlugins;
List<ActivePluginData> get installingAndInstalledPlugins => _installingAndInstalledPlugins;
set activePlugins(List<ActivePluginData> newData) {
  _activePlugins = newData;
  List<ActivePluginData> list = [];
  _installingAndInstalledPlugins = _activePlugins.where((element) => element.installed || element.status != ActionStatus.failed).toList();
  for (PluginSysStatusWidgetState wid in pluginSysStatusWidgets) {
    wid.updateList(newData);
  }
  for (PluginButtonsWidgetState wid in pluginButtonsWidgets) {
    wid.updateList(newData);
  }
}

@JsonSerializable()
class ActivePluginData {
  ActivePluginData(this.identifier, this.repositoryName, this.installed, this.locking,
      this.status, this.statusText, this.dependency) :
        name = identifier.split(":").last;

  @JsonKey(name: "identifier")
  final String identifier;
  final String name;
  @JsonKey(name: "repository")
  final String repositoryName;
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

  bool isInstalledOrInstalling() {
    if (installed) {
      return true;
    }
    if (status == ActionStatus.failed) {
      return false;
    }
    return true;
  }

  Plugin toPlugin() {
    return Plugin.autoDir(identifier, name, repositoryName);
  }
}

List<AskData> _askData = <AskData>[];

List<AskData> get askData => _askData;
set askData(List<AskData> newData) {
  _askData = newData;
  for (PluginSysStatusWidgetState list in pluginSysStatusWidgets) {
    list.updateAsk(newData);
  }
}

enum AskStatus {
  showing,
  done,
}

Map<int,AskStatus> askStatus = {};

@JsonSerializable()
class AskData {
  AskData(this.id, this.package, this.plugin, this.type, this.message);

  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "package")
  final String package;
  @JsonKey(name: "plugin")
  final String plugin;
  @JsonKey(name: "type")
  final String type;
  @JsonKey(name: "message")
  final String message;

  factory AskData.fromJson(Map<String, dynamic> json) =>
      _$AskDataFromJson(json);
}

class Plugin {
  final String identifier;
  final String name;
  final String? repositoryName;
  final String? dir;

  Plugin(this.identifier, this.name, this.repositoryName, this.dir);
  factory Plugin.autoDir(String identifier, String name, String? repositoryName) {
    var repoDir = pluginSysConfig.repositories[repositoryName];
    String? dir;
    if (repoDir != null) {
      dir = path.join(repoDir, name);
    }
    return Plugin(identifier, name, repositoryName, dir);
  }
  factory Plugin.fromIdentifier(String identifier) {
    String name;
    String? repo;
    var split = identifier.split(":");
    if (split.length == 1) {
      name = identifier;
      try {
        ActivePluginData plugin = activePlugins.firstWhere((element) => element.name == name);
        repo = plugin.repositoryName;
      } on StateError catch (_) {}
    } else {
      repo = split[0];
      name = split[1];
    }
    return Plugin.autoDir(identifier, split.last, split.length == 2 ? split.first : null);
  }
}
