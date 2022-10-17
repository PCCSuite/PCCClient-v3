import 'dart:math';

import 'package:flutter/material.dart';

import '../../utils/general.dart';

Future<void> showError(BuildContext context, err, trace) async {
  await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          AlertDialog(
            title: Text(str.error_dialog_title),
            scrollable: true,
            content: getErrorContent(err, trace),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  str.error_dialog_ignore,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              )
            ],
          ));
}

Random rnd = Random();

List<String> _errorMessage = [
  "Error: Meccha Error",
  "Error: It is possible that Monday is nearby.",
];

String getErrorDescription() {
  int index = rnd.nextInt(_errorMessage.length);
  return "${_errorMessage[index]}\n${str.error_dialog_description}";
}

Column getErrorContent(err, trace) {
  return Column(
    children: [
      SelectableText(getErrorDescription()),
      SelectableText("${err.toString()}\n${trace.toString()}"),
    ],
  );
}
