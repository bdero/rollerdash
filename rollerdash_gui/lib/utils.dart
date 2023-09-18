import 'package:rollerdash/schema.dart';

double secondsSinceRollCreated(RollModel roll) {
  return DateTime.now()
      .difference(DateTime.parse(roll.created))
      .inSeconds
      .toDouble();
}
