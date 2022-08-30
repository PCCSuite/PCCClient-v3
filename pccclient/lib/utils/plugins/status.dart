import 'package:flutter/material.dart';
import 'package:pccclient/utils/general.dart';

enum ActionStatus {
  waitStart,
  waitLock,
  waitDepend,
  running,
  done,
  failed,
}

extension ActionStatusExt on ActionStatus {
  Widget get icon {
    const size = 35.0;
    switch (this) {
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
