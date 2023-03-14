import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'auth.dart';
import 'general.dart';
import 'samba.dart';
import 'server_info.dart';

Future<void> mountSamba(BuildContext context) async {
  if (Platform.isWindows) {
    await _mountWindows(context);
    return;
  }
  if (Platform.isLinux) {
    await _mountLinux();
    return;
  }
  throw UnimplementedError("Unsupported platform to mount");
}

Future<void> _mountWindows(BuildContext context) async {
  bool hasMounted =
      await Directory.fromUri(Uri.directory("A:\\", windows: true)).exists();
  if (hasMounted) {
    if (context.mounted) {
      bool remount = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Text(str.mount_already_mounted),
          actions: [
            SimpleDialogOption(
              child: Text(str.mount_unmount),
              onPressed: () => Navigator.pop(context, true),
            ),
            SimpleDialogOption(
              child: Text(str.mount_skip),
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        ),
      );
      if (remount) {
        await _unmountWindowsCmd("A:");
        await _unmountWindowsCmd("B:");
      } else {
        return;
      }
    } else {
      return;
    }
  }
  await _mountWindowsCmd(username, sambaPassword,
      "\\\\${serverInfo.sambaServer}\\pcc_homes_v3", "A:");
  await _mountWindowsCmd(
      username, sambaPassword, "\\\\${serverInfo.sambaServer}\\share_v3", "B:");
}

// letter should "X:"
Future<void> _mountWindowsCmd(
    String username, String password, String path, String letter) async {
  List<String> param = ["use", letter, path, password, "/user:$username", "/y"];
  var process = await Process.run('net', param);
  if (process.exitCode != 0) {
    throw Exception(
        "Failed to execute: net ${param.join(" ")}\n${process.stderr} ${process.stdout}");
  }
}

// letter should "X:"
Future<void> _unmountWindowsCmd(String letter) async {
  List<String> param = ["use", letter, "/DELETE", "/y"];
  var process = await Process.run('net', param);
  if (process.exitCode != 0) {
    throw Exception(
        "Failed to execute: net ${param.join(" ")}\n${process.stderr} ${process.stdout}");
  }
}

Future<void> _mountLinux() async {
  await _mountLinuxCmd(
      username, sambaPassword, serverInfo.sambaServer, "pcc_homes_v3");
  await _mountLinuxCmd(
      username, sambaPassword, serverInfo.sambaServer, "share_v3");
}

Future<void> _mountLinuxCmd(
    String username, String password, String server, String name) async {
  List<String> param = ["mount", "smb://$username@$server/$name"];
  var process = await Process.start('gio', param);
  process.stdin.write("\n$password\n");
  if (await process.exitCode != 0) {
    String stdout = await process.stdout.transform(utf8.decoder).join();
    String stderr = await process.stderr.transform(utf8.decoder).join();
    if (!stderr.endsWith(": Location is already mounted\n")) {
      throw Exception(
          "Failed to mount: gio ${param.join(" ")}\n$stderr $stdout");
    }
  }
}
