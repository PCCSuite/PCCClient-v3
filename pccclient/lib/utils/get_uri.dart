import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<String> getStringFromURIString(String uri) async {
  return getStringFromURI(Uri.parse(uri));
}

Future<String> getStringFromURI(Uri uri) async {
  switch (uri.scheme.toLowerCase()) {
    case "http":
    case "https":
      http.Response response = await http.get(uri);
      return response.body;
    case "tcp":
      Socket sock = await Socket.connect(uri.host, uri.port);
      String res = await utf8.decodeStream(sock);
      return res;
    case "file":
      File file = File.fromUri(uri);
      return file.readAsStringSync();
    default:
      throw UnsupportedError("This uri is not supported");
  }
}
