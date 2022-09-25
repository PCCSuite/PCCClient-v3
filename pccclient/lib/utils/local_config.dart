import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'local_config.g.dart';

const String _fileName = "pccclient_config.json";

LocalConfig localConfig = LocalConfig(1, "", "", "");

@JsonSerializable()
class LocalConfig {
  final int configVersion;
  final String serverURL;
  final String authMethod;
  final String pluginSysConfig;

  LocalConfig(this.configVersion, this.serverURL, this.authMethod,
      this.pluginSysConfig);

  factory LocalConfig.fromJson(Map<String, dynamic> json) =>
      _$LocalConfigFromJson(json);

  Map<String, dynamic> toJson() => _$LocalConfigToJson(this);
}

// Directory.current

readConfig() {
  File file = File(_fileName);
  String str = file.readAsStringSync();
  var json = jsonDecode(str);
  localConfig = LocalConfig.fromJson(json);
}
