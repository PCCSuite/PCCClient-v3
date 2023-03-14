import 'dart:async';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'auth.dart';
import 'get_uri.dart';
import 'local_config.dart';

part 'server_info.g.dart';

@JsonSerializable()
class ServerInfo {
  final String authEndpoint;
  final String tokenEndpoint;
  final LoginMethod defaultLoginMethod;
  final String pccSambaURL;
  final String sambaServer;
  final String setBrowserURL;
  final String tipsURL;
  final String attendanceURL;
  final String pluginSysPath;

  ServerInfo(
      this.authEndpoint,
      this.tokenEndpoint,
      this.defaultLoginMethod,
      this.pccSambaURL,
      this.sambaServer,
      this.setBrowserURL,
      this.tipsURL,
      this.attendanceURL,
      this.pluginSysPath);

  factory ServerInfo.fromJson(Map<String, dynamic> json) =>
      _$ServerInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ServerInfoToJson(this);
}

late ServerInfo serverInfo;

Future<ServerInfo> getServerInfo() async {
  String raw = await getStringFromURIString(localConfig.serverInfoURL);
  var json = jsonDecode(raw);
  serverInfo = ServerInfo.fromJson(json);
  return serverInfo;
}
