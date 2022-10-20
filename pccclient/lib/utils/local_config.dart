import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'local_config.g.dart';

const String _fileName = "pccclient_config.json";

LocalConfig localConfig = LocalConfig(1, "", "", "", true, "");

@JsonSerializable()
class LocalConfig {
  final int configVersion;
  final String serverInfoURL;
  @JsonKey(defaultValue: "")
  final String authMethod;
  @JsonKey(defaultValue: "")
  final String pluginSysConfig;
  @JsonKey(defaultValue: true)
  final bool autoRestore;
  @JsonKey(defaultValue: "")
  final String environment;

  LocalConfig(this.configVersion, this.serverInfoURL, this.authMethod,
      this.pluginSysConfig, this.autoRestore, this.environment);

  factory LocalConfig.fromJson(Map<String, dynamic> json) =>
      _$LocalConfigFromJson(json);

  Map<String, dynamic> toJson() => _$LocalConfigToJson(this);
}

LocalConfig readConfig() {
  File file = File(_fileName);
  String str = file.readAsStringSync();
  Map<String, dynamic> json = jsonDecode(str);
  localConfig = LocalConfig.fromJson(json);
  json = localConfig.toJson();
  str = const JsonEncoder.withIndent("    ").convert(json);
  file.writeAsStringSync(str);
  return localConfig;
}
