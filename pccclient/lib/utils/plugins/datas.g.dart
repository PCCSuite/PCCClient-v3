// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datas.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivePackageData _$ActivePackageDataFromJson(Map<String, dynamic> json) =>
    ActivePackageData(
      json['identifier'] as String,
      json['repository'] as String,
      json['installed'] as bool,
      json['locking'] as bool,
      $enumDecode(_$ActionStatusEnumMap, json['status']),
      json['status_text'] as String,
      json['priority'] as int,
      (json['dependency'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ActivePackageDataToJson(ActivePackageData instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'repository': instance.repositoryName,
      'installed': instance.installed,
      'locking': instance.locking,
      'status': _$ActionStatusEnumMap[instance.status]!,
      'status_text': instance.statusText,
      'priority': instance.priority,
      'dependency': instance.dependency,
    };

const _$ActionStatusEnumMap = {
  ActionStatus.waitStart: 'wait_start',
  ActionStatus.running: 'running',
  ActionStatus.waitDepend: 'wait_depend',
  ActionStatus.waitLock: 'wait_lock',
  ActionStatus.waitAsk: 'wait_ask',
  ActionStatus.done: 'done',
  ActionStatus.failed: 'failed',
};

AskData _$AskDataFromJson(Map<String, dynamic> json) => AskData(
      json['id'] as int,
      json['package'] as String,
      json['plugin'] as String,
      json['type'] as String,
      json['message'] as String,
    );

Map<String, dynamic> _$AskDataToJson(AskData instance) => <String, dynamic>{
      'id': instance.id,
      'package': instance.package,
      'plugin': instance.plugin,
      'type': instance.type,
      'message': instance.message,
    };
