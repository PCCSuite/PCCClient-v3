import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:pccclient/utils/local_config.dart';
import 'package:pccclient/utils/server_info.dart';
import 'package:xml/xml.dart';

part 'files.g.dart';

late PluginSysConfig pluginSysConfig;

@JsonSerializable()
class PluginSysConfig {
  PluginSysConfig(
      this.pluginsList, this.repositories, this.dataDir, this.tempDir);

  @JsonKey(name: "plugins_list")
  final String pluginsList;
  @JsonKey(name: "repositories")
  final Map<String, String> repositories;
  @JsonKey(name: "data_dir")
  final String dataDir;
  @JsonKey(name: "temp_dir")
  final String tempDir;

  factory PluginSysConfig.fromJson(Map<String, dynamic> json) =>
      _$PluginSysConfigFromJson(json);

  Map<String, dynamic> toJson() => _$PluginSysConfigToJson(this);
}

Future<void> loadPluginSysConfig() async {
  var configPath = "${serverInfo.pluginSysPath}\\config.json";
  if (localConfig.pluginSysConfig.isNotEmpty) {
    configPath = localConfig.pluginSysConfig;
  }
  File configFile = File(configPath);
  String str = await configFile.readAsString();
  var jsonRaw = jsonDecode(str);
  pluginSysConfig = PluginSysConfig.fromJson(jsonRaw);

  for (var dir in pluginSysConfig.repositories.values) {
    await Directory(dir).create(recursive: true);
  }

  await loadFavoritePlugins();
}

Map<String, PluginXml> pluginXmls = {};

class PluginXml {
  final String name;
  final String version;
  final String description;
  final String author;
  final String licence;
  final List<String> dependency;
  final List<PluginConfigItem> config;

  factory PluginXml.fromXml(XmlDocument xml) {
    XmlElement plugin = xml.getElement("plugin")!;
    XmlElement general = plugin.getElement("general")!;
    List<String> splitDesc =
        general.getElement("description")!.innerText.trim().split("\n");
    String description = splitDesc.map((e) => e.trim()).join("\n");
    XmlElement dependency = plugin.getElement("dependency")!;
    List<String> dependencyList = [];
    for (var dependent in dependency.childElements) {
      dependencyList.add(dependent.text);
    }
    XmlElement? config = plugin.getElement("config");
    List<PluginConfigItem> configList = [];
    if (config != null) {
      for (var configItem in config.childElements) {
        var attrs = configItem.attributes;
        String id = "", type = "", hint = "";
        for (var attr in attrs) {
          switch (attr.name.local) {
            case "id":
              id = attr.value;
              break;
            case "type":
              type = attr.value;
              break;
            case "hint":
              hint = attr.value;
              break;
          }
        }
        configList.add(PluginConfigItem(id, type, hint, configItem.innerText));
      }
    }
    return PluginXml(
        general.getElement("name")!.innerText,
        general.getElement("version")!.innerText,
        description,
        general.getElement("plugin_author")!.innerText,
        general.getElement("plugin_licence")!.innerText,
        dependencyList,
        configList);
  }

  PluginXml(this.name, this.version, this.description, this.author,
      this.licence, this.dependency, this.config);
}

class PluginConfigItem {
  final String id;
  final String type;
  final String hint;
  final String name;

  PluginConfigItem(this.id, this.type, this.hint, this.name);
}

Future<PluginXml> loadPluginXml(String path) async {
  File xmlFile = File(path);
  XmlDocument xml = XmlDocument.parse(await xmlFile.readAsString());
  return PluginXml.fromXml(xml);
}


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
  if (!await file.exists()) {
    await File("${serverInfo.pluginSysPath}\\plugins.json").copy(pluginSysConfig.pluginsList);
  }
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