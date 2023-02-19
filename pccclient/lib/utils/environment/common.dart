import 'dart:io';

import 'windows.dart';
import '../local_config.dart';

late Environment environment;

class Environment {
  MachineType machineType;
  bool enablePlugin;

  Environment(this.machineType)
      : enablePlugin = (machineType == MachineType.resetWindows);
}

enum MachineType { resetWindows, unResetWindows, linux }

Future<void> checkEnv() async {
  if (localConfig.environment != "") {
    MachineType type = MachineType.values.byName(localConfig.environment);
    environment = Environment(type);
    return;
  }

  if (Platform.isWindows) {
    await checkEnvWindows();
    return;
  }
  if (Platform.isLinux) {
    environment = Environment(MachineType.linux);
    return;
  }
  throw Exception("Unsupported platform: ${Platform.operatingSystem}");
}
