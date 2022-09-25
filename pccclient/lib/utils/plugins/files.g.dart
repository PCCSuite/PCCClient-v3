// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'files.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PluginSysConfig _$PluginSysConfigFromJson(Map<String, dynamic> json) =>
    PluginSysConfig(
      json['plugins_list'] as String,
      (json['repositories'] as List<dynamic>).map((e) => e as String).toList(),
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
