import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'local_config.g.dart';

const String _fileName = "pccclient_config.json";

LocalConfig localConfig = LocalConfig(1, "", "", "", true);

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

  LocalConfig(this.configVersion, this.serverInfoURL, this.authMethod,
      this.pluginSysConfig, this.autoRestore);

  factory LocalConfig.fromJson(Map<String, dynamic> json) =>
      _$LocalConfigFromJson(json);

  Map<String, dynamic> toJson() => _$LocalConfigToJson(this);
}

// Directory.current

LocalConfig readConfig() {
  File file = File(_fileName);
  if (file.existsSync()) {
    String str = file.readAsStringSync();
    var json = jsonDecode(str);
    localConfig = LocalConfig.fromJson(json);
  }
  Map<String, dynamic> json = localConfig.toJson();
  String str = const JsonEncoder.withIndent("    ").convert(json);
  file.writeAsStringSync(str);
  return localConfig;
}
