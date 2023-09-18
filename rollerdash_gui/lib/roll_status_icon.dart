import 'package:flutter/material.dart';

import 'package:rollerdash/schema.dart';
import 'package:rollerdash_gui/utils.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Displays an icon indicating whether the last completed roll was successful
/// or not.
class RollStatusIcon extends StatelessWidget {
  const RollStatusIcon({Key? key, required this.status}) : super(key: key);

  final StatusModel status;

  @override
  Widget build(BuildContext context) {
    // Find the first roll entry that isn't in-progress.
    try {
      // Display an amber warning icon if the most recent roll has been
      // in-progress for 5 hours or more.
      var warningOverride = status.recent_rolls.isNotEmpty &&
          status.recent_rolls.first.result == 'IN_PROGRESS' &&
          secondsSinceRollCreated(status.recent_rolls.first) >= 60 * 60 * 5;
      final roll = status.recent_rolls
          .firstWhere((roll) => roll.result != 'IN_PROGRESS');
      switch (roll.result) {
        case 'SUCCESS':
          return Tooltip(
            message:
                'Last success: ${timeago.format(DateTime.parse(roll.created))}',
            child: Icon(
              warningOverride
                  ? Icons.warning_amber_outlined
                  : Icons.check_outlined,
              color: warningOverride ? Colors.amber : Colors.green,
            ),
          );
        case 'FAILURE':
          return Tooltip(
            message:
                'Last failure: ${timeago.format(DateTime.parse(roll.created))}',
            child: const Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
          );
        default:
          debugPrint(
              'Unexpected roll status for ${status.mini_status.roller_id}: ${roll.result}');
          break;
      }
    } on StateError {
      debugPrint(
          'No completed roll found for ${status.mini_status.roller_id}.');
    }

    return const Tooltip(
      message: 'This roller is in an inknown state!',
      child: Icon(
        Icons.question_mark,
        color: Colors.yellow,
      ),
    );
  }
}
