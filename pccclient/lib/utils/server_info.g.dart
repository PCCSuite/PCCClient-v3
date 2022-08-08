// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerInfo _$ServerInfoFromJson(Map<String, dynamic> json) => ServerInfo(
      json['tokenEndpoint'] as String,
      json['defaultAuthMethod'] as String,
      json['getSambaPassURL'] as String,
      json['sambaPath'] as String,
      json['setBrowserURL'] as String,
      json['getTipsAddress'] as String,
      json['pccCliManAddress'] as String,
    );

Map<String, dynamic> _$ServerInfoToJson(ServerInfo instance) =>
    <String, dynamic>{
      'tokenEndpoint': instance.tokenEndpoint,
      'defaultAuthMethod': instance.defaultAuthMethod,
      'getSambaPassURL': instance.getSambaPassURL,
      'sambaPath': instance.sambaPath,
      'setBrowserURL': instance.setBrowserURL,
      'getTipsAddress': instance.getTipsAddress,
      'pccCliManAddress': instance.pccCliManAddress,
    };
