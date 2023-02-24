import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth.dart';
import 'server_info.dart';

late int sambaMode;
late String sambaPassword;

Future<void> getSambaPass() async {
  http.Response response = await http.get(
      Uri.parse("${serverInfo.pccSambaURL}getPassword"),
      headers: {"Authorization": "Bearer ${await getToken()}"});
  if (response.statusCode != 200) {
    throw Exception(
        "Failed to get token status: ${response.statusCode}, body: ${response.body}");
  }
  var json = jsonDecode(response.body);
  if (json["mode"] is! int) {
    throw Exception("Unexpected password data: $json");
  }
  sambaMode = json["mode"];
  switch (sambaMode) {
    case 1:
      sambaPassword = json["data"];
      break;
    case 2:
      sambaPassword = json["data"];
      break;
    case 3:
      throw UnimplementedError("Password encryption not supported yet");
    case 4:
      throw UnimplementedError("Password unlisted not supported yet");
    default:
      throw Exception("Unexpected password type: ${json["mode"]}");
  }
}

Future<void> setSambaPass(int mode, String password) async {
  Map<String, dynamic> jsonMap = {};
  jsonMap["mode"] = mode;
  jsonMap["password"] = password;
  var json = jsonEncode(jsonMap);
  http.Response response = await http.post(
    Uri.parse("${serverInfo.pccSambaURL}setPassword"),
    headers: {
      "Authorization": "Bearer ${await getToken()}",
      "Content-Type": "application/json",
    },
    body: json,
  );
  if (response.statusCode != 204) {
    throw Exception(
        "Failed to set samba password: ${response.statusCode}, body: ${response.body}");
  }
  sambaMode = mode;
  sambaPassword = password;
}
