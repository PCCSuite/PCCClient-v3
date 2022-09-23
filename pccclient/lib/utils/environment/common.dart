
import 'dart:io';

import 'package:pccclient/utils/environment/windows.dart';

late Environment environment;

class Environment {
  MachineType machineType;
  bool enablePlugin;

  Environment(this.machineType) : enablePlugin = (machineType == MachineType.resetWindows);
}

enum MachineType {
  resetWindows,
  unResetWindows,
  linux
}

Future<void> checkEnv() async {
  if (Platform.isWindows) {
    checkEnvWindows();
    return;
  }
  if (Platform.isLinux) {
    environment = Environment(MachineType.linux);
    return;
  }
  throw Exception("Unsupported platform: ${Platform.operatingSystem}");
}