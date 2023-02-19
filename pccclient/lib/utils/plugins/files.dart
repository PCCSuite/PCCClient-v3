import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import '../../screens/part/form_field.dart';
import '../local_config.dart';
import '../server_info.dart';
import 'package:xml/xml.dart';

import 'package:path/path.dart' as path;

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

class PluginXml {
  final String name;
  final String version;
  final String description;
  final String author;
  final String licence;
  final List<String> dependency;
  final List<PluginButtonData> buttons;
  final List<PluginFormFieldData> config;

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
    XmlElement? buttons = plugin.getElement("buttons");
    List<PluginButtonData> buttonList = [];
    if (buttons != null) {
      for (var buttonItem in buttons.childElements) {
        buttonList.add(PluginButtonData.fromXml(buttonItem));
      }
    }
    XmlElement? config = plugin.getElement("config");
    List<PluginFormFieldData> configList = [];
    if (config != null) {
      for (var configItem in config.childElements) {
        configList.add(PluginFormFieldData.fromXml(configItem));
      }
    }
    return PluginXml(
        general.getElement("name")!.innerText,
        general.getElement("version")!.innerText,
        description,
        general.getElement("plugin_author")!.innerText,
        general.getElement("plugin_licence")!.innerText,
        dependencyList,
        buttonList,
        configList);
  }

  String get dataDir {
    return path.join(pluginSysConfig.dataDir, name);
  }

  PluginXml(this.name, this.version, this.description, this.author,
      this.licence, this.dependency, this.buttons, this.config);
}

class PluginButtonData {
  final String name;
  final String action;
  final List<PluginFormFieldData> form;

  factory PluginButtonData.fromXml(XmlElement xml) {
    String name = xml.getElement("name")!.innerText;
    String action = xml.getElement("action")!.innerText;
    XmlElement? formData = xml.getElement("form");
    List<PluginFormFieldData> form = [];
    if (formData != null) {
      for (var field in formData.childElements) {
        form.add(PluginFormFieldData.fromXml(field));
      }
    }
    return PluginButtonData(name, action, form);
  }

  PluginButtonData(this.name, this.action, this.form);
}

class PluginFormFieldData {
  final PluginFormFieldType type;
  final String? filePicker;
  final String id;
  final String? title;
  final String? description;
  final String? label;
  final String? hint;
  final String? initial;

  factory PluginFormFieldData.fromXml(XmlElement xml) {
    PluginFormFieldType type =
        PluginFormFieldType.values.byName(xml.getAttribute("type")!);
    String? filePicker = xml.getAttribute("file_picker");
    String id = xml.getElement("id")!.innerText;
    String? title = xml.getElement("title")?.innerText;
    String? description = xml.getElement("description")?.innerText;
    String? label = xml.getElement("label")?.innerText;
    String? hint = xml.getElement("hint")?.innerText;
    String? initial = xml.getElement("initial")?.innerText;
    return PluginFormFieldData(
        type, filePicker, id, title, description, label, hint, initial);
  }

  PluginFormFieldData(this.type, this.filePicker, this.id, this.title,
      this.description, this.label, this.hint, this.initial);
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
    await File("${serverInfo.pluginSysPath}\\plugins.json")
        .copy(pluginSysConfig.pluginsList);
  }
  String str = await file.readAsString();
  var jsonRaw = jsonDecode(str);
  favoritePlugins = (jsonRaw["plugins"] as List<dynamic>)
      .map((element) => FavoritePlugin.fromJson(element))
      .toList();
  return favoritePlugins;
}

Future<void> saveFavoritePlugins() async {
  var jsonRaw = const JsonEncoder.withIndent("	")
      .convert({"plugins": favoritePlugins.map((e) => e.toJson()).toList()});
  File file = File(pluginSysConfig.pluginsList);
  await file.writeAsString(jsonRaw);
}
