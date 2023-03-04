import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

import 'auth.dart';

part 'user_settings.g.dart';

const String _fileName = "pccclient_settings.json";

UserSettings userSettings =
    UserSettings(1, false, "", 0, null, "", true, false, false);

@JsonSerializable()
class UserSettings {
  @JsonKey(defaultValue: 1)
  int settingVersion;
  @JsonKey(defaultValue: false)
  bool appAutoLogin;
  @JsonKey(defaultValue: "")
  String appRefreshToken;
  // unix epoch mili
  @JsonKey(defaultValue: 0)
  int appRefreshTokenPeriod;

  @JsonKey(defaultValue: null)
  LoginMethod? loginMethod;

  @JsonKey(defaultValue: "")
  String pluginSysConfig;
  @JsonKey(defaultValue: true)
  bool pluginAutoRestore;

  @JsonKey(defaultValue: false)
  bool pluginDevMode;
  @JsonKey(defaultValue: false)
  bool debugMode;

  UserSettings(
      this.settingVersion,
      this.appAutoLogin,
      this.appRefreshToken,
      this.appRefreshTokenPeriod,
      this.loginMethod,
      this.pluginSysConfig,
      this.pluginAutoRestore,
      this.pluginDevMode,
      this.debugMode);

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);
}

UserSettings loadUserSettings() {
  File file = File(_fileName);
  if (!file.existsSync()) {
    return userSettings;
  }
  String str = file.readAsStringSync();
  Map<String, dynamic> json = jsonDecode(str);
  userSettings = UserSettings.fromJson(json);
  return userSettings;
}

void saveUserSettings() {
  File file = File(_fileName);
  Map<String, dynamic> json = userSettings.toJson();
  String str = const JsonEncoder.withIndent("    ").convert(json);
  file.writeAsStringSync(str);
}
