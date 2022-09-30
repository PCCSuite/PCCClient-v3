import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:pccclient/utils/local_config.dart';
import 'package:pccclient/utils/server_info.dart';

part 'files.g.dart';

PluginSysConfig? pluginSysConfig;

@JsonSerializable()
class PluginSysConfig {
  PluginSysConfig(
      this.pluginsList, this.repositories, this.dataDir, this.tempDir);

  @JsonKey(name: "plugins_list")
  final String pluginsList;
  @JsonKey(name: "repositories")
  final Map<String,String> repositories;
  @JsonKey(name: "data_dir")
  final String dataDir;
  @JsonKey(name: "temp_dir")
  final String tempDir;

  factory PluginSysConfig.fromJson(Map<String, dynamic> json) =>
      _$PluginSysConfigFromJson(json);

  Map<String, dynamic> toJson() => _$PluginSysConfigToJson(this);
}

Future<void> loadPluginSysConfig() async {
  var configPath = "${serverInfo.pluginSysPath}\\config.json";
  if (localConfig.pluginSysConfig.isNotEmpty) {
    configPath = localConfig.pluginSysConfig;
  }
  File configFile = File(configPath);
  String str = await configFile.readAsString();
  var jsonRaw = jsonDecode(str);
  pluginSysConfig = PluginSysConfig.fromJson(jsonRaw);
}