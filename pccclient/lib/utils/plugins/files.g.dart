// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'files.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PluginSysConfig _$PluginSysConfigFromJson(Map<String, dynamic> json) =>
    PluginSysConfig(
      json['plugins_list'] as String,
      Map<String, String>.from(json['repositories'] as Map),
      json['data_dir'] as String,
      json['temp_dir'] as String,
    );

Map<String, dynamic> _$PluginSysConfigToJson(PluginSysConfig instance) =>
    <String, dynamic>{
      'plugins_list': instance.pluginsList,
      'repositories': instance.repositories,
      'data_dir': instance.dataDir,
      'temp_dir': instance.tempDir,
    };

FavoritePlugin _$FavoritePluginFromJson(Map<String, dynamic> json) =>
    FavoritePlugin(
      json['identifier'] as String,
      json['priority'] as int,
      json['enabled'] as bool,
    );

Map<String, dynamic> _$FavoritePluginToJson(FavoritePlugin instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'priority': instance.priority,
      'enabled': instance.enabled,
    };
