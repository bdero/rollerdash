import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

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

String decorateMode(String mode, bool bold) {
  var b = bold ? ";1" : "";
  switch (mode) {
    case "STOPPED":
      mode = "\u001b[31${b}mSTOPPED\u001b[0m 🛑";
      break;
    default:
      mode = "\u001b[32${b}mRUNNING\u001b[0m 🚀";
  }
  return mode;
}

String decorateResult(String result, bool bold) {
  var b = bold ? ";1" : "";
  switch (result) {
    case "FAILURE":
      result = "  \u001b[31${b}mFAILURE\u001b[0m  ";
      break;
    case "IN_PROGRESS":
      result = "\u001b[33${b}mIN_PROGRESS\u001b[0m";
      break;
    case "SUCCESS":
      result = "  SUCCESS  ";
      // Always color green when bold in this case.
      result = bold ? "\u001b[32${b}m$result\u001b[0m" : result;
      break;
    default:
      result = bold ? decorateBold(result) : result;
  }
  return result;
}

String decorateBold(String s) {
  return "\u001b[1m" + s + "\u001b[0m";
}

String decorateTimestamp(String timestamp, bool bold) {
  var r = timeago.format(DateTime.parse(timestamp));
  return bold ? decorateBold(r) : r;
}

void printSummary(Config config) async {
  stderr.writeln("Fetching summary...");

  List<StatusModel> statuses = await getAllStatuses(config.rollers);
  for (var status in statuses) {
    var firstRoll = status.recent_rolls[0];
    var printFailures = firstRoll.result != "SUCCESS";
    var mode = status.mini_status.mode;

    var summary = "\n" + (printFailures ? "  ┏━" : " ✅━");
    summary +=
        "${(' ' + decorateBold(status.mini_status.roller_id)).padLeft(41, '━')} ┃ "
        "${decorateResult(status.recent_rolls[0].result, true)} ┃ "
        "${decorateMode(mode, true)} ┃ "
        "${decorateBold('Behind:' + status.mini_status.num_behind.toString().padLeft(3) + ' commit' + (status.mini_status.num_behind == 1 ? " " : "s"))} ┃ "
        "${decorateBold('https://autoroll.skia.org/r/' + status.mini_status.roller_id)}";
    print(summary);

    if (!printFailures) continue;

    for (var i = 0; i < status.recent_rolls.length; i++) {
      var roll = status.recent_rolls[i];
      var isSuccess = roll.result == "SUCCESS";
      var isLastLine = isSuccess || i == status.recent_rolls.length - 1;

      var line = isLastLine
          ? "  ┗━"
          : " ${roll.result != "IN_PROGRESS" ? "❌━" : "🚧━"}";
      line +=
          "${(' ' + decorateTimestamp(roll.created, false)).padLeft(33, '━')} ┃ "
          "${decorateResult(roll.result, false)} ┃ "
          "${roll.rolling_from.substring(0, 13) + ' ⟶   ' + roll.rolling_to.substring(0, 13)} ┃ "
          "${status.issue_url_base + roll.id}";
      print(line);

      if (isSuccess) break;
    }
  }
}
