import 'dart:async';
import 'dart:convert';

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
  // http.Response response;
  // response = await http.get(Uri.parse(localConfig.serverURL));
  // var json = jsonDecode(response.body);
  // serverInfo = ServerInfo.fromJson(json);
  serverInfo = ServerInfo(
      "http://pccs1.tama-st-h.local/keycloak/realms/pcc/protocol/openid-connect/auth?client_id=pccclient&response_type=token&scope=samba&redirect_uri=http%3A%2F%2Flocalhost%3A15456%2Freturn&response_mode=form_post&login_hint=",
      "browser",
      "http://pccs2.tama-st-h.local:8081/getPassword",
      "pccs2.tama-st-h.local",
      "http://pccs1.tama-st-h.local/",
      "pccs1.tama-st-h.local",
      "ws://pccs1.tama-st-h.local:8081/pccclient",
      "B:\\PCCPlugin\\sys");
  return serverInfo;
}
