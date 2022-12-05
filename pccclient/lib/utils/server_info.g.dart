// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerInfo _$ServerInfoFromJson(Map<String, dynamic> json) => ServerInfo(
      json['tokenEndpoint'] as String,
      json['defaultAuthMethod'] as String,
      json['getSambaPassURL'] as String,
      json['sambaServer'] as String,
      Map<String, String>.from(json['sambaShares'] as Map),
      json['setBrowserURL'] as String,
      json['tipsURL'] as String,
      json['pccCliManAddress'] as String,
      json['pluginSysPath'] as String,
    );

Map<String, dynamic> _$ServerInfoToJson(ServerInfo instance) =>
    <String, dynamic>{
      'tokenEndpoint': instance.tokenEndpoint,
      'defaultAuthMethod': instance.defaultAuthMethod,
      'getSambaPassURL': instance.getSambaPassURL,
      'sambaServer': instance.sambaServer,
      'sambaShares': instance.sambaShares,
      'setBrowserURL': instance.setBrowserURL,
      'tipsURL': instance.tipsURL,
      'pccCliManAddress': instance.pccCliManAddress,
      'pluginSysPath': instance.pluginSysPath,
    };
