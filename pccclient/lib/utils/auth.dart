import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:pccclient/utils/general.dart';
import 'package:pccclient/utils/server_info.dart';
import 'package:http/http.dart' as http;

import 'local_config.dart';

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

Future<bool> getUser() async {
  if (!Platform.isWindows) {
    return false;
  }
  var process = await Process.run('wmic',
      ["netuse", "where", "LocalName=\"U:\"", "get", "UserName", "/value"]);
  var result = process.stdout.toString();
  var index = result.indexOf("ts");
  result = result.substring(index, index + 7).replaceAll("ts", "pc");
  return true;
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
  if (Platform.isWindows) {
    await _mountWindows();
    return;
  }
  if (Platform.isLinux) {
    await _mountLinux();
    return;
  }
  throw UnimplementedError("Unsupported platform to mount");
}

Future<void> _mountWindows() async {
  await _mountWindowsCmd(loginState.username!, loginState.sambaPassword!, "\\\\${serverInfo.sambaServer}\\pcc_homes_v3", "A:");
  await _mountWindowsCmd(loginState.username!, loginState.sambaPassword!, "\\\\${serverInfo.sambaServer}\\share_v3", "B:");
}

// letter should "X:"
Future<void> _mountWindowsCmd(
    String username, String password, String path, String letter) async {
  List<String> param = ["use", letter, path, password, "/user:$username", "/y"];
  var process = await Process.run(
      'net', param);
  if (process.exitCode != 0) {
    throw Exception(
        "Failed to execute: net ${param.join(" ")}\n${process.stderr} ${process.stdout}");
  }
}

Future<void> _mountLinux() async {
  await _mountLinuxCmd(loginState.username!, loginState.sambaPassword!, serverInfo.sambaServer, "pcc_homes_v3");
  await _mountLinuxCmd(loginState.username!, loginState.sambaPassword!, serverInfo.sambaServer, "share_v3");
}

Future<void> _mountLinuxCmd(
    String username, String password, String server, String name) async {
  List<String> param = ["mount", "smb://$username:$password@$server/$name"];
  var process = await Process.run('gio', param);
  if (process.exitCode != 0) {
    throw Exception("Failed to mount: gio ${param.join(" ")}\n${process.stderr} ${process.stdout}");
  }
}
