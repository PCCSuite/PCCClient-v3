// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) => UserSettings(
      json['settingVersion'] as int? ?? 1,
      json['appAutoLogin'] as bool? ?? false,
      json['appRefreshToken'] as String? ?? '',
      json['appRefreshTokenPeriod'] as int? ?? 0,
      $enumDecodeNullable(_$LoginMethodEnumMap, json['loginMethod']),
      json['pluginSysConfig'] as String? ?? '',
      json['pluginAutoRestore'] as bool? ?? true,
      json['pluginDevMode'] as bool? ?? false,
      json['debugMode'] as bool? ?? false,
    );

Map<String, dynamic> _$UserSettingsToJson(UserSettings instance) =>
    <String, dynamic>{
      'settingVersion': instance.settingVersion,
      'appAutoLogin': instance.appAutoLogin,
      'appRefreshToken': instance.appRefreshToken,
      'appRefreshTokenPeriod': instance.appRefreshTokenPeriod,
      'loginMethod': _$LoginMethodEnumMap[instance.loginMethod],
      'pluginSysConfig': instance.pluginSysConfig,
      'pluginAutoRestore': instance.pluginAutoRestore,
      'pluginDevMode': instance.pluginDevMode,
      'debugMode': instance.debugMode,
    };

const _$LoginMethodEnumMap = {
  LoginMethod.browser: 'browser',
  LoginMethod.webview: 'webview',
  LoginMethod.internal: 'internal',
};
