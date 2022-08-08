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

  int done = 0;

  @override
  void initState() {
    setState(() {
      _getSambaPassState =
          StateMsgSet(ProcessState.waiting, "ネットワークドライブのパスワードを取得中");
      _mountSambaState = StateMsgSet(ProcessState.waiting, "ネットワークドライブのマウント待ち");
      _connectCliManState = StateMsgSet(ProcessState.waiting, "PCCCliMan接続中");
    });
    var getSambaPassFuture = Future(getSambaPass);
    getSambaPassFuture.then((value) {
      done++;
      setState(() {
        _getSambaPassState = value;
        _mountSambaState =
            StateMsgSet(ProcessState.waiting, "ネットワークドライブのマウント中");
      });
      var mountSambaFuture = Future(mountSamba);
      mountSambaFuture.then((value) {
        done++;
        setState(() {
          _mountSambaState = value;
        });
        _checkDone();
      });
    });
    var connectCliManFuture = Future(init);
    getSambaPassFuture.then((value) {
      done++;
      setState(() {
        _connectCliManState = StateMsgSet(ProcessState.ok, "PCCCliMan接続完了");
      });
      _checkDone();
    });
    super.initState();
  }

  _checkDone() {
    if (done >= 3) {
      Navigator.popUntil(context, ModalRoute.withName(LoginSelectScreen.routeName));
      Navigator.popAndPushNamed(context, HomeScreen.routeName);
    }
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
