import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'general.dart';
import 'server_info.dart';
import 'user_settings.dart';

enum LoginMethod {
  browser,
  webview,
  internal;
}

extension LoginMethodExt on LoginMethod {
  String get name {
    switch (this) {
      case LoginMethod.browser:
        return str.login_method_browser;
      case LoginMethod.webview:
        return str.login_method_webview;
      case LoginMethod.internal:
        return str.login_method_internal;
    }
  }
}

class NeedLoginExeption implements Exception {}

class LoginState {
  String accessToken;
  DateTime accessTokenPeriod;
  String refreshToken;
  DateTime refreshTokenPeriod;

  LoginState(this.accessToken, this.accessTokenPeriod, this.refreshToken,
      this.refreshTokenPeriod);
}

void saveRefreshToken() {
  if (userSettings.appAutoLogin) {
    userSettings.appRefreshToken = _loginState!.refreshToken;
    userSettings.appRefreshTokenPeriod =
        _loginState!.refreshTokenPeriod.millisecondsSinceEpoch;
    saveUserSettings();
  }
}

LoginState? _loginState;

Future<bool> initAuth() async {
  if (userSettings.appAutoLogin) {
    _loginState = LoginState(
        "",
        DateTime.fromMillisecondsSinceEpoch(0),
        userSettings.appRefreshToken,
        DateTime.fromMillisecondsSinceEpoch(
            userSettings.appRefreshTokenPeriod));
    try {
      await getToken();
      _parseToken();
    } on NeedLoginExeption {
      _loginState = null;
    }
  }
  if (_username != "") {
    return true;
  }
  return await _getUser();
}

bool get tokenAvailable {
  if (_loginState == null) return false;
  if (!_loginState!.refreshTokenPeriod.isAfter(DateTime.now())) {
    _loginState = null;
    return false;
  }
  return true;
}

set loginState(LoginState s) {
  _loginState = s;
  _parseToken();
  saveRefreshToken();
}

void _parseToken() {
  String rawJson = utf8.decode(base64Url
      .decode(base64Url.normalize(_loginState!.accessToken.split(".")[1])));
  var jsonMap = jsonDecode(rawJson);
  _username = jsonMap["preferred_username"];
  var rolesArray = jsonMap["resource_access"]?["samba"]?["roles"];
  if (rolesArray != null) {
    _sambaRoles = List<String>.from(rolesArray);
  }
}

String _username = "";

String get username => _username;

List<String> _sambaRoles = [];

List<String> get sambaRoles => _sambaRoles;

Future<void> getServer() async {
  await getServerInfo();
  return;
}

const oAuthScope = "samba offline_access";

Uri getAuthEndpoint(
    {String redirectUri = "http://127.0.0.1:15456/return",
    required String state}) {
  var param = <String, String>{
    "client_id": "pccclient",
    "response_type": "code",
    "scope": oAuthScope,
    "redirect_uri": redirectUri,
    "state": state,
  };
  if (username != "") {
    param["login_hint"] = username;
  }
  return Uri.parse(serverInfo.authEndpoint).replace(queryParameters: param);
}

Future<String> getToken() async {
  var state = _loginState;
  if (state == null) {
    throw NeedLoginExeption();
  }
  if (state.accessTokenPeriod.isAfter(DateTime.now())) {
    return state.accessToken;
  }
  if (!state.refreshTokenPeriod.isAfter(DateTime.now())) {
    _loginState = null;
    throw NeedLoginExeption();
  }
  var body = <String, String>{
    "client_id": "pccclient",
    "grant_type": "refresh_token",
    "refresh_token": state.refreshToken,
  };
  Uri tokenEndpoint = Uri.parse(serverInfo.tokenEndpoint);
  DateTime now = DateTime.now();
  var resp = await http.post(tokenEndpoint, body: body);
  if (resp.statusCode != 200) {
    _loginState = null;
    throw NeedLoginExeption();
  }
  Map<String, dynamic> result = jsonDecode(resp.body);
  state.accessToken = result["access_token"];
  state.accessTokenPeriod = now.add(Duration(seconds: result["expires_in"]));
  state.refreshToken = result["refresh_token"];
  state.refreshTokenPeriod =
      now.add(Duration(seconds: result["refresh_expires_in"]));
  saveRefreshToken();
  return state.accessToken;
}

Future<bool> _getUser() async {
  if (!Platform.isWindows) {
    return false;
  }
  var process = await Process.run('wmic',
      ["netuse", "where", "LocalName=\"U:\"", "get", "UserName", "/value"]);
  var result = process.stdout.toString();
  var index = result.indexOf("ts");
  if (index == -1) {
    return false;
  }
  _username = result.substring(index, index + 7).replaceAll("ts", "pc");
  return true;
}
