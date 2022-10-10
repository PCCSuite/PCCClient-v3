import 'dart:convert';

import 'package:pccclient/utils/plugins/start.dart';

void startPluginRestore() {
  socket!.write(json.encode({"data_type": "restore"}));
}

void installPlugin(String name) {
  socket!.write(json.encode({"data_type": "install", "plugin": name}));
}

void startPluginAction(String plugin, String action) {
  socket!.write(
      json.encode({"data_type": "action", "plugin": plugin, "action": action}));
}
