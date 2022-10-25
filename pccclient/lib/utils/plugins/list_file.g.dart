// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
