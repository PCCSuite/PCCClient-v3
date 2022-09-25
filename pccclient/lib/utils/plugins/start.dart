import 'dart:convert';
import 'dart:io';

import 'package:pccclient/utils/plugins/datas.dart';
import 'package:pccclient/utils/plugins/files.dart';
import 'package:pccclient/utils/plugins/status_enum.dart';
import 'package:pccclient/utils/server_info.dart';

import 'package:path/path.dart' as path;

Future<void> startPluginSys() async {
  var logDir = Directory(pluginSysConfig!.tempDir);
  logDir.createSync();
  var process = await Process.start("cmd.exe", [
    "/C",
    "${serverInfo.pluginSysPath}\\PCCPluginSys.exe",
    "host",
    "${serverInfo.pluginSysPath}\\config.json",
    ">",
    path.join(logDir.path, "sys.log"),
    "2>&1",
  ]);
  pluginSysStatus = PluginSysStatus.starting;
  process.exitCode.whenComplete(() {
    pluginSysStatus = PluginSysStatus.stopped;
  });
  _connectPluginSys();
}

Socket? socket;

Future<void> _connectPluginSys() async {
  var sock = await _connectSocket();
  sock.write(
      json.encode({"data_type": "negotiate", "client_type": "pccclient"}));
  sock.flush();
  sock.listen(_listener);
}

Future<Socket> _connectSocket() async {
  for (int i = 0; i < 10; i++) {
    try {
      var sock = await Socket.connect("localhost", 15000);
      socket = sock;
      return sock;
    } catch (_) {
      sleep(const Duration(milliseconds: 200));
    }
  }
  var sock = await Socket.connect("localhost", 15000);
  socket = sock;
  return sock;
}

void _listener(dynamic data) {
  Map<String, dynamic> map = json.decode(data);
  switch (map["data_type"]) {
    case "notify":
      pluginSysStatus = PluginSysStatus.from(map["status"]);
      List<ActivePluginData> newActivePlugins = [];
      for (Map<String, dynamic> pluginRaw in map["plugins"]) {
        newActivePlugins.add(ActivePluginData.fromJson(pluginRaw));
      }
      activePlugins = newActivePlugins;
  }
}
