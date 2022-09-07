import 'dart:io';

import 'package:pccclient/utils/environment/common.dart';

Future<void> checkEnvLinux() async {
  environment = Environment(MachineType.linux);
  try {
    Process.run("gio", []);
  } on ProcessException catch(_) {
    throw Exception("Please make sure you have installed gvfs");
  }
  return;
}