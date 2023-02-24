import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../utils/auth.dart';
import '../utils/user_settings.dart';
import 'part/tips.dart';

import '../utils/general.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const routeName = "/settings";

  static final screenName = str.settings_title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SettingsScreen.screenName),
      ),
      bottomNavigationBar: getTipsBar(),
      body: const _SettingsWidget(),
    );
  }
}

class _SettingsWidget extends StatefulWidget {
  const _SettingsWidget({Key? key}) : super(key: key);

  @override
  State<_SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<_SettingsWidget> {
  int debugModeRemain = 5;
  int pluginDevModeRemain = 5;

  late TextEditingController pluginSysConfigPathTextControler;

  @override
  void initState() {
    pluginSysConfigPathTextControler =
        TextEditingController(text: userSettings.pluginSysConfig);
    pluginSysConfigPathTextControler.addListener(() {
      userSettings.pluginSysConfig = pluginSysConfigPathTextControler.text;
    });
    super.initState();
  }

  @override
  void dispose() {
    saveUserSettings();
    pluginSysConfigPathTextControler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          dense: true,
          title: Text(str.settings_auto_login),
        ),
        CheckboxListTile(
          title: Text(str.settings_auto_login_client),
          value: userSettings.appAutoLogin,
          onChanged: (val) => setState(() {
            userSettings.appAutoLogin = val!;
            if (val) {
              saveRefreshToken();
            } else {
              userSettings.appRefreshToken = "";
              userSettings.appRefreshTokenPeriod = 0;
            }
          }),
        ),
        ListTile(
          dense: true,
          title: Text(str.settings_login_method),
        ),
        RadioListTile<LoginMethod?>(
          title: Text(str.settings_login_method_default),
          value: null,
          groupValue: userSettings.loginMethod,
          onChanged: (val) => setState(() {
            userSettings.loginMethod = val;
          }),
        ),
        RadioListTile<LoginMethod?>(
          title: Text(LoginMethod.browser.name),
          value: LoginMethod.browser,
          groupValue: userSettings.loginMethod,
          onChanged: (val) => setState(() {
            userSettings.loginMethod = val;
          }),
        ),
        RadioListTile<LoginMethod?>(
          title: Text(LoginMethod.webview.name),
          value: LoginMethod.webview,
          groupValue: userSettings.loginMethod,
          onChanged: (val) => setState(() {
            userSettings.loginMethod = val;
          }),
        ),
        RadioListTile<LoginMethod?>(
          title: Text(LoginMethod.internal.name),
          value: LoginMethod.internal,
          groupValue: userSettings.loginMethod,
          onChanged: (val) => setState(() {
            userSettings.loginMethod = val;
          }),
        ),
        ListTile(
          dense: true,
          title: Text(str.settings_pccplugin),
        ),
        CheckboxListTile(
          title: Text(str.settings_pccplugin_auto_restore),
          value: userSettings.pluginAutoRestore,
          onChanged: (val) => setState(() {
            userSettings.pluginAutoRestore = val!;
          }),
        ),
        ListTile(
          title: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: pluginSysConfigPathTextControler,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: str.settings_pccplugin_config_path,
                    hintText: str.settings_pccplugin_config_path_default,
                  ),
                ),
              ),
              TextButton(
                  onPressed: () async {
                    var result = await FilePicker.platform.pickFiles();
                    if (result != null && result.files.isNotEmpty) {
                      pluginSysConfigPathTextControler.text =
                          result.files.map((e) => e.path).join(":");
                    }
                  },
                  child: const Icon(Icons.folder))
            ],
          ),
        ),
        userSettings.pluginDevMode ||
                pluginDevModeRemain <= 0 ||
                userSettings.debugMode ||
                debugModeRemain <= 0
            ? ListTile(
                dense: true,
                title: Text(str.settings_mode),
              )
            : Container(),
        userSettings.pluginDevMode || pluginDevModeRemain <= 0
            ? CheckboxListTile(
                title: Text(str.settings_mode_plugin),
                value: userSettings.pluginDevMode,
                onChanged: (val) {
                  setState(() {
                    userSettings.pluginDevMode = val!;
                  });
                },
              )
            : Container(),
        userSettings.debugMode || debugModeRemain <= 0
            ? CheckboxListTile(
                title: Text(str.settings_mode_debug),
                value: userSettings.debugMode,
                onChanged: (val) {
                  setState(() {
                    userSettings.debugMode = val!;
                  });
                },
              )
            : Container(),
        ListTile(
          dense: true,
          title: Text(str.settings_version),
        ),
        ListTile(
          title: Text(str.settings_version_pccclient),
          subtitle: const Text(version),
          onTap: () {
            setState(() {
              debugModeRemain--;
            });
          },
        ),
        ListTile(
          title: Text(str.settings_version_build),
          subtitle: const Text("116"),
          onTap: () {
            setState(() {
              pluginDevModeRemain--;
            });
          },
        ),
      ],
    );
  }
}
