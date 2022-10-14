import 'package:flutter/material.dart';

import '../../utils/general.dart';

Future<void> showError(BuildContext context, err, trace) async {
  await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
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

Column getErrorContent(err, trace) {
  return Column(
    children: [
      SelectableText(str.error_dialog_description),
      SelectableText("${err.toString()}\n${trace.toString()}"),
    ],
  );
}
