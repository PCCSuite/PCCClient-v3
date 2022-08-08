import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'local_config.g.dart';

const String fileName = "pccclient_config.json";

late final LocalConfig localConfig;

@JsonSerializable()
class LocalConfig {
  final int configVersion;
  final String serverURL;
  final String authMethod;

  LocalConfig(this.configVersion, this.serverURL, this.authMethod);

  factory LocalConfig.fromJson(Map<String, dynamic> json) => _$LocalConfigFromJson(json);

  Map<String, dynamic> toJson() => _$LocalConfigToJson(this);
}

// Directory.current

readConfig() {
  // File file = File(fileName);
  // String str = file.readAsStringSync();
  // var json = jsonDecode(str);
  // localConfig = LocalConfig.fromJson(json);
  localConfig = LocalConfig(1, "", "");
}