import 'package:flutter/material.dart';
import 'package:pccclient/screens/home.dart';
import 'package:pccclient/screens/login_select.dart';
import 'package:pccclient/screens/part/error.dart';
import 'package:pccclient/utils/auth.dart';
import 'package:pccclient/utils/environment/common.dart';
import 'package:pccclient/utils/general.dart';
import 'package:pccclient/utils/manager.dart';
import 'package:pccclient/utils/plugins/start.dart';

import '../utils/plugins/files.dart';

class _LoggingInStateRow extends StatelessWidget {
  const _LoggingInStateRow(this.state, {Key? key}) : super(key: key);

  final StateMsgSet state;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Row(
      children: [getIcon(state.state), Text(state.message)],
    ));
  }
}

class LoggingInScreen extends StatelessWidget {
  static const routeName = "/logging_in";

  static final screenName = str.loggingin_title;

  const LoggingInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LoggingInScreen.screenName),
      ),
      body: const _LoggingInStateWidget(),
    );
  }
}

class _LoggingInStateWidget extends StatefulWidget {
  const _LoggingInStateWidget({Key? key}) : super(key: key);

  @override
  State<_LoggingInStateWidget> createState() => _LoggingInStateWidgetState();
}

class _LoggingInStateWidgetState extends State<_LoggingInStateWidget> {
  late StateMsgSet _getSambaPassState =
      StateMsgSet(ProcessState.waiting, str.loggingin_get_password_start);
  late StateMsgSet _mountSambaState =
      StateMsgSet(ProcessState.waiting, str.loggingin_mount_wait);
  late StateMsgSet _loadPluginSysConfigState =
      StateMsgSet(ProcessState.waiting, str.loggingin_load_plugin_wait);
  late StateMsgSet _startPluginSysState =
      StateMsgSet(ProcessState.waiting, str.loggingin_start_plugin_wait);
  late StateMsgSet _connectCliManState =
      StateMsgSet(ProcessState.waiting, str.loggingin_climan_start);

  int _runningProcess = 0;
  int _errorShowing = 0;

  void _startGetSambaPass() {
    _runningProcess++;
    var getSambaPassFuture = getSambaPass();
    getSambaPassFuture.then((_) {
      setState(() {
        _getSambaPassState =
            StateMsgSet(ProcessState.ok, str.loggingin_get_password_done);
      });
      _startMountSamba();
      _runningProcess--;
    }).catchError((e, trace) {
      setState(() {
        _getSambaPassState =
            StateMsgSet(ProcessState.failed, str.loggingin_get_password_fail);
      });
      _errorShow(e, trace);
    });
  }

  void _startMountSamba() {
    setState(() {
      _mountSambaState =
          StateMsgSet(ProcessState.getting, str.loggingin_mount_start);
    });
    _runningProcess++;
    var mountSambaFuture = mountSamba();
    mountSambaFuture.then((_) {
      setState(() {
        _mountSambaState =
            StateMsgSet(ProcessState.ok, str.loggingin_mount_done);
      });
      _runningProcess--;
      if (environment.enablePlugin) {
        _loadPluginSysConfig();
      } else {
        _checkDone();
      }
    }).catchError((e, trace) {
      setState(() {
        _mountSambaState =
            StateMsgSet(ProcessState.failed, str.loggingin_mount_fail);
      });
      _errorShow(e, trace);
    });
  }

  void _loadPluginSysConfig() {
    setState(() {
      _loadPluginSysConfigState =
          StateMsgSet(ProcessState.waiting, str.loggingin_load_plugin_start);
    });
    _runningProcess++;
    var loadPluginSysConfigFuture = loadPluginSysConfig();
    loadPluginSysConfigFuture.then((_) {
      setState(() {
        _loadPluginSysConfigState =
            StateMsgSet(ProcessState.ok, str.loggingin_load_plugin_done);
      });
      _runningProcess--;
      _startPluginSys();
    }).catchError((e, trace) {
      setState(() {
        _loadPluginSysConfigState =
            StateMsgSet(ProcessState.failed, str.loggingin_load_plugin_fail);
      });
      _errorShow(e, trace);
    });
  }

  void _startPluginSys() {
    setState(() {
      _startPluginSysState =
          StateMsgSet(ProcessState.waiting, str.loggingin_start_plugin_start);
    });
    _runningProcess++;
    var startPluginSysFuture = startPluginSys();
    startPluginSysFuture.then((_) {
      setState(() {
        _startPluginSysState =
            StateMsgSet(ProcessState.ok, str.loggingin_start_plugin_done);
      });
      _runningProcess--;
      _checkDone();
    }).catchError((e, trace) {
      setState(() {
        _startPluginSysState =
            StateMsgSet(ProcessState.failed, str.loggingin_start_plugin_fail);
      });
      _errorShow(e, trace);
    });
  }

  void _startConnectCliMan() {
    _runningProcess++;
    var connectCliManFuture = Future(init);
    connectCliManFuture.then((value) {
      setState(() {
        _connectCliManState =
            StateMsgSet(ProcessState.ok, str.loggingin_climan_done);
      });
      _runningProcess--;
      _checkDone();
    }).catchError((e, trace) {
      setState(() {
        _connectCliManState =
            StateMsgSet(ProcessState.failed, str.loggingin_climan_fail);
      });
      _errorShow(e, trace);
    });
  }

  @override
  void initState() {
    _startGetSambaPass();
    _startConnectCliMan();
    super.initState();
  }

  _checkDone() {
    if (_runningProcess == 0 && _errorShowing == 0) {
      Navigator.popUntil(
          context, ModalRoute.withName(LoginSelectScreen.routeName));
      Navigator.popAndPushNamed(context, HomeScreen.routeName);
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
  Widget build(BuildContext context) {
    List<Widget> content = [];
    content.add(_LoggingInStateRow(_getSambaPassState));
    content.add(_LoggingInStateRow(_mountSambaState));
    if (environment.enablePlugin) {
      content.add(_LoggingInStateRow(_loadPluginSysConfigState));
      content.add(_LoggingInStateRow(_startPluginSysState));
    }
    content.add(_LoggingInStateRow(_connectCliManState));
    return Column(
      children: content,
    );
  }
}
