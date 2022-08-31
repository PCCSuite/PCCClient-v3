import 'package:flutter/material.dart';
import 'package:pccclient/screens/part/error.dart';
import 'package:pccclient/utils/local_config.dart';

import '../utils/auth.dart';
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
  late StateMsgSet _configState;
  late StateMsgSet _envState;
  late StateMsgSet _serverState;
  late StateMsgSet _usernameState;

  int _remainProcess = 4;
  int _errorShowing = 0;

  @override
  void initState() {
    _configState =
        StateMsgSet(ProcessState.getting, str.init_load_config_start);
    Future<void> configFuture = Future(readConfig);
    configFuture.then((value) {
      setState(() {
        _configState = StateMsgSet(ProcessState.ok, str.init_load_config_done);
      });
      _remainProcess--;
      _checkState();
    });
    configFuture.catchError((e, trace) {
      setState(() {
        _configState =
            StateMsgSet(ProcessState.failed, str.init_load_config_fail);
      });
      _errorShow(e, trace);
    });
    _envState = StateMsgSet(ProcessState.getting, str.init_check_env_start);
    Future<void> envFuture = Future(getEnv);
    envFuture.then((value) {
      setState(() {
        _envState = StateMsgSet(ProcessState.ok, str.init_check_env_done);
      });
      _remainProcess--;
      _checkState();
    });
    envFuture.catchError((e, trace) {
      setState(() {
        _envState = StateMsgSet(ProcessState.failed, str.init_check_env_fail);
      });
      _errorShow(e, trace);
    });
    _serverState = StateMsgSet(ProcessState.getting, str.init_check_srv_start);
    Future<void> serverFuture = getServer();
    serverFuture.then((value) {
      setState(() {
        _serverState = StateMsgSet(ProcessState.ok, str.init_check_srv_done);
      });
      _remainProcess--;
      _checkState();
    });
    serverFuture.catchError((e, trace) {
      setState(() {
        _serverState =
            StateMsgSet(ProcessState.failed, str.init_check_srv_fail);
      });
      _errorShow(e, trace);
    });
    _usernameState =
        StateMsgSet(ProcessState.getting, str.init_check_username_start);
    Future<void> usernameFuture = Future(getUser);
    usernameFuture.then((_) {
      setState(() {
        _usernameState =
            StateMsgSet(ProcessState.ok, str.init_check_username_done);
      });
      _remainProcess--;
      _checkState();
    });
    usernameFuture.catchError((e, trace) {
      setState(() {
        _usernameState =
            StateMsgSet(ProcessState.failed, str.init_check_username_fail);
      });
      _errorShow(e, trace);
    });
    super.initState();
  }

  void _errorShow(err, trace) async {
    _errorShowing++;
    await showError(context, err, trace);
    _errorShowing--;
    _remainProcess--;
    _checkState();
  }

  void _checkState() {
    if (_remainProcess == 0 && _errorShowing == 0) {
      Navigator.popAndPushNamed(context, LoginSelectScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: _InitializeStateRow(_configState)),
        Expanded(child: _InitializeStateRow(_envState)),
        Expanded(child: _InitializeStateRow(_serverState)),
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
