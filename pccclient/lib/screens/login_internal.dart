import 'dart:convert';

import 'package:flutter/material.dart';
import '../utils/auth.dart';
import '../utils/general.dart';
import '../utils/server_info.dart';
import 'loggingin.dart';
import 'login_select.dart';
import 'part/error.dart';
import 'part/tips.dart';
import 'package:http/http.dart' as http;

class LoginInternalScreen extends StatefulWidget {
  const LoginInternalScreen({Key? key}) : super(key: key);

  static const routeName = "/login_internal";

  static final screenName = str.login_internal_title;

  @override
  State<LoginInternalScreen> createState() => _LoginInternalScreenState();
}

class _LoginInternalScreenState extends State<LoginInternalScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String status = str.login_internal_status_wait;
  bool isChangeable = true;

  late String _username;
  late String _password;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        status = str.login_internal_status_running;
        isChangeable = false;
      });
      _formKey.currentState!.save();
      try {
        var body = <String, String>{
          "client_id": "pccclient",
          "grant_type": "password",
          "scope": oAuthScope,
          "username": _username,
          "password": _password,
        };
        Uri tokenEndpoint = Uri.parse(serverInfo.tokenEndpoint);
        DateTime now = DateTime.now();
        var resp = await http.post(tokenEndpoint, body: body);
        Map<String, dynamic> result = jsonDecode(resp.body);
        if (resp.statusCode == 401 && result["error"] == "invalid_grant") {
          setState(() {
            status = "Error: ${str.login_internal_status_invalid_credentials}";
            isChangeable = true;
          });
          return;
        }
        if (resp.statusCode != 200) {
          throw Exception(
              "token endpoint failed ${resp.statusCode}: ${resp.body}");
        }
        loginState = LoginState(
            result["access_token"],
            now.add(Duration(seconds: result["expires_in"])),
            result["refresh_token"],
            now.add(Duration(seconds: result["refresh_expires_in"])));
        setState(() {
          status = str.login_internal_status_done;
          Navigator.popUntil(
              context, ModalRoute.withName(LoginSelectScreen.routeName));
          Navigator.pushNamed(context, LoggingInScreen.routeName);
        });
      } catch (err, trace) {
        showError(context, err, trace);
        setState(() {
          status = "Error: $err";
          isChangeable = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LoginInternalScreen.screenName),
      ),
      bottomNavigationBar: getTipsBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  "Login",
                  textScaleFactor: 4.0,
                ),
                TextFormField(
                  initialValue: username,
                  autofocus: username == "",
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: str.login_internal_username,
                    hintText: 'pcXXXXX',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter username';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _username = val!;
                  },
                  style: const TextStyle(
                    fontSize: 32.0,
                  ),
                ),
                TextFormField(
                  autofocus: username != "",
                  onFieldSubmitted: (_) {
                    _submit();
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: str.login_internal_password,
                    hintText: 'Enter your password',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _password = val!;
                  },
                  style: const TextStyle(
                    fontSize: 32.0,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        status,
                        // overflow: TextOverflow.ellipsis,
                        textScaleFactor: 2.0,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isChangeable
                          ? () {
                              _submit();
                            }
                          : null,
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            str.login_internal_submit,
                            textScaleFactor: 2.0,
                          )),
                    ),
                  ],
                )
              ],
            )),
      ),
    );
  }
}
