
import 'dart:io';

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
  if (Platform.isLinux) {
    environment = Environment(MachineType.linux);
    return;
  }
  if (!Platform.isWindows) {
    throw Exception("Unsupported platform: ${Platform.operatingSystem}");
  }
  int tkg = 0;
  if (await _hasLogonScript()) {
    tkg += 2;
  }
  if (await _isIpValid()) {
    tkg += 2;
  }
  if (tkg >= 3) {
    environment = Environment(MachineType.resetWindows);
  }
  if (await _hasUserDirectory()) {
    tkg++;
  }
  if (tkg >= 3) {
    environment = Environment(MachineType.resetWindows);
  }
  if (await _hasNetworkDrive()) {
    tkg++;
  }
  if (tkg >= 3) {
    environment = Environment(MachineType.resetWindows);
  }
  environment = Environment(MachineType.unResetWindows);
}

Future<bool> _isIpValid() async {
  List<NetworkInterface> list = await NetworkInterface.list(type: InternetAddressType.IPv4);
  bool foundAddress = false;
  InternetAddress? ipAddress;
  addressSearch:
  for (NetworkInterface i in list) {
    for (InternetAddress addr in i.addresses) {
      if (addr.isLoopback ||  addr.isLinkLocal || addr.isMulticast) {
        continue;
      }
      foundAddress = true;
      if (addr.rawAddress[0] == 10) {
        ipAddress = addr;
        break addressSearch;
      }
    }
  }
  if (!foundAddress) {
    throw Exception("Failed to find ip address");
  }
  if (ipAddress == null) {
    return false;
  }
  if (ipAddress.rawAddress[1] > 5) {
    return false;
  }
  if (ipAddress.rawAddress[2] > 99) {
    return false;
  }
  if (ipAddress.rawAddress[3] > 40) {
    return false;
  }
  return true;
}

Future<bool> _hasLogonScript() async {
  return await File.fromUri(Uri.directory("C:\\logon", windows: true)).exists();
}

Future<bool> _hasUserDirectory() async {
  return await File.fromUri(Uri.directory("C:\\Users\\user", windows: true)).exists();
}

Future<bool> _hasNetworkDrive() async {
  Future<bool> public = File.fromUri(Uri.directory("P:", windows: true)).exists();
  Future<bool> homes = File.fromUri(Uri.directory("U:", windows: true)).exists();
  return await public && await homes;
}