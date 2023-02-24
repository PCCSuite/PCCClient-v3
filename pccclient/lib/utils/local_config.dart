import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'local_config.g.dart';

const String _fileName = "pccclient_config.json";

late LocalConfig localConfig;

@JsonSerializable()
class LocalConfig {
  final int configVersion;
  final String serverInfoURL;
  @JsonKey(defaultValue: "")
  final String environment;

  LocalConfig(this.configVersion, this.serverInfoURL, this.environment);

  factory LocalConfig.fromJson(Map<String, dynamic> json) =>
      _$LocalConfigFromJson(json);

  Map<String, dynamic> toJson() => _$LocalConfigToJson(this);
}

LocalConfig readLocalConfig() {
  File file = File(_fileName);
  if (!file.existsSync()) {
    Map<String, dynamic> json = LocalConfig(1, "", "").toJson();
    String str = const JsonEncoder.withIndent("    ").convert(json);
    file.writeAsStringSync(str);
  }
  String str = file.readAsStringSync();
  Map<String, dynamic> json = jsonDecode(str);
  localConfig = LocalConfig.fromJson(json);
  return localConfig;
}
