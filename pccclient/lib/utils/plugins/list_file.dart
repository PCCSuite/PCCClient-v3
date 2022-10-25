import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:pccclient/utils/plugins/files.dart';

part 'list_file.g.dart';

List<FavoritePlugin> favoritePlugins = [];

@JsonSerializable()
class FavoritePlugin {
  FavoritePlugin(this.identifier, this.priority, this.enabled);

  @JsonKey(name: "identifier")
  final String identifier;
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
  var jsonRaw = const JsonEncoder.withIndent("	").convert({"plugins": favoritePlugins.map((e) => e.toJson()).toList()});
  File file = File(pluginSysConfig.pluginsList);
  await file.writeAsString(jsonRaw);
}