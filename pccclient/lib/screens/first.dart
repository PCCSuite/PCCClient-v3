import 'package:flutter/material.dart';
import 'package:pccclient/screens/part/error.dart';
import 'package:pccclient/utils/local_config.dart';

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
  StateMsgSet _configState =
      StateMsgSet(ProcessState.getting, str.init_load_config_start);
  StateMsgSet _envState =
      StateMsgSet(ProcessState.getting, str.init_check_env_start);
  StateMsgSet _serverState =
      StateMsgSet(ProcessState.getting, str.init_load_srv_info_wait);
  StateMsgSet _usernameState =
      StateMsgSet(ProcessState.getting, str.init_check_username_start);

  int _runningProcess = 0;
  int _errorShowing = 0;

  Future<void> _loadConfig() async {
    try {
      _runningProcess++;
      readConfig();
      setState(() {
        _configState = StateMsgSet(ProcessState.ok, str.init_load_config_done);
      });
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
      setState(() {
        _serverState =
            StateMsgSet(ProcessState.ok, str.init_load_srv_info_done);
      });
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

  Future<void> _getUsername() async {
    try {
      _runningProcess++;
      await getUser();
      setState(() {
        _usernameState =
            StateMsgSet(ProcessState.ok, str.init_check_username_done);
      });
      _runningProcess--;
      _checkDone();
    } catch (e, trace) {
      setState(() {
        _usernameState =
            StateMsgSet(ProcessState.failed, str.init_check_username_fail);
      });
      _errorShow(e, trace);
    }
  }

  _checkDone() {
    if (_runningProcess == 0 && _errorShowing == 0) {
      Navigator.popAndPushNamed(context, LoginSelectScreen.routeName);
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
      _checkEnv();
      _getUsername();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: _InitializeStateRow(_configState)),
        Expanded(child: _InitializeStateRow(_serverState)),
        Expanded(child: _InitializeStateRow(_envState)),
        Expanded(child: _InitializeStateRow(_usernameState)),
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
