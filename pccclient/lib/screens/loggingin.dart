import 'package:flutter/material.dart';
import '../utils/mount.dart';
import '../utils/samba.dart';
import 'home.dart';
import 'login_select.dart';
import 'part/error.dart';
import 'part/tips.dart';
import '../utils/auth.dart';
import '../utils/environment/common.dart';
import '../utils/general.dart';
import '../utils/plugins/general.dart';

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
      bottomNavigationBar: getTipsBar(),
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

  int _runningProcess = 0;
  int _errorShowing = 0;

  Future<void> _startGetSambaPass() async {
    try {
      _runningProcess++;
      await getSambaPass();
      setState(() {
        _getSambaPassState =
            StateMsgSet(ProcessState.ok, str.loggingin_get_password_done);
      });
      _startMountSamba();
      _runningProcess--;
    } catch (e, trace) {
      setState(() {
        _getSambaPassState =
            StateMsgSet(ProcessState.failed, str.loggingin_get_password_fail);
      });
      _errorShow(e, trace);
    }
  }

  Future<void> _startMountSamba() async {
    try {
      setState(() {
        _mountSambaState =
            StateMsgSet(ProcessState.getting, str.loggingin_mount_start);
      });
      _runningProcess++;
      await mountSamba(context);
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
    } catch (e, trace) {
      setState(() {
        _mountSambaState =
            StateMsgSet(ProcessState.failed, str.loggingin_mount_fail);
      });
      _errorShow(e, trace);
    }
  }

  Future<void> _loadPluginSysConfig() async {
    try {
      setState(() {
        _loadPluginSysConfigState =
            StateMsgSet(ProcessState.waiting, str.loggingin_load_plugin_start);
      });
      _runningProcess++;
      await loadPluginSysConfig();
      setState(() {
        _loadPluginSysConfigState =
            StateMsgSet(ProcessState.ok, str.loggingin_load_plugin_done);
      });
      _runningProcess--;
      _startPluginSys();
    } catch (e, trace) {
      setState(() {
        _loadPluginSysConfigState =
            StateMsgSet(ProcessState.failed, str.loggingin_load_plugin_fail);
      });
      _errorShow(e, trace);
    }
  }

  Future<void> _startPluginSys() async {
    try {
      setState(() {
        _startPluginSysState =
            StateMsgSet(ProcessState.waiting, str.loggingin_start_plugin_start);
      });
      _runningProcess++;
      await startPluginSys();
      setState(() {
        _startPluginSysState =
            StateMsgSet(ProcessState.ok, str.loggingin_start_plugin_done);
      });
      _runningProcess--;
      _checkDone();
    } catch (e, trace) {
      setState(() {
        _startPluginSysState =
            StateMsgSet(ProcessState.failed, str.loggingin_start_plugin_fail);
      });
      _errorShow(e, trace);
    }
  }

  @override
  void initState() {
    _startGetSambaPass();
    super.initState();
  }

  _checkDone() {
    if (_runningProcess == 0 && _errorShowing == 0) {
      Navigator.popAndPushNamed(context, HomeScreen.routeName);
    }
  }

  void _errorShow(err, trace) async {
    _errorShowing++;
    await Future.delayed(Duration.zero, () => showError(context, err, trace));
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
    return Column(
      children: content,
    );
  }
}
