// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datas.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivePluginData _$ActivePluginDataFromJson(Map<String, dynamic> json) =>
    ActivePluginData(
      json['name'] as String,
      json['repository'] as String,
      json['installed'] as bool,
      json['locking'] as bool,
      $enumDecode(_$ActionStatusEnumMap, json['status']),
      json['status_text'] as String,
      (json['dependency'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ActivePluginDataToJson(ActivePluginData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'repository': instance.repository,
      'installed': instance.installed,
      'locking': instance.locking,
      'status': _$ActionStatusEnumMap[instance.status]!,
      'status_text': instance.statusText,
      'dependency': instance.dependency,
    };

const _$ActionStatusEnumMap = {
  ActionStatus.loaded: 'loaded',
  ActionStatus.waitStart: 'wait_start',
  ActionStatus.running: 'running',
  ActionStatus.waitDepend: 'wait_depend',
  ActionStatus.waitLock: 'wait_lock',
  ActionStatus.done: 'done',
  ActionStatus.failed: 'failed',
};
