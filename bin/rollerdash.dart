import 'dart:io';

import 'package:rollerdash/console.dart' as console;
import 'package:rollerdash/config.dart';

void main(List<String> arguments) {
  exitCode = 0;
  final config = Config.fromArgs(arguments);

  switch (config.runMode) {
    case RunMode.print:
      console.printSummary(config);
      break;
    case RunMode.watch:
      console.watchSummary(config);
      break;
    case RunMode.dump:
      console.dump(config);
      break;
  }
}
