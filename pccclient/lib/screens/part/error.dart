

import 'package:flutter/material.dart';

import '../../utils/general.dart';

Future<void> showError(BuildContext context, String err, String trace) async {
  await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
    title: Text(str.error_dialog_title),
    scrollable: true,
    content: Column(
      children: [
        Text(str.error_dialog_description),
        Text("$err\n$trace"),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          str.error_dialog_ignore,
          style: TextStyle(color: Colors.redAccent),
        ),
      )
    ],
  ));}