import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:pccclient/utils/local_config.dart';

part 'server_info.g.dart';

@JsonSerializable()
class ServerInfo {
  final String tokenEndpoint;
  final String defaultAuthMethod;
  final String getSambaPassURL;
  final String sambaServer;
  final String setBrowserURL;
  final String getTipsAddress;
  final String pccCliManAddress;
  final String pluginSysPath;

  ServerInfo(
      this.tokenEndpoint,
      this.defaultAuthMethod,
      this.getSambaPassURL,
      this.sambaServer,
      this.setBrowserURL,
      this.getTipsAddress,
      this.pccCliManAddress,
      this.pluginSysPath);

  factory ServerInfo.fromJson(Map<String, dynamic> json) =>
      _$ServerInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ServerInfoToJson(this);
}

late ServerInfo serverInfo;

Future<ServerInfo> getServerInfo() async {
  Uri uri = Uri.parse(localConfig.serverInfoURL);
  String raw;
  switch (uri.scheme.toLowerCase()) {
    case "http":
    case "https":
      http.Response response = await http.get(uri);
      raw = response.body;
      var json = jsonDecode(response.body);
      break;
    case "file":
      File file = File.fromUri(uri);
      raw = file.readAsStringSync();
      break;
    default:
      throw UnsupportedError("This uri is not supported");
  }
  var json = jsonDecode(raw);
  serverInfo = ServerInfo.fromJson(json);
  return serverInfo;
}
