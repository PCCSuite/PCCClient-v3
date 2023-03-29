import 'package:flutter/material.dart';
import '../utils/user_settings.dart';
import 'loggingin.dart';
import 'part/error.dart';
import '../utils/local_config.dart';

import '../utils/auth.dart';
import '../utils/environment/common.dart';
import '../utils/general.dart';
import 'login_select.dart';

class _InitializeStateRow extends StatelessWidget {
  const _InitializeStateRow(this.state, {Key? key}) : super(key: key);

  final StateMsgSet state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [getIcon(state.state), Text(state.message)],
    );
  }
}

class _InitializeStateView extends StatefulWidget {
  const _InitializeStateView({Key? key}) : super(key: key);

  @override
  State<_InitializeStateView> createState() => _InitializeStateViewState();
}

class _InitializeStateViewState extends State<_InitializeStateView> {
  StateMsgSet _envState =
      StateMsgSet(ProcessState.getting, str.init_check_env_start);
  StateMsgSet _configState =
      StateMsgSet(ProcessState.getting, str.init_load_config_start);
  StateMsgSet _serverState =
      StateMsgSet(ProcessState.getting, str.init_load_srv_info_wait);
  StateMsgSet _settingsState =
      StateMsgSet(ProcessState.getting, str.init_load_settings_start);
  StateMsgSet _prepareAuthState =
      StateMsgSet(ProcessState.getting, str.init_prepare_auth_wait);

  int _runningProcess = 0;
  int _errorShowing = 0;

  bool _settingLoaded = false;
  bool _serverInfoLoaded = false;

  Future<void> _loadSettings() async {
    try {
      _runningProcess++;
      loadUserSettings();
      _settingLoaded = true;
      setState(() {
        _settingsState =
            StateMsgSet(ProcessState.ok, str.init_load_settings_done);
      });
      _prepareAuth();
      _runningProcess--;
    } catch (e, trace) {
      setState(() {
        _settingsState =
            StateMsgSet(ProcessState.failed, str.init_load_settings_fail);
      });
      _errorShow(e, trace);
    }
  }

  Future<void> _loadConfig() async {
    try {
      _runningProcess++;
      readLocalConfig();
      setState(() {
        _configState = StateMsgSet(ProcessState.ok, str.init_load_config_done);
      });
      _checkEnv();
      _loadServer();
      _runningProcess--;
    } catch (e, trace) {
      setState(() {
        _configState =
            StateMsgSet(ProcessState.failed, str.init_load_config_fail);
      });
      _errorShow(e, trace);
    }
  }

  Future<void> _loadServer() async {
    try {
      _runningProcess++;
      setState(() {
        _serverState =
            StateMsgSet(ProcessState.ok, str.init_load_srv_info_start);
      });
      await getServer();
      _serverInfoLoaded = true;
      setState(() {
        _serverState =
            StateMsgSet(ProcessState.ok, str.init_load_srv_info_done);
      });
      _prepareAuth();
      _runningProcess--;
      _checkDone();
    } catch (e, trace) {
      setState(() {
        _serverState =
            StateMsgSet(ProcessState.failed, str.init_load_srv_info_fail);
      });
      _errorShow(e, trace);
    }
  }

  Future<void> _checkEnv() async {
    try {
      _runningProcess++;
      await checkEnv();
      setState(() {
        _envState = StateMsgSet(ProcessState.ok, str.init_check_env_done);
      });
      _runningProcess--;
      _checkDone();
    } catch (e, trace) {
      setState(() {
        _envState = StateMsgSet(ProcessState.failed, str.init_check_env_fail);
      });
      _errorShow(e, trace);
    }
  }

  Future<void> _prepareAuth() async {
    if (!_settingLoaded || !_serverInfoLoaded) {
      return;
    }
    try {
      _runningProcess++;
      setState(() {
        _prepareAuthState =
            StateMsgSet(ProcessState.ok, str.init_prepare_auth_start);
      });
      await initAuth();
      setState(() {
        _prepareAuthState =
            StateMsgSet(ProcessState.ok, str.init_prepare_auth_done);
      });
      _runningProcess--;
      _checkDone();
    } catch (e, trace) {
      setState(() {
        _prepareAuthState =
            StateMsgSet(ProcessState.failed, str.init_prepare_auth_fail);
      });
      _errorShow(e, trace);
    }
  }

  _checkDone() {
    if (_runningProcess == 0 && _errorShowing == 0) {
      if (tokenAvailable) {
        Navigator.popAndPushNamed(context, LoggingInScreen.routeName);
      } else {
        Navigator.popAndPushNamed(context, LoginSelectScreen.routeName);
      }
    }
  }

  void _errorShow(err, trace) async {
    _errorShowing++;
    await showError(context, err, trace);
    _errorShowing--;
    _runningProcess--;
    _checkDone();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadConfig();
      _loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: _InitializeStateRow(_envState)),
        Expanded(child: _InitializeStateRow(_configState)),
        Expanded(child: _InitializeStateRow(_serverState)),
        Expanded(child: _InitializeStateRow(_settingsState)),
        Expanded(child: _InitializeStateRow(_prepareAuthState)),
      ],
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({Key? key}) : super(key: key);

  static const routeName = "/init";

  @override
  Widget build(BuildContext context) {
    initLocalizations(context);
    // return const _InitializeStateView();
    return Scaffold(
      appBar: AppBar(
        title: Text(str.init_title),
      ),
      body: const _InitializeStateView(),
    );
  }
}
