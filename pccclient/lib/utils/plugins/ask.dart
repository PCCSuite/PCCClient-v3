import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pccclient/utils/plugins/command.dart';
import 'package:pccclient/utils/plugins/start.dart';

import '../../screens/part/form_field.dart';
import '../general.dart';
import 'datas.dart';

Future<void> showAskDialog(BuildContext context, AskData data) async {
  Widget field;
  String? result;
  switch (data.type) {
    case "string":
      field = TextFormField(
        keyboardType: TextInputType.text,
        onSaved: (val) => result = val.toString(),
      );
      break;
    case "password":
      field = TextFormField(
        keyboardType: TextInputType.visiblePassword,
        onSaved: (val) => result = val.toString(),
      );
      break;
    case "int":
      field = IntegerFormField(
        onSaved: (val) => result = val.toString(),
      );
      break;
    case "bool":
      field = ToggleFormField(
        onSaved: (val) => result = val.toString(),
      );
      break;
    default:
      field = const Text("Invalid type");
  }
  var formKey = GlobalKey<FormState>();
  bool submit = await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => AlertDialog(
      title: Text(str.plugin_ask_title),
      scrollable: true,
      content: Form(
        key: formKey,
        child: Column(
          children: [
            SelectableText(
              "Package: ${data.package}, Plugin: ${data.plugin}",
              textScaleFactor: 0.8,
            ),
            Container(
              height: 10,
            ),
            SelectableText(data.message),
            field,
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            str.plugin_ask_cancel,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        TextButton(
          onPressed: () {
            formKey.currentState!.save();
            Navigator.pop(context, true);
          },
          child: Text(
            str.plugin_ask_submit,
          ),
        ),
      ],
    ),
  );
  if (submit) {
    answerAsking(data.id, result.toString());
  } else {
    cancelAction(data.package);
  }
}
