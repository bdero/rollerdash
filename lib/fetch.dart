import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

import 'package:rollerdash/schema.dart';

Future<List<StatusModel>> getAllStatuses(List<String> rollerIds) async {
  var results = <Future<StatusModel>>[];
  for (var id in rollerIds) {
    results.add(getStatus(id));
  }
  return await Future.wait(results);
}

Future<StatusModel> getStatus(String rollerId) async {
  // curl https://autoroll.skia.org/twirp/autoroll.rpc.AutoRollService/GetStatus
  //      -X POST -H "Content-Type: application/json; charset=UTF-8"
  //      -d '{"roller_id": "skia-flutter-autoroll"}'

  // Autoroller service RPCs fail quite frequently, so we perform retries with
  // exponential backoff and jitter.
  var random = Random();
  Duration delay(double seconds) {
    var ms = seconds * 1000;
    return Duration(
        milliseconds: (ms + random.nextDouble() * ms * 0.3) ~/ 2);
  }
  var client = RetryClient.withDelays(http.Client(), [
    delay(1),
    delay(2),
    delay(3),
    delay(5),
    delay(8),
    delay(13),
    delay(21),
  ]);

  var response = await client.post(
      Uri.parse(
          'https://autoroll.skia.org/twirp/autoroll.rpc.AutoRollService/GetStatus'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: '{"roller_id": "$rollerId"}');

  if (response.statusCode != 200) {
    throw Exception(
        "Failed to fetch `$rollerId` 7 times (status code: ${response.statusCode})");
  }

  Map<String, dynamic> result = jsonDecode(response.body);
  return StatusModel.fromJson(result['status']);
}
