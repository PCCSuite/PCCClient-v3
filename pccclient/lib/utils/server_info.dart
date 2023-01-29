import 'dart:async';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:pccclient/utils/get_uri.dart';
import 'package:pccclient/utils/local_config.dart';

part 'server_info.g.dart';

@JsonSerializable()
class ServerInfo {
  final String tokenEndpoint;
  final String defaultAuthMethod;
  final String getSambaPassURL;
  final String sambaServer;
  final String setBrowserURL;
  final String tipsURL;
  final String pccCliManAddress;
  final String pluginSysPath;

  ServerInfo(
      this.tokenEndpoint,
      this.defaultAuthMethod,
      this.getSambaPassURL,
      this.sambaServer,
      this.setBrowserURL,
      this.tipsURL,
      this.pccCliManAddress,
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
