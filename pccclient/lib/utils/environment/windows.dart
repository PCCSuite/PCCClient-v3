

import 'dart:io';

import 'common.dart';

Future<void> checkEnvWindows() async {
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
  } else {
    environment = Environment(MachineType.unResetWindows);
  }
}

Future<bool> _isIpValid() async {
  List<NetworkInterface> list = await NetworkInterface.list(type: InternetAddressType.IPv4);
  bool foundAddress = false;
  InternetAddress? ipAddress;
  addressSearch:
  for (NetworkInterface i in list) {
    for (InternetAddress address in i.addresses) {
      if (address.isLoopback ||  address.isLinkLocal || address.isMulticast) {
        continue;
      }
      foundAddress = true;
      if (address.rawAddress[0] == 10) {
        ipAddress = address;
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
  Future<bool> public = File.fromUri(Uri.directory("P:\\", windows: true)).exists();
  Future<bool> homes = File.fromUri(Uri.directory("U:\\", windows: true)).exists();
  return await public && await homes;
}