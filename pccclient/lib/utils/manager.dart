import 'package:pccclient/utils/general.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

late WebSocketChannel _channel;

String homeURL = "http://example.com";

StateMsgSet init() {
  _connect();
  _auth();
  return StateMsgSet(ProcessState.ok, "PCCCliMan接続完了");
}

_connect() {
  // TODO
  // _channel = WebSocketChannel.connect(Uri.parse(serverInfo.pccCliManAddress))
}

_auth() {
  // TODO
}
