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
  return Future.wait(results);
}

Future<Map<String, dynamic>> getStatusRaw(String rollerId) async {
  // curl https://autoroll.skia.org/twirp/autoroll.rpc.AutoRollService/GetStatus
  //      -X POST -H "Content-Type: application/json; charset=UTF-8"
  //      -d '{"roller_id": "skia-flutter-autoroll"}'

  // Occasionally the Autoroll service experiences a high failure rate, so we
  // perform retries with exponential backoff and jitter.
  var random = Random();
  Duration delay(double seconds) {
    var ms = seconds * 1000;
    return Duration(milliseconds: (ms + random.nextDouble() * ms * 0.3) ~/ 2);
  }

  // Uncomment to test error handling by throwing exceptions 15% of the time.
  //
  // if (random.nextDouble() < 0.15) {
  //   return Future.delayed(Duration(seconds: 1), () {
  //     throw Exception("Random test exception");
  //   });
  // }

  var client = RetryClient.withDelays(
      http.Client(),
      [
        delay(1),
        delay(2),
        delay(3),
        delay(5),
        delay(8),
        delay(13),
        delay(21),
      ],
      whenError: (object, stackTrace) => true);

  http.Response response;
  try {
    response = await client.post(
        Uri.parse(
            'https://autoroll.skia.org/twirp/autoroll.rpc.AutoRollService/GetStatus'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: '{"roller_id": "$rollerId"}');
  } catch (error) {
    throw Exception(
        "Failed to fetch `$rollerId` 7 times (last error: $error)");
  }

  client.close();

  return jsonDecode(response.body);
}

Future<StatusModel> getStatus(String rollerId) async {
  var raw = getStatusRaw(rollerId);
  return raw.then((value) => StatusModel.fromJson(value['status']));
}
