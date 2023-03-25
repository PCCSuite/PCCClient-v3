import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth.dart';
import 'server_info.dart';

Future<void> registerAttendance() async {
  http.Response response = await http.post(
    Uri.parse(serverInfo.attendanceURL),
    headers: {
      // "Authorization": "Bearer ${await getToken()}",
      "Content-Type": "application/json",
    },
    body: jsonEncode(
      {
        "status": "online",
        "name": username,
        "reg_type": "pccclient",
      },
    ),
  );
  if (response.statusCode != 200) {
    throw Exception(
        "Failed to register attendance: ${response.statusCode}, body: ${response.body}");
  }
}
