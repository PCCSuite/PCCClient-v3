import 'dart:convert';

import 'package:pccclient/utils/plugins/start.dart';

void startPluginRestore() {
  socket!.write(json.encode({"data_type": "restore"}));
}

void installPackageCommand(String identifier) {
  socket!.write(json.encode({"data_type": "install", "package": identifier}));
}

void startPluginActionCommand(String plugin, String action) {
  socket!.write(
      json.encode({"data_type": "action", "plugin": plugin, "action": action}));
}

void cancelActionCommand(String package) {
  socket!.write(
      json.encode({"data_type": "cancel", "package": package}));
}

void answerAskingCommand(int id, String answer) {
  socket!.write(
      json.encode({"data_type": "answer", "id": id, "value": answer}));
}
