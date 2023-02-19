import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';
import 'package:pccclient/screens/plugin_manage.dart';
import 'package:pccclient/utils/plugins/files.dart';
import 'package:pccclient/utils/plugins/status_enum.dart';
import 'package:pccclient/utils/plugins/status_widget.dart';

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

Map<String, HashSet<Function(ActivePackageData)>> _activePackageListener = {};

List<ActivePackageData> _activePackages = <ActivePackageData>[];
List<ActivePackageData> _installingAndInstalledPackages = <ActivePackageData>[];

List<ActivePackageData> get activePackages => _activePackages;

List<ActivePackageData> get installingAndInstalledPlugins =>
    _installingAndInstalledPackages;

set activePackages(List<ActivePackageData> newData) {
  _activePackages = newData;
  _installingAndInstalledPackages = _activePackages
      .where((element) =>
          element.installed || element.status != ActionStatus.failed)
      .toList();
  for (PluginSysStatusWidgetState wid in pluginSysStatusWidgets) {
    wid.updateList(newData);
  }
  for (var data in newData) {
    var listeners = _activePackageListener[data.identifier];
    if (listeners == null) continue;
    for (var listener in listeners) {
      listener(data);
    }
  }
}

void subscribeActivePackage(
    String packageName, Function(ActivePackageData) func) {
  var listeners = _activePackageListener[packageName];
  if (listeners == null) {
    listeners = HashSet();
    _activePackageListener[packageName] = listeners;
  }
  listeners.add(func);
}

void unsubscribeActivePackage(
    String packageName, Function(ActivePackageData) func) {
  var listeners = _activePackageListener[packageName];
  listeners!.remove(func);
}

@JsonSerializable()
class ActivePackageData {
  ActivePackageData(
      this.identifier,
      this.repositoryName,
      this.installed,
      this.locking,
      this.status,
      this.statusText,
      this.priority,
      this.dependency)
      : name = identifier.split(":").last;

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
  @JsonKey(name: "priority")
  final int priority;
  @JsonKey(name: "dependency")
  final List<String> dependency;

  factory ActivePackageData.fromJson(Map<String, dynamic> json) =>
      _$ActivePluginDataFromJson(json);

  Map<String, dynamic> toJson() => _$ActivePluginDataToJson(this);

  bool isInstalledOrInstalling() {
    if (installed) {
      return true;
    }
    return isRunning();
  }

  bool isRunning() {
    if (status == ActionStatus.done) {
      return false;
    } else if (status == ActionStatus.failed) {
      return false;
    } else {
      return true;
    }
  }

  Package toPlugin() {
    return Package.autoDir(name, repositoryName);
  }

  String getFullIdentifier() {
    return "$repositoryName:$name";
  }

  static ActivePackageData? findByName(String name) {
    for (var data in activePackages) {
      if (data.name == name) {
        return data;
      }
    }
    return null;
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

Map<int, AskStatus> askStatus = {};

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

  Map<String, dynamic> toJson() => _$AskDataToJson(this);
}

class Package {
  final String name;
  final String? repositoryName;
  final String? dir;

  Package(this.name, this.repositoryName, this.dir);

  factory Package.autoDir(String name, String repositoryName) {
    var repoDir = pluginSysConfig.repositories[repositoryName];
    String? dir;
    if (repoDir != null) {
      dir = path.join(repoDir, name);
    }
    return Package(name, repositoryName, dir);
  }

  factory Package.fromIdentifier(String identifier) {
    var split = identifier.split(":");
    if (split.length == 1) {
      try {
        return getPluginsInRepositories()
            .firstWhere((element) => element.name == identifier);
      } on StateError catch (_) {}
      return Package(identifier, null, null);
    } else {
      return Package.autoDir(split[1], split[0]);
    }
  }

  String getIdentifier() {
    if (repositoryName == null) {
      return name;
    } else {
      return "$repositoryName:$name";
    }
  }

  ActivePackageData? getActiveData() {
    for (var data in activePackages) {
      if (data.name == name) {
        return data;
      }
    }
    return null;
  }
}
