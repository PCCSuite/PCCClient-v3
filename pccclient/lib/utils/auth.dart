import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:pccclient/utils/general.dart';
import 'package:pccclient/utils/server_info.dart';
import 'package:http/http.dart' as http;

import 'local_config.dart';

void getEnv() {
  return;
}

Future<void> getServer() async {
  await getServerInfo();
  return;
}

Uri getTokenEndpoint() {
  var url = serverInfo.tokenEndpoint;
  if (loginState.username != null) {
    url += loginState.username!;
  }
  return Uri.parse(url);
}

void getUser() async {
  var process = await Process.run('wmic',
      ["netuse", "where", "LocalName=\"U:\"", "get", "UserName", "/value"]);
  var result = process.stdout.toString();
  var index = result.indexOf("ts");
  result = result.substring(index, index + 7).replaceAll("ts", "pc");
  return;
}

StateMsgSet getSavedToken() {
  return StateMsgSet(ProcessState.ok, "Remember me未実装");
}

LoginState loginState = LoginState();

class LoginState {
  String? username;
  String? accessToken;
  String? sambaPassword;
}

void parseToken() async {
  String normalizedSource =
      base64Url.normalize(loginState.accessToken!.split(".")[1]);
  String rawJson = utf8.decode(base64Url.decode(normalizedSource));
  var jsonMap = jsonDecode(rawJson);
  loginState.username = jsonMap["preferred_username"];
}

// Future<StateMsgSet> getToken() async {
//   Uri tokenEndpoint = Uri.dataFromString(serverInfo.tokenEndpoint);
//   List<Cookie> addCookies = [];
//   String? loginToken = loginState.loginToken;
//   if (loginToken != null) {
//     addCookies.add(Cookie("KEYCLOAK_IDENTITY", loginToken));
//   }
//   loginState.jar.saveFromResponse(tokenEndpoint, addCookies);
//   HttpClientRequest request = await HttpClient().getUrl(tokenEndpoint);
//   request.cookies.addAll(await loginState.jar.loadForRequest(tokenEndpoint));
//   HttpClientResponse response = await request.close();
//   loginState.jar.saveFromResponse(tokenEndpoint, response.cookies);
//   return StateMsgSet(ProcessState.ok, "トークンの取得成功");
// }

// @JsonSerializable()
// class PasswordData {
//   @JsonKey()
//   final String type;
//   final String data;
//
//   PasswordData(this.type, this.data);
//
//   factory PasswordData.fromJson(Map<String, dynamic> json) => _$PasswordDataFromJson(json);
//
//   Map<String, dynamic> toJson() => _$PasswordDataToJson(this);
// }

Future<void> getSambaPass() async {
  http.Response response = await http.get(Uri.parse(serverInfo.getSambaPassURL),
      headers: {"Authorization": "Bearer ${loginState.accessToken!}"});
  if (response.statusCode != 200) {
    throw Exception("Failed to get token status: ${response.statusCode}, body: ${response.body}");
  }
  var json = jsonDecode(response.body);
  if (json["mode"] is! int) {
    throw Exception("Unexpected password data: $json");
  }
  switch (json["mode"]) {
    case 0:
      loginState.sambaPassword = json["data"];
      break;
    case 1:
      loginState.sambaPassword = json["data"];
      break;
    case 2:
      throw UnimplementedError("Password encryption not supported yet");
    case 3:
      throw UnimplementedError("Password unlisted not supported yet");
    default:
      throw Exception("Unexpected password type: ${json["mode"]}");
  }
}

Future<void> mountSamba() async {
  await _mountCmd(loginState.username!, loginState.sambaPassword!, "${serverInfo.sambaPath}pcc_homes_v3", "A:");
  await _mountCmd(loginState.username!, loginState.sambaPassword!, "${serverInfo.sambaPath}share_v3", "B:");
  return;
}

// letter should "X:"
Future<void> _mountCmd(
    String username, String password, String server, String letter) async {
  List<String> param = ["use", letter, server, password, "/user:$username", "/y"];
  var process = await Process.run(
      'net', param);
  if (process.exitCode != 0) {
    throw Exception(
        "Failed to execute: net ${param.join(" ")}\n${process.stderr} ${process.stdout}");
  }
}
