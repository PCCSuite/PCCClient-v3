// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavoritePlugin _$FavoritePluginFromJson(Map<String, dynamic> json) =>
    FavoritePlugin(
      json['name'] as String,
      json['priority'] as int,
      json['enabled'] as bool,
    );

Map<String, dynamic> _$FavoritePluginToJson(FavoritePlugin instance) =>
    <String, dynamic>{
      'name': instance.name,
      'priority': instance.priority,
      'enabled': instance.enabled,
    };