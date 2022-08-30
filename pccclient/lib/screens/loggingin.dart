import 'package:flutter/material.dart';
import 'package:pccclient/screens/home.dart';
import 'package:pccclient/screens/login_select.dart';
import 'package:pccclient/utils/auth.dart';
import 'package:pccclient/utils/general.dart';
import 'package:pccclient/utils/manager.dart';

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

  static const screenName = "ログイン中...";

  const LoggingInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(LoggingInScreen.screenName),
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
  late StateMsgSet _getSambaPassState;
  late StateMsgSet _mountSambaState;
  late StateMsgSet _connectCliManState;

  int _remainProcess = 3;
  int _errorShowing = 0;

  @override
  void initState() {
    setState(() {
      _getSambaPassState =
          StateMsgSet(ProcessState.getting, str.loggingin_get_password_start);
      _mountSambaState =
          StateMsgSet(ProcessState.waiting, str.loggingin_mount_wait);
      _connectCliManState =
          StateMsgSet(ProcessState.getting, str.loggingin_climan_start);
    });
    var getSambaPassFuture = Future(getSambaPass);
    getSambaPassFuture.then((_) {
      _remainProcess--;
      setState(() {
        _getSambaPassState =
            StateMsgSet(ProcessState.ok, str.loggingin_get_password_done);
        _mountSambaState =
            StateMsgSet(ProcessState.getting, str.loggingin_mount_start);
      });
      var mountSambaFuture = Future(mountSamba);
      mountSambaFuture.then((_) {
        _remainProcess--;
        setState(() {
          _mountSambaState =
              StateMsgSet(ProcessState.ok, str.loggingin_mount_done);
        });
        _checkDone();
      }).catchError((e, trace) {
        setState(() {
          _mountSambaState =
              StateMsgSet(ProcessState.failed, str.loggingin_mount_fail);
        });
        _errorShow(e, trace);
      });
    }).catchError((e, trace) {
      setState(() {
        _getSambaPassState =
            StateMsgSet(ProcessState.failed, str.loggingin_get_password_fail);
      });
      _errorShow(e, trace);
    });
    var connectCliManFuture = Future(init);
    connectCliManFuture.then((value) {
      _remainProcess--;
      setState(() {
        _connectCliManState =
            StateMsgSet(ProcessState.ok, str.loggingin_climan_done);
      });
      _checkDone();
    }).catchError((e, trace) {
      setState(() {
        _connectCliManState =
            StateMsgSet(ProcessState.failed, str.loggingin_climan_fail);
      });
      _errorShow(e, trace);
    });
    super.initState();
  }

  _checkDone() {
    if (_remainProcess == 0 && _errorShowing == 0) {
      Navigator.popUntil(
          context, ModalRoute.withName(LoginSelectScreen.routeName));
      Navigator.popAndPushNamed(context, HomeScreen.routeName);
    }
  }

  void _errorShow(err, trace) async {
    _errorShowing++;
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(str.error_dialog_title),
              scrollable: true,
              content: Column(
                children: [
                  Text(str.error_dialog_description),
                  Text("$err\n$trace"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    str.error_dialog_ignore,
                    style: TextStyle(color: Colors.redAccent),
                  ),
                )
              ],
            ));
    _errorShowing--;
    _remainProcess--;
    _checkDone();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LoggingInStateRow(_getSambaPassState),
        _LoggingInStateRow(_mountSambaState),
        _LoggingInStateRow(_connectCliManState),
      ],
    );
  }
}
