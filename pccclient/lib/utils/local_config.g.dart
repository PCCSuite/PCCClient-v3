// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalConfig _$LocalConfigFromJson(Map<String, dynamic> json) => LocalConfig(
      json['configVersion'] as int,
      json['serverURL'] as String,
      json['authMethod'] as String,
      json['pluginSysConfig'] as String,
      json['autoRestore'] as bool,
    );

Map<String, dynamic> _$LocalConfigToJson(LocalConfig instance) =>
    <String, dynamic>{
      'configVersion': instance.configVersion,
      'serverURL': instance.serverURL,
      'authMethod': instance.authMethod,
      'pluginSysConfig': instance.pluginSysConfig,
      'autoRestore': instance.autoRestore,
    };
