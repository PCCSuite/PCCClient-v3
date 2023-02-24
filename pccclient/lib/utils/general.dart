import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum ProcessState { waiting, getting, ok, failed }

late AppLocalizations str;

void initLocalizations(BuildContext context) {
  str = AppLocalizations.of(context)!;
}

Icon getIcon(ProcessState state) {
  const double size = 100.0;
  switch (state) {
    case ProcessState.waiting:
      return const Icon(
        Icons.navigate_next,
        size: size,
        color: Colors.black12,
      );
    case ProcessState.getting:
      return const Icon(
        Icons.more_horiz,
        size: size,
        color: Colors.black45,
      );
    case ProcessState.ok:
      return const Icon(
        Icons.check,
        size: size,
        color: Colors.blue,
      );
    case ProcessState.failed:
      return const Icon(
        Icons.close,
        size: size,
        color: Colors.red,
      );
  }
}

class StateMsgSet {
  ProcessState state;
  String message;

  StateMsgSet(this.state, this.message);
}

String generateRandomString(int len) {
  var r = Random.secure();
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
}
