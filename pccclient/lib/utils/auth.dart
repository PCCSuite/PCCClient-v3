import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:pccclient/utils/general.dart';
import 'package:pccclient/utils/server_info.dart';

import '../screens/login_select.dart';

StateMsgSet getEnv() {
  return StateMsgSet(ProcessState.ok, "環境チェック未実装");
}

StateMsgSet getServer() {
  getServerInfo();
  return StateMsgSet(ProcessState.ok, "サーバー情報固定");
}

Uri getTokenEndpoint() {
  var url = serverInfo.tokenEndpoint;
  if (loginState.username != null) {
    url += loginState.username!;
  }
  return Uri.dataFromString(url);
}

Future<StateMsgSet> getUser() async {
  try {
    var process = await Process.run('wmic', ["netuse", "where", "LocalName=\"U:\"", "get", "UserName", "/value"]);
    var result = process.stdout.toString();
    var index = result.indexOf("ts");
    loginState.username = result.substring(index, index+7);
  } catch (e) {
    print(e.toString());
    return StateMsgSet(ProcessState.failed, str.init_check_username_fail);
  }
  return StateMsgSet(ProcessState.ok, str.init_checked_username);
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

StateMsgSet getSambaPass() {
  return StateMsgSet(ProcessState.ok, str.loggingin_got_password);
}

StateMsgSet mountSamba() {
  return StateMsgSet(ProcessState.ok, str.loggingin_mounted);
}