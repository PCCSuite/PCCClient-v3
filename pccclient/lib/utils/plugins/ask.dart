import 'package:flutter/material.dart';
import 'package:pccclient/screens/plugin_config.dart';
import 'package:pccclient/utils/plugins/command.dart';
import 'package:pccclient/utils/plugins/files.dart';

import 'package:path/path.dart' as path;

import '../../screens/part/form_field.dart';
import '../general.dart';
import 'datas.dart';

Future<void> showAskDialog(BuildContext context, AskData data) async {
  Widget field;
  String? result;
  bool submit;
  if (data.type == "config") {
    submit = await Navigator.pushNamed(
          context,
          PluginConfigScreen.routeName,
          arguments: PluginConfigScreenArgument(
              data.message,
              await loadPluginXml(path.join(
                  Package.fromIdentifier(data.plugin).dir!, "plugin.xml"))),
        ) ==
        true;
  } else {
    switch (data.type) {
      case "string":
        field = TextFormField(
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: str.plugin_form_field_hint_string,
          ),
          onSaved: (val) => result = val.toString(),
        );
        break;
      case "password":
        field = TextFormField(
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            hintText: str.plugin_form_field_hint_password,
          ),
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
    submit = await showDialog(
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
  }
  if (submit) {
    answerAskingCommand(data.id, result.toString());
  } else {
    cancelActionCommand(data.package);
  }
}
