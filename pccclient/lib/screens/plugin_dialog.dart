import 'package:flutter/material.dart';

import '../utils/general.dart';

Future<void> showPluginAddDialog(
    BuildContext context, String plugin, bool install, bool favorite) async {
  await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
            title: Text(str.plugin_add_dialog_title),
            scrollable: true,
            content: Form(
                child: Column(
              children: [
                Checkbox(
                  value: true,
                  onChanged: (bool? value) {},
                ),
              ],
            )),
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
