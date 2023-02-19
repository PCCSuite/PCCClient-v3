import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pccclient/utils/local_config.dart';
import 'package:pccclient/utils/plugins/command.dart';
import 'package:pccclient/utils/plugins/datas.dart';
import 'package:pccclient/utils/plugins/files.dart';
import 'package:pccclient/utils/plugins/status_enum.dart';
import 'package:pccclient/utils/server_info.dart';

import 'package:path/path.dart' as path;

Process? pluginSysProcess;

Future<void> startPluginSys() async {
  var logDir = Directory(pluginSysConfig.tempDir);
  if (await logDir.exists()) {
    try {
      await _connectPluginSys(0);
      pluginSysStatus = PluginSysStatus.starting;
      return;
    } catch (_) {}
  } else {
    await logDir.create();
  }
  pluginSysProcess = await Process.start("cmd.exe", [
    "/C",
    "${serverInfo.pluginSysPath}\\PCCPluginSys.exe",
    "host",
    "${serverInfo.pluginSysPath}\\config.json",
    ">",
    path.join(logDir.path, "sys.log"),
    "2>&1",
  ]);
  pluginSysStatus = PluginSysStatus.starting;
  pluginSysProcess!.exitCode.whenComplete(() {
    pluginSysStatus = PluginSysStatus.stopped;
  });
  await _connectPluginSys(10);
}

Socket? socket;

Future<void> _connectPluginSys(int retryNum) async {
  var sock = await _connectSocket(retryNum);
  sock.done.whenComplete(() {
    pluginSysStatus = PluginSysStatus.stopped;
  });
  sock.write(
      json.encode({"data_type": "negotiate", "client_type": "pccclient"}));
  sock.flush();
  sock.listen(_listener);
}

Future<Socket> _connectSocket(int retryNum) async {
  for (int i = 0; i < retryNum; i++) {
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

void _listener(Uint8List data) {
  Map<String, dynamic> map = json.decode(utf8.decode(data));
  switch (map["data_type"]) {
    case "notify":
      pluginSysStatus = PluginSysStatus.from(map["status"]);
      List<ActivePackageData> newActivePlugins = [];
      for (Map<String, dynamic> pluginRaw in map["packages"]) {
        newActivePlugins.add(ActivePackageData.fromJson(pluginRaw));
      }
      activePackages = newActivePlugins;
      List<AskData> newAskData = [];
      for (Map<String, dynamic> askRaw in map["asking"]) {
        newAskData.add(AskData.fromJson(askRaw));
      }
      askData = newAskData;
      if (pluginSysStatus == PluginSysStatus.ready && localConfig.autoRestore) {
        startPluginRestore();
      }
  }
}
