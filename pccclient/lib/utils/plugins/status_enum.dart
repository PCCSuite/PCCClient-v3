import 'package:flutter/material.dart';
import 'package:pccclient/utils/general.dart';

enum PluginSysStatus {
  starting(-1),
  stopped(-2),
  readying(1),
  ready(2),
  restoring(3),
  standby(4);

  final int data;
  const PluginSysStatus(this.data);
  factory PluginSysStatus.from(int data) {
    return PluginSysStatus.values.firstWhere((element) => element.data == data);
  }
}

extension PluginSysStatusExt on PluginSysStatus {
  String get message {
    switch (this) {
      case PluginSysStatus.starting:
        return str.plugin_sys_status_starting;
      case PluginSysStatus.stopped:
        return str.plugin_sys_status_stopped;
      case PluginSysStatus.readying:
        return str.plugin_sys_status_readying;
      case PluginSysStatus.ready:
        return str.plugin_sys_status_ready;
      case PluginSysStatus.restoring:
        return str.plugin_sys_status_restoring;
      case PluginSysStatus.standby:
        return str.plugin_sys_status_standby;
    }
  }
}

enum ActionStatus {
  loaded("loaded"),
  waitStart("wait_start"),
  running("running"),
  waitDepend("wait_depend"),
  waitLock("wait_lock"),
  done("done"),
  failed("failed");

  final String data;
  const ActionStatus(this.data);
  factory ActionStatus.from(String data) {
    return ActionStatus.values.firstWhere((element) => element.data == data);
  }
}

extension ActionStatusExt on ActionStatus {
  Widget get icon {
    const size = 35.0;
    switch (this) {
      case ActionStatus.loaded:
        return Tooltip(
          message: str.plugin_status_waitStart,
          child: const Icon(
            Icons.download_done,
            size: size,
          ),
        );
      case ActionStatus.waitStart:
        return Tooltip(
          message: str.plugin_status_waitStart,
          child: const Icon(
            Icons.not_started,
            size: size,
          ),
        );
      case ActionStatus.waitDepend:
        return Tooltip(
          message: str.plugin_status_waitDepend,
          child: const Icon(
            Icons.access_time,
            size: size,
          ),
        );
      case ActionStatus.waitLock:
        return Tooltip(
          message: str.plugin_status_waitLock,
          child: const Icon(
            Icons.lock_clock,
            size: size,
          ),
        );
      case ActionStatus.running:
        return Tooltip(
          message: str.plugin_status_running,
          child: const Icon(
            Icons.sync,
            size: size,
          ),
        );
      case ActionStatus.done:
        return Tooltip(
          message: str.plugin_status_done,
          child: const Icon(
            Icons.check,
            size: size,
            color: Colors.blue,
          ),
        );
      case ActionStatus.failed:
        return Tooltip(
          message: str.plugin_status_failed,
          child: const Icon(
            Icons.close,
            size: size,
            color: Colors.red,
          ),
        );
    }
  }
}
