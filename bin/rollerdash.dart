import 'dart:io';

import 'package:rollerdash/console.dart' as console;
import 'package:rollerdash/config.dart';

void main(List<String> arguments) {
  exitCode = 0;
  final config = Config.fromArgs(arguments);

  console.printSummary(config);
}
