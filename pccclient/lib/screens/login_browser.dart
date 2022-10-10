import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pccclient/screens/loggingin.dart';
import 'package:pccclient/screens/part/error.dart';
import 'package:pccclient/utils/auth.dart';
import 'package:pccclient/utils/general.dart';
import 'package:pccclient/utils/server_info.dart';
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
        var bodyRaw = await utf8.decoder.bind(request).join();
        var params = Uri(query: bodyRaw).queryParameters;
        if (params["access_token"] != null) {
          request.response.statusCode = 200;
          request.response.headers.contentType =
              ContentType("text", "html", charset: "utf-8");
          request.response.write("<script>window.close()</script>");
          request.response.write("<h1>${str.login_browser_response_success}</h1>");
          request.response.close();
          loginState.accessToken = params["access_token"];
          parseToken();
          setState(() {
            status = str.login_browser_success;
            Navigator.pushNamed(context, LoggingInScreen.routeName);
          });
        } else {
          request.response.statusCode = 400;
          request.response.write(str.login_browser_response_failed);
          request.response.close();
          setState(() {
            status = str.login_browser_failed;
          });
        }
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
    var openBrowser = launchUrl(getTokenEndpoint());
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
