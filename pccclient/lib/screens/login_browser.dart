import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/auth.dart';
import 'loggingin.dart';
import 'login_select.dart';
import 'part/error.dart';
import 'part/tips.dart';
import '../utils/auth.dart';
import '../utils/general.dart';
import '../utils/server_info.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginBrowserScreen extends StatefulWidget {
  const LoginBrowserScreen({Key? key}) : super(key: key);

  static const routeName = "/login_browser";

  @override
  State<LoginBrowserScreen> createState() => _LoginBrowserScreenState();
}

class _LoginBrowserScreenState extends State<LoginBrowserScreen> {
  String status = "Initializing...";

  HttpServer? _server;

  static const String redirectUri = "http://127.0.0.1:15456/return";
  String stateParam = generateRandomString(64);

  @override
  void initState() {
    _startServer();
    super.initState();
  }

  @override
  void dispose() {
    _server?.close();
    super.dispose();
  }

  void _startServer() async {
    var serverFuture = HttpServer.bind(InternetAddress.loopbackIPv4, 15456);
    setState(() {
      status = str.login_browser_starting_server;
    });
    try {
      _server = await serverFuture;
      _server!.listen((request) async {
        var uri = request.uri;
        if (uri.path != "/return") {
          request.response.statusCode = 404;
          request.response
              .write("This is PCCClient internal server for authentication");
          request.response.close();
          return;
        }
        var code = request.uri.queryParameters["code"];
        if (code == null) {
          request.response.statusCode = 400;
          request.response.write(str.login_browser_response_failed);
          request.response.close();
          setState(() {
            status =
                "${str.login_browser_failed}\nrequest doesn't contain code";
          });
          return;
        }
        var respState = request.uri.queryParameters["state"];
        if (respState == null) {
          request.response.statusCode = 400;
          request.response.write(str.login_browser_response_failed);
          request.response.close();
          setState(() {
            status =
                "${str.login_browser_failed}\nrequest doesn't contain state";
          });
          return;
        }
        if (respState != stateParam) {
          request.response.statusCode = 400;
          request.response.write(str.login_browser_response_failed);
          request.response.close();
          setState(() {
            status = "${str.login_browser_failed}\nstate verification failed";
          });
          return;
        }
        var body = <String, String>{
          "client_id": "pccclient",
          "grant_type": "authorization_code",
          "code": code,
          "redirect_uri": redirectUri,
        };
        Uri tokenEndpoint = Uri.parse(serverInfo.tokenEndpoint);
        DateTime now = DateTime.now();
        var resp = await http.post(tokenEndpoint, body: body);
        if (resp.statusCode != 200) {
          request.response.statusCode = 400;
          request.response.write(str.login_browser_response_failed);
          request.response.close();
          setState(() {
            status =
                "${str.login_browser_failed}\ntoken endpoint failed ${resp.statusCode}: ${resp.body}";
          });
          return;
        }
        Map<String, dynamic> result = jsonDecode(resp.body);
        loginState = LoginState(
            result["access_token"],
            now.add(Duration(seconds: result["expires_in"])),
            result["refresh_token"],
            now.add(Duration(seconds: result["refresh_expires_in"])));

        request.response.statusCode = 200;
        request.response.headers.contentType =
            ContentType("text", "html", charset: "utf-8");
        request.response.write("<script>window.close()</script>");
        request.response
            .write("<h1>${str.login_browser_response_success}</h1>");
        request.response.close();
        setState(() {
          status = str.login_browser_success;
          Navigator.popUntil(
              context, ModalRoute.withName(LoginSelectScreen.routeName));
          Navigator.pushNamed(context, LoggingInScreen.routeName);
        });
      });
      setState(() {
        status = str.login_browser_server_started;
      });
      _openBrowser();
    } catch (err, trace) {
      showError(context, err, trace);
      setState(() {
        status = str.login_browser_server_start_failed;
      });
    }
  }

  void _openBrowser() async {
    var openBrowser =
        launchUrl(getAuthEndpoint(redirectUri: redirectUri, state: stateParam));
    setState(() {
      status = str.login_browser_launching_browser;
    });
    try {
      if (!(await openBrowser)) {
        throw "launchUrl return false";
      }
      setState(() {
        status = str.login_browser_launched_browser;
      });
    } catch (err, trace) {
      showError(context, err, trace);
      setState(() {
        status = str.login_browser_launch_browser_failed;
      });
    }
  }

  void _copyURL() async {
    final data = ClipboardData(text: serverInfo.tokenEndpoint);
    await Clipboard.setData(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(str.login_browser_title),
      ),
      bottomNavigationBar: getTipsBar(),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            status,
            textScaleFactor: 2.0,
          ),
          Text(
            serverInfo.tokenEndpoint,
            textScaleFactor: 0.9,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _openBrowser();
                },
                child: Text(str.login_browser_relaunch_browser),
              ),
              ElevatedButton(
                onPressed: () {
                  _copyURL();
                },
                child: Text(str.login_browser_copy_url),
              )
            ],
          )
        ],
      )),
    );
  }
}
