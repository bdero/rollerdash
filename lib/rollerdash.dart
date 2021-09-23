import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:rollerdash/config.dart';

class RollerSummary {}

// curl -X POST https://autoroll.skia.org/twirp/autoroll.rpc.AutoRollService/GetStatus \
//      -H 'Content-Type: application/json' -d '{"roller_id": "skia-flutter-autoroll"}'
//
// skia-flutter-autoroll
// clang-linux-flutter-engine
// clang-mac-flutter-engine
// dart-sdk-flutter-engine
// flutter-engine-flutter-autoroll
// flutter-plugins-flutter-autoroll
// fuchsia-linux-sdk-flutter-engine
// fuchsia-mac-sdk-flutter-engine
void printSummary(Config config) async {
  var response = await http.post(
      Uri.parse(
          'https://autoroll.skia.org/twirp/autoroll.rpc.AutoRollService/GetStatus'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: '{"roller_id": "skia-flutter-autoroll"}');

  if (response.statusCode != 200) {
    print('http request failed');
    return;
  }

  Map<String, dynamic> result = jsonDecode(response.body);
  List<Map<String, dynamic>> rolls = result['status']?['recent_rolls'];
}
