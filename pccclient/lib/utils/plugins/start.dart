import 'dart:convert';
import 'dart:io';

import 'package:pccclient/utils/local_config.dart';
import 'package:pccclient/utils/plugins/datas.dart';
import 'package:pccclient/utils/plugins/status_enum.dart';
import 'package:pccclient/utils/server_info.dart';

Future<void> startPluginSys() async {
  var process = await Process.start("cmd.exe", ["/C", "${serverInfo.pluginSysPath}\\PCCPluginSys.exe", "host", "${serverInfo.pluginSysPath}\\config.json", ">", localConfig.pluginLog, " 2>&1"]);
  pluginSysStatus = PluginSysStatus.starting;
  process.exitCode.whenComplete(() {
    pluginSysStatus = PluginSysStatus.stopped;
  });
}

WebSocket? socket;

Future<void> connectPluginSys() async {
  var ws = await _connectWebsocket();
  ws.add(json.encode({
    "data_type": "negotiate",
    "client_type": "pccclient"
  }));
  ws.listen(_listener);
}

Future<WebSocket> _connectWebsocket() async {
  for (int i = 0;i < 10;i++) {
    try {
      var ws = await WebSocket.connect("ws://localhost:15000/");
      socket = ws;
      return ws;
    } catch (_) {
      sleep(const Duration(milliseconds: 200));
    }
  }
  var ws = await WebSocket.connect("ws://localhost:15000/");
  socket = ws;
  return ws;
}

void _listener(dynamic data) {
  Map<String, dynamic> map = json.decode(data);
  switch (map["data_type"]) {
    case "notify":
      pluginSysStatus = PluginSysStatus.from(map["status"]);
      List<ActivePluginData> newActivePlugins = [];
      for (Map<String,dynamic> pluginRaw in map["plugins"]) {
        newActivePlugins.add(ActivePluginData.fromJson(pluginRaw));
      }
      activePlugins = newActivePlugins;
  }
}