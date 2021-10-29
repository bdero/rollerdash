import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:rollerdash/config.dart';
import 'package:rollerdash/schema.dart';

Future<List<StatusModel>> getAllStatuses(List<String> rollerIds) async {
  var results = <Future<StatusModel>>[];
  for (var id in rollerIds) {
    results.add(getStatus(id));
  }
  return await Future.wait(results);
}

Future<StatusModel> getStatus(String rollerId) async {
  var response = await http.post(
      Uri.parse(
          'https://autoroll.skia.org/twirp/autoroll.rpc.AutoRollService/GetStatus'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: '{"roller_id": "$rollerId"}');

  if (response.statusCode != 200) {
    throw Exception(
        "Failed to fetch `$rollerId` (status code: ${response.statusCode})");
  }

  Map<String, dynamic> result = jsonDecode(response.body);
  return StatusModel.fromJson(result['status']);
}

void printSummary(Config config) async {
  List<StatusModel> statuses = await getAllStatuses(config.rollers);
  for (var status in statuses) {
    print("${status.mini_status.roller_id.padLeft(32)} : "
        "${status.recent_rolls[0].result.padRight(12)}: "
        "${status.recent_rolls[0].subject}");
  }
}
