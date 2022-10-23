import 'dart:convert';

import 'package:pccclient/utils/plugins/start.dart';

void startPluginRestore() {
  socket!.write(json.encode({"data_type": "restore"}));
}

void installPackage(String name) {
  socket!.write(json.encode({"data_type": "install", "package": name}));
}

void startPluginAction(String plugin, String action) {
  socket!.write(
      json.encode({"data_type": "action", "plugin": plugin, "action": action}));
}

void cancelAction(String package) {
  socket!.write(
      json.encode({"data_type": "cancel", "package": package}));
}

void answerAsking(int id, String answer) {
  socket!.write(
      json.encode({"data_type": "answer", "id": id, "value": answer}));
}
