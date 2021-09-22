import 'dart:io';

import 'package:rollerdash/rollerdash.dart' as rollerdash;
import 'package:rollerdash/config.dart';

void main(List<String> arguments) {
  exitCode = 0;
  final config = Config.fromArgs(arguments);

  if (config.verbose) {
    print('Running in verbose mode.');
  }

  rollerdash.printSummary(config);
}
