// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerInfo _$ServerInfoFromJson(Map<String, dynamic> json) => ServerInfo(
      json['authEndpoint'] as String,
      json['tokenEndpoint'] as String,
      $enumDecode(_$LoginMethodEnumMap, json['defaultLoginMethod']),
      json['pccSambaURL'] as String,
      json['sambaServer'] as String,
      json['setBrowserURL'] as String,
      json['tipsURL'] as String,
      json['attendanceURL'] as String,
      json['pluginSysPath'] as String,
    );

Map<String, dynamic> _$ServerInfoToJson(ServerInfo instance) =>
    <String, dynamic>{
      'authEndpoint': instance.authEndpoint,
      'tokenEndpoint': instance.tokenEndpoint,
      'defaultLoginMethod': _$LoginMethodEnumMap[instance.defaultLoginMethod]!,
      'pccSambaURL': instance.pccSambaURL,
      'sambaServer': instance.sambaServer,
      'setBrowserURL': instance.setBrowserURL,
      'tipsURL': instance.tipsURL,
      'attendanceURL': instance.attendanceURL,
      'pluginSysPath': instance.pluginSysPath,
    };

const _$LoginMethodEnumMap = {
  LoginMethod.browser: 'browser',
  LoginMethod.webview: 'webview',
  LoginMethod.internal: 'internal',
};
