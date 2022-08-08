import 'package:flutter/material.dart';
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

  @override
  void initState() {
    _configState = StateMsgSet(ProcessState.getting, str.init_loading_config);
    Future<void> configFuture = Future(readConfig);
    configFuture.then((value) {
      setState(() {
        _configState = StateMsgSet(ProcessState.ok, str.init_loaded_config);
      });
      _remainProcess--;
      checkState();
    });
    _envState = StateMsgSet(ProcessState.getting, str.init_checking_env);
    Future<StateMsgSet> envFuture = Future(getEnv);
    envFuture.then((value) {
      setState(() {
        _envState = value;
      });
      _remainProcess--;
      checkState();
    });
    _serverState = StateMsgSet(ProcessState.getting, str.init_checking_srv);
    Future<StateMsgSet> serverFuture =
        Future.delayed(const Duration(seconds: 3), getServer);
    serverFuture.then((value) {
      setState(() {
        _serverState = value;
      });
      _remainProcess--;
      checkState();
    });
    _usernameState = StateMsgSet(ProcessState.getting, str.init_checking_username);
    Future<StateMsgSet> usernameFuture = getUser();
    usernameFuture.then((value) {
      setState(() {
        _usernameState = value;
      });
      _remainProcess--;
      checkState();
    });
    super.initState();
  }

  void checkState() {
    if (_remainProcess == 0) {
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
