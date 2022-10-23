import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:pccclient/utils/plugins/files.dart';

part 'list_file.g.dart';

List<FavoritePlugin> favoritePlugins = [];

@JsonSerializable()
class FavoritePlugin {
  FavoritePlugin(this.name, this.priority, this.enabled);

  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "priority")
  final int priority;
  @JsonKey(name: "enabled")
  final bool enabled;

  factory FavoritePlugin.fromJson(Map<String, dynamic> json) =>
      _$FavoritePluginFromJson(json);

  Map<String, dynamic> toJson() => _$FavoritePluginToJson(this);
}

Future<List<FavoritePlugin>> loadFavoritePlugins() async {
  File file = File(pluginSysConfig.pluginsList);
  String str = await file.readAsString();
  var jsonRaw = jsonDecode(str);
  favoritePlugins = (jsonRaw["plugins"] as List<dynamic>).map((element) => FavoritePlugin.fromJson(element)).toList();
  return favoritePlugins;
}

Future<void> saveFavoritePlugins() async {
  var jsonRaw = jsonEncode({"plugins": favoritePlugins.map((e) => e.toJson())});
  File file = File(pluginSysConfig.pluginsList);
  await file.writeAsString(jsonRaw);
}